"""Explicitly build Neorg parsers using this host's compiler; no binaries are copied across OSes."""
import argparse
from pathlib import Path
import subprocess
import tempfile

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apply',action='store_true')
    args=parser.parse_args()
    if not args.apply:
        print('Preview: build norg/norg_meta parsers using locked Neorg configs and the current host compiler.')
        return
    with tempfile.TemporaryDirectory(prefix='neorg-provision-') as directory:
        script=Path(directory)/'deploy.lua'
        script.write_text("local ok,err=xpcall(function() require('neorg_setup').install() end,debug.traceback)\n"
                          "if not ok then print(err) end\nvim.cmd(ok and 'qa!' or 'cquit 1')\n",encoding='utf-8')
        subprocess.run(['nvim','--headless','-n','--cmd','let g:coc_start_at_startup=0','+luafile '+str(script)],
                       check=True,timeout=180,cwd=Path(__file__).resolve().parent.parent)

if __name__=='__main__':main()
