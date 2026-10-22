"""顺序运行配置集成回归；不安装依赖、不授权账号、不改用户项目。"""
import argparse
from datetime import datetime, timezone
import json
import os
from pathlib import Path
import subprocess
import sys
import time
from nvim_process import run_nvim

ROOT = Path(__file__).resolve().parents[1]
SMOKES = [
    'process_runner', 'windows_tools', 'startup', 'python_provider', 'go_startup', 'git_lifecycle', 'editor', 'ui_startup',
    'keys', 'large_file_growth', 'coc_large_growth', 'project_theme', 'search', 'native_extension',
    'command_palette', 'palette_concurrency', 'palette_migration', 'tutor', 'file_tree', 'surround',
    'lazy_loading', 'parser_deployment', 'neorg_deploy', 'keymap_inventory', 'coc', 'ai', 'rest',
]
LANGUAGES = ['python', 'python-venv', 'lua', 'javascript', 'typescript',
             'javascriptreact', 'typescriptreact', 'vue26', 'vue27', 'vue3', 'go']


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    jobs = [[str(ROOT/'tests'/f'{name}_smoke.py')] for name in SMOKES]
    jobs += [[str(ROOT/'tests/language_services_smoke.py'), '--language', name] for name in LANGUAGES]
    records = []
    env = os.environ.copy()
    env['PYTHONIOENCODING'] = 'utf-8'
    for job in jobs:
        started = time.monotonic()
        print('RUN ' + ' '.join(job), flush=True)
        try:
            result = run_nvim([sys.executable, *job], cwd=ROOT, env=env, timeout=180)
            record = dict(test=' '.join(job).replace(str(ROOT), '.'),
                          passed=result.returncode == 0, output=result.stdout)
        except AssertionError as error:
            record = dict(test=' '.join(job), passed=False, output=str(error))
        record['seconds'] = round(time.monotonic() - started, 3)
        records.append(record)
        print(record['output'], flush=True)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(dict(utc=datetime.now(timezone.utc).isoformat(),
        revision=subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
        note='修订号加当前工作区；TUI及macOS另列平台验收，候选性能试验不属于此回归。',
        results=records), ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    failed = [record['test'] for record in records if not record['passed']]
    print(f'{len(records)-len(failed)}/{len(records)} passed; failures={failed}')
    raise SystemExit(bool(failed))


if __name__ == '__main__':
    main()
