"""Check that a stalled compiler cannot block Neovim's first screen.

Run with Python 3.9+. Requires the configured Neovim and a C compiler.
The deliberately stalled gcc fixture is used only in a child process PATH.
"""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import time
import sys


def main():
    sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'scripts'))
    from bootstrap_rocks import build_environment
    build_env, _ = build_environment()
    compiler = shutil.which("gcc", path=build_env['PATH']) or shutil.which("cc", path=build_env['PATH'])
    if not compiler:
        raise SystemExit("Test requires gcc or cc")
    with tempfile.TemporaryDirectory(prefix="nvim-startup-smoke-") as directory:
        root = Path(directory)
        source = root / "stalled.c"
        source.write_text(
            '#include <stdio.h>\n#ifdef _WIN32\n#include <windows.h>\n'
            '#define pause() Sleep(8000)\n#else\n#include <unistd.h>\n'
            '#define pause() sleep(8)\n#endif\n'
            'int main(void) { pause(); puts("x86_64-w64-mingw32"); return 0; }\n',
            encoding="utf-8")
        binary = root / ("gcc.exe" if os.name == "nt" else "gcc")
        subprocess.run([compiler, str(source), "-o", str(binary)], env=build_env, check=True, timeout=30)
        env = os.environ.copy()
        env["PATH"] = str(root) + os.pathsep + env.get("PATH", "")
        started = time.monotonic()
        result = subprocess.run([
            "nvim", "--headless", "-n", "--cmd", "let g:coc_start_at_startup=0",
            "+lua vim.schedule(function() print('FIRST_SCREEN_READY'); vim.cmd('qa!') end)"],
            env=env, cwd=root, capture_output=True, text=True, timeout=12)
        elapsed = time.monotonic() - started
        assert result.returncode == 0, result.stdout + result.stderr
        assert "FIRST_SCREEN_READY" in result.stderr + result.stdout
        assert elapsed < 3, f"Stalled compiler blocked startup: {elapsed:.2f}s (budget 3s)"
        print(f"PASS stalled compiler does not block startup: {elapsed:.2f}s")


if __name__ == "__main__":
    main()
