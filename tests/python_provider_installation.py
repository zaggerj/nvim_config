"""Explicit deployment integration: repair a managed venv interrupted before pip."""
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import venv
from nvim_process import run_nvim


def main():
    script = Path(__file__).resolve().parents[1] / 'scripts' / 'provision_python.py'
    with tempfile.TemporaryDirectory(prefix='nvim provider install ') as directory:
        data = Path(directory)
        destination = data / 'tools' / 'python-provider'
        venv.EnvBuilder(with_pip=False).create(destination)
        marker = destination / 'nvim-provider.json'
        marker.write_text(json.dumps(dict(tool='nvim-python-provider', complete=False)), encoding='utf-8')
        sentinel = destination / 'retained-user-file.txt'
        sentinel.write_text('keep me', encoding='utf-8')
        result = run_nvim([sys.executable, str(script), '--data', str(data), '--apply'], timeout=300)
        assert result.returncode == 0, result.stdout
        assert json.loads(marker.read_text(encoding='utf-8'))['complete'] is True
        assert sentinel.read_text(encoding='utf-8') == 'keep me'
        print('PASS interrupted venv repaired; real provider imports validated; existing data retained')


if __name__ == '__main__':
    main()
