"""Measure a real RPC UI, functional readiness and actual Telescope results.

Use an isolated Python environment containing pynvim; never clears editor caches.
Optional --compare-root alternates A/B configurations over the same generated files.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import re
import statistics
import subprocess
import tempfile
import time

import pynvim


PRELOAD = r'''
local started = (vim.uv or vim.loop).hrtime()
local result = {}
local function elapsed() return ((vim.uv or vim.loop).hrtime() - started) / 1e6 end
vim.defer_fn(function()
  vim.rpcnotify(1, 'benchmark_error', 'measurement exceeded 35 seconds')
end, 35000)
vim.api.nvim_create_autocmd('VimEnter', {once=true, callback=function()
  vim.rpcnotify(1, 'benchmark_vimenter', elapsed())
  local function run_poll()
    local buf = vim.api.nvim_get_current_buf()
    if not result.editor_ready_ms and vim.treesitter.highlighter.active[buf]
      and vim.o.statusline:find('lualine', 1, true) then result.editor_ready_ms = elapsed() end
    if not result.coc_rpc_ms and vim.fn.exists('*coc#rpc#ready') == 1
      and vim.fn['coc#rpc#ready']() == 1 then result.coc_rpc_ms = elapsed() end
    if result.coc_rpc_ms and not result.definition_provider_ms then
      local ok, ready = pcall(vim.fn.CocHasProvider, 'definition')
      if ok and (ready == true or ready == 1) then result.definition_provider_ms = elapsed() end
    end
    if elapsed() < 8000 and not (result.editor_ready_ms and result.definition_provider_ms) then
      vim.defer_fn(function()
        local ok, err = xpcall(run_poll, debug.traceback)
        if not ok then vim.rpcnotify(1, 'benchmark_error', err) end
      end, 10)
    else
      result.language_filetype = vim.bo.filetype
      local builtin = require('telescope.builtin')
      local state = require('telescope.actions.state')
      local actions = require('telescope.actions')
      local function picker(kind, open)
        local begin = (vim.uv or vim.loop).hrtime()
        open()
        local found = vim.wait(8000, function()
          local current = state.get_current_picker(vim.api.nvim_get_current_buf())
          return current and current.manager and current.manager:num_results() > 0
        end, 5)
        result[kind .. '_first_result_ms'] = found and ((vim.uv or vim.loop).hrtime() - begin) / 1e6 or vim.NIL
        local current = state.get_current_picker(vim.api.nvim_get_current_buf())
        if current then actions.close(current.prompt_bufnr) end
      end
      picker('files', function() builtin.find_files() end)
      picker('grep', function() builtin.live_grep({default_text='BENCHMARK_NEEDLE'}) end)
      result.colors_name = vim.g.colors_name
      result.loaded_plugins = 0
      for _, plugin in pairs(require('lazy.core.config').plugins) do
        if plugin._.loaded then result.loaded_plugins = result.loaded_plugins + 1 end
      end
      vim.rpcnotify(1, 'benchmark_done', result)
    end
  end
  vim.schedule(function()
    local ok, err = xpcall(run_poll, debug.traceback)
    if not ok then vim.rpcnotify(1, 'benchmark_error', err) end
  end)
end})
'''


def measure(config, project, preload, log):
    argv = ['nvim', '--embed', '-n', '--startuptime', str(log), '-u', str(config / 'init.vim'),
            '--cmd', 'lua dofile(' + json.dumps(preload.as_posix()) + ')', str(project / 'main.py')]
    started = time.perf_counter()
    nvim = pynvim.attach('child', argv=argv)
    result = {}
    entered = False

    def notice(name, args):
        nonlocal entered
        if name == 'benchmark_vimenter':
            entered = True
            result['vimenter_ms'] = args[0]
        elif name == 'redraw' and entered and 'first_ui_flush_wall_ms' not in result:
            if any(event[0] == 'flush' for event in args):
                result['first_ui_flush_wall_ms'] = (time.perf_counter() - started) * 1000
        elif name == 'benchmark_done':
            result.update(args[0])
            nvim.stop_loop()
        elif name == 'benchmark_error':
            result['error'] = args[0]
            nvim.stop_loop()

    try:
        nvim.ui_attach(100, 35, rgb=True)
        nvim.run_loop(None, notice)
        try:
            nvim.command('qa!')
        except (EOFError, OSError):
            pass
    finally:
        nvim.close()
    if 'error' in result:
        raise RuntimeError(result['error'])
    text = log.read_text(encoding='utf-8', errors='replace')
    screens = re.findall(r'([\d.]+)\s+[\d.]+: first screen update', text)
    result['first_screen_internal_ms'] = float(screens[-1]) if screens else None
    result['process_wall_ms'] = (time.perf_counter() - started) * 1000
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--config-root', type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument('--compare-root', type=Path)
    parser.add_argument('--runs', type=int, default=3)
    parser.add_argument('--files', type=int, default=1200)
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    assert args.runs > 0 and args.files > 0, 'runs and files must be positive'
    configs = [('A', args.config_root.resolve())]
    if args.compare_root:
        configs.append(('B', args.compare_root.resolve()))
    records = []
    with tempfile.TemporaryDirectory(prefix='nvim-benchmark-') as directory:
        project = Path(directory)
        (project / 'main.py').write_text('def greet(name: str) -> str:\n    return name\nprint(greet("world"))\n', encoding='utf-8')
        (project / 'pyproject.toml').write_text('[project]\nname="nvim-benchmark"\nversion="0.1.0"\n', encoding='utf-8')
        for number in range(args.files):
            file = project / 'src' / f'module{number // 100:03d}' / f'file{number:05d}.py'
            file.parent.mkdir(parents=True, exist_ok=True)
            file.write_text(f'BENCHMARK_NEEDLE = {number}\n', encoding='utf-8')
        (project / '.gitignore').write_text('ignored/\n*.log\n', encoding='utf-8')
        (project / 'ignored').mkdir()
        (project / 'ignored/cache.py').write_text('BENCHMARK_NEEDLE = "ignored"\n', encoding='utf-8')
        subprocess.run(['git', 'init', '-q', str(project)], check=True, timeout=15)
        preload = project / 'preload.lua'
        preload.write_text(PRELOAD, encoding='utf-8')
        for number in range(1, args.runs + 1):
            for kind, config in configs:
                log = project / f'{kind}-{number}.log'
                record = measure(config, project, preload, log)
                record.update(kind=kind, run=number, cache_state='first-observed' if number == 1 else 'warm-repeated')
                records.append(record)
                print(json.dumps(record, ensure_ascii=False), flush=True)
    fields = ('first_screen_internal_ms', 'first_ui_flush_wall_ms', 'editor_ready_ms', 'coc_rpc_ms',
              'definition_provider_ms', 'files_first_result_ms', 'grep_first_result_ms')
    summaries = {}
    for kind, _ in configs:
        summaries[kind] = {}
        for field in fields:
            samples = [r[field] for r in records if r['kind'] == kind and isinstance(r.get(field), (int, float))]
            summaries[kind][field] = dict(median=statistics.median(samples), minimum=min(samples), maximum=max(samples)) if samples else None
    evidence = dict(platform=platform.platform(), python=platform.python_version(),
                    neovim=subprocess.check_output(['nvim', '--version'], text=True).splitlines()[0],
                    config_sources={kind: {str(p.relative_to(config)): hashlib.sha256(p.read_bytes()).hexdigest()
                                           for p in ([config / 'init.vim', config / 'lazy-lock.json']
                                                     + sorted((config / 'lua').rglob('*.lua'))
                                                     + sorted((config / 'mysettings').rglob('*.vim')))}
                                    for kind, config in configs},
                    method='RPC UI attach 100x35; internal first screen from --startuptime; first UI flush after VimEnter uses Python process wall clock; no physical terminal painting.',
                    cache='No user cache deleted. First-observed is not certified cold; later samples warm repeated. A/B alternate only when compare-root is provided.',
                    readiness='Lua pre-init hrtime; highlighter+statusline, Coc RPC and definition-provider availability separately; 10ms polling. Provider availability is not completion-quality verification.',
                    fixture=dict(files=args.files, kind='generated Python project and ignored Git cache', search='same input set for all variants'),
                    runs=records, summary_ms=summaries)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(evidence, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    required = ('first_ui_flush_wall_ms', 'first_screen_internal_ms', 'editor_ready_ms',
                'coc_rpc_ms', 'definition_provider_ms', 'files_first_result_ms', 'grep_first_result_ms')
    for record in records:
        assert all(isinstance(record.get(field),(int,float)) and record[field]>0 for field in required), record


if __name__ == '__main__':
    main()
