"""Exercise successful, failed and timed-out child lifecycles without touching peers."""
import subprocess
import sys
import time
from nvim_process import run_nvim


def main():
    peer = subprocess.Popen([sys.executable, '-c', 'import time; time.sleep(30)'])
    try:
        success = run_nvim([sys.executable, '-c', 'print("ready")'], timeout=2)
        assert success.returncode == 0 and 'ready' in success.stdout
        failed = run_nvim([sys.executable, '-c', 'print("failed"); raise SystemExit(7)'], timeout=2)
        assert failed.returncode == 7 and 'failed' in failed.stdout
        started = time.monotonic()
        try:
            run_nvim([sys.executable, '-u', '-c',
                      'import subprocess,sys,time; '
                      'subprocess.Popen([sys.executable,"-c","import time; time.sleep(30)"]); '
                      'print("before timeout",flush=True); time.sleep(30)'], timeout=0.6)
        except AssertionError as error:
            assert 'timed out' in str(error) and 'before timeout' in str(error), str(error)
        else:
            raise AssertionError('Timeout was silently accepted')
        assert time.monotonic() - started < 6
        assert peer.poll() is None, 'Unrelated process was terminated'
        print('PASS success/failure/timeout preserve output and leave unrelated processes alive')
    finally:
        peer.kill()
        peer.wait(timeout=3)


if __name__ == '__main__':
    main()
