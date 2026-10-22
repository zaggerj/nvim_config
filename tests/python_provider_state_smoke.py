"""An incomplete editor provider must show a usable deployment instruction."""
import json
import os
from pathlib import Path
import shutil
import sys
import tempfile
from nvim_process import run_nvim

LUA = r'''
vim.opt.runtimepath:prepend(vim.env.NVIM_SOURCE_ROOT)
assert(vim.fn.stdpath('data')==vim.env.NVIM_EXPECTED_DATA,'fixture data directory mismatch')
require('bootstrap').init(vim.env.NVIM_SOURCE_ROOT)
vim.cmd('filetype plugin indent on')
vim.cmd.edit(vim.env.NVIM_PROVIDER_SAMPLE)
vim.schedule(function()
 local ok,err=xpcall(function()
  local messages=vim.api.nvim_exec2('messages',{output=true}).output
  assert(messages:find('provision_python.py',1,true),'Incomplete provider gives no deployment instruction')
  assert(messages:gsub('\\','/'):find(vim.env.NVIM_SOURCE_ROOT,1,true),'Instruction does not identify config source directory')
  print('PASS incomplete provider reports deployment instruction and source directory')
 end,debug.traceback)
 if not ok then print(err) end
 vim.cmd(ok and 'qa!' or 'cquit 1')
end)
'''


def main():
    source = Path(__file__).resolve().parents[1]
    with tempfile.TemporaryDirectory(prefix='nvim provider state ') as directory:
        root = Path(directory)
        data = root / 'data' / ('nvim-data' if os.name == 'nt' else 'nvim')
        provider = data / 'tools' / 'python-provider'
        python = provider / ('Scripts/python.exe' if os.name == 'nt' else 'bin/python')
        python.parent.mkdir(parents=True)
        shutil.copy2(sys.executable, python)
        (provider / 'nvim-provider.json').write_text(json.dumps(dict(tool='nvim-python-provider',complete=False)))
        sample = root / 'sample.py'
        sample.write_text('print(42)\n')
        probe = root / 'verify.lua'
        probe.write_text(LUA,encoding='utf-8')
        env = dict(os.environ, XDG_DATA_HOME=str(root/'data'), NVIM_SOURCE_ROOT=source.as_posix(),
                   NVIM_EXPECTED_DATA=str(data), NVIM_PROVIDER_SAMPLE=str(sample))
        env.pop('NVIM_APPNAME',None)
        result = run_nvim(['nvim','--headless','-u','NONE','-n','+luafile '+str(probe)],cwd=root,env=env,timeout=12)
        assert result.returncode==0,result.stdout
        print(result.stdout)


if __name__=='__main__':main()
