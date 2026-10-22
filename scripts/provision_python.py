"""Explicitly deploy Neovim's Python provider, isolated from project/global packages."""
import argparse
import json
import os
from pathlib import Path
import subprocess
import sys
import venv


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--data', required=True, type=Path, help="Neovim stdpath('data')")
    parser.add_argument('--apply', action='store_true')
    args = parser.parse_args()
    if sys.version_info < (3, 9):
        parser.error('Python 3.9+ is required')
    destination = args.data.expanduser().resolve() / 'tools' / 'python-provider'
    marker = destination / 'nvim-provider.json'
    if destination.exists():
        if not marker.is_file() or json.loads(marker.read_text(encoding='utf-8')).get('tool') != 'nvim-python-provider':
            raise SystemExit(f'Refusing to modify an unmanaged directory: {destination}')
    if not args.apply:
        print(f'Preview: deploy pinned Python provider into {destination}; global/project packages retained')
        return
    destination.mkdir(parents=True, exist_ok=True)
    state = dict(tool='nvim-python-provider', complete=False)
    marker.write_text(json.dumps(state) + '\n', encoding='utf-8')
    python = destination / ('Scripts/python.exe' if os.name == 'nt' else 'bin/python')
    if not python.is_file():
        venv.EnvBuilder(with_pip=True).create(destination)
    env = os.environ.copy()
    for name in ('PYTHONHOME', 'PYTHONPATH'):
        env.pop(name, None)
    requirements = Path(__file__).with_name('python-provider-requirements.txt')
    subprocess.run([str(python), '-m', 'pip', 'install', '--disable-pip-version-check',
                    '--only-binary=:all:', '-r', str(requirements)], env=env, check=True, timeout=180)
    subprocess.run([str(python), '-m', 'pip', 'check'], env=env, check=True, timeout=30)
    # Import the real C extensions, not just package metadata or find_spec.
    subprocess.run([str(python), '-c', 'import neovim, pynvim, greenlet, msgpack; print("Python provider imports OK")'],
                   env=env, check=True, timeout=30)
    state.update(complete=True, python=str(python))
    marker.write_text(json.dumps(state, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(f'Python provider ready: {python}; restart Neovim')


if __name__ == '__main__':
    main()
