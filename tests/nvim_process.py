"""Run configured Neovim with a bounded lifetime and track only its own descendants.

Test dependency: psutil (see requirements.txt). File output avoids inherited PIPE EOF
keeping Python communicate() blocked after the Neovim process itself has exited.
"""
import os
from pathlib import Path
import subprocess
import tempfile
import time
import psutil


def run_nvim(argv, *, cwd=None, env=None, timeout=20):
    with tempfile.TemporaryDirectory(prefix="nvim-process-", ignore_cleanup_errors=True) as directory:
        output = Path(directory) / "output.log"
        descendants = {}
        timed_out = False
        with output.open("wb") as stream:
            process = subprocess.Popen(argv, cwd=cwd, env=env, stdin=subprocess.DEVNULL,
                                       stdout=stream, stderr=subprocess.STDOUT)
            parent = psutil.Process(process.pid)
            deadline = time.monotonic() + timeout
            while process.poll() is None:
                try:
                    for child in parent.children(recursive=True):
                        descendants[(child.pid, child.create_time())] = child
                except psutil.Error:
                    pass
                if time.monotonic() > deadline:
                    timed_out = True
                    break
                time.sleep(0.01)
            alive = []
            for child in descendants.values():
                try:
                    if child.is_running() and child.status() != psutil.STATUS_ZOMBIE:
                        alive.append(child)
                except psutil.Error:
                    pass
            # Neovim's main process itself is tracked too, never unrelated processes.
            if process.poll() is None:
                alive.append(parent)
            if alive:
                _, alive = psutil.wait_procs(alive, timeout=0.5)
            leaked = []
            for child in alive:
                try:
                    leaked.append((child.pid, child.name(), child.cmdline()))
                    child.kill()
                except psutil.Error:
                    pass
            psutil.wait_procs(alive, timeout=3)
            process.wait(timeout=3)
        captured = output.read_text(encoding="utf-8", errors="replace")
        try:
            output.unlink()
        except PermissionError as error:
            raise AssertionError("A child retained Neovim output handles after exit: " + str(output)) from error
        assert not timed_out, f"Neovim timed out after {timeout}s; descendants={leaked}\n{captured}"
        assert not leaked, f"Neovim left child processes: {leaked}\n{captured}"
        return subprocess.CompletedProcess(argv, process.returncode, captured, "")
