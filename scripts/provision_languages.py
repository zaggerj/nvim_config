"""Explicitly deploy pinned language tools; editor startup never downloads these tools.

python scripts/provision_languages.py --data <stdpath(data)> --lua --go --apply
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import shutil
import subprocess
import tarfile
import tempfile
import urllib.request
import zipfile

LUA_VERSION = "3.19.2"
GOIMPORTS_VERSION = "v0.47.1-0.20260707181000-a299dadba899"  # Same tools module as gopls 0.23.0.
GOPLS_VERSION = "v0.23.0"  # Last verified release compatible with the installed Go 1.26 toolchain.
LUA_ASSETS = {
    "win32-x64": ("zip", "4a3dc851b3b31e7b75a23f645d1ba4a2137579a55f5fa4edbb17a3e2a6254044"),
    "darwin-arm64": ("tar.gz", "79149584320a23bd5fcd5bc31f47a1975acd8a4560a0e89036bb1016fa61687f"),
    "darwin-x64": ("tar.gz", "6f2174ece5ec63bcd9d5b22b2c902445c1cd9045fafe48c62602448ebf4c09cc"),
}


def lua_asset():
    arch = "arm64" if platform.machine().lower() in ("arm64", "aarch64") else "x64"
    system = "win32" if os.name == "nt" else platform.system().lower()
    key = system + "-" + arch
    if key not in LUA_ASSETS:
        raise SystemExit("No verified LuaLS asset for " + key)
    extension, digest = LUA_ASSETS[key]
    name = f"lua-language-server-{LUA_VERSION}-{key}.{extension}"
    return name, digest


def install_lua(data):
    target = data / "coc/extensions/coc-lua-data/lua-language-server"
    executable = target / "bin" / ("lua-language-server.exe" if os.name == "nt" else "lua-language-server")
    marker = target / "nvim-config-version.json"
    if executable.is_file() and marker.is_file() and json.loads(marker.read_text())["version"] == LUA_VERSION:
        print("LuaLS already provisioned:", executable)
        return
    name, expected = lua_asset()
    cache = data / "tool-archives"
    cache.mkdir(parents=True, exist_ok=True)
    archive = cache / name
    if not archive.is_file() or hashlib.sha256(archive.read_bytes()).hexdigest() != expected:
        url = f"https://github.com/LuaLS/lua-language-server/releases/download/{LUA_VERSION}/{name}"
        staged = cache / (name + ".part")
        print("Downloading official LuaLS:", url, flush=True)
        with urllib.request.urlopen(urllib.request.Request(url, headers={"User-Agent": "nvim-config-provision"}), timeout=60) as source, staged.open("wb") as out:
            shutil.copyfileobj(source, out)
        actual = hashlib.sha256(staged.read_bytes()).hexdigest()
        if actual != expected:
            raise SystemExit("LuaLS SHA256 mismatch; staged archive retained for inspection")
        staged.replace(archive)
    target.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="lua-ls-stage-", dir=target.parent) as stage:
        staging = Path(stage) / "content"
        staging.mkdir()
        if archive.suffix == ".zip":
            with zipfile.ZipFile(archive) as package:
                for name in package.namelist():
                    if not (staging / name).resolve().is_relative_to(staging.resolve()):
                        raise SystemExit("Unsafe LuaLS archive entry")
                package.extractall(staging)
        else:
            with tarfile.open(archive) as package:
                # Python 3.9+ portability: validate every member before extraction.
                # Official LuaLS archives contain regular files/directories only.
                for member in package.getmembers():
                    if not (member.isfile() or member.isdir()):
                        raise SystemExit("Unsafe LuaLS archive member type: " + member.name)
                    if not (staging / member.name).resolve().is_relative_to(staging.resolve()):
                        raise SystemExit("Unsafe LuaLS archive entry")
                package.extractall(staging)
        binary = staging / "bin" / executable.name
        if not binary.is_file():
            raise SystemExit("LuaLS archive does not contain its official executable")
        (staging / marker.name).write_text(json.dumps({"version": LUA_VERSION, "sha256": expected}) + "\n")
        if target.exists():
            backup = target.with_name(target.name + "-previous")
            if backup.exists():
                raise SystemExit("Previous LuaLS backup exists; inspect before replacing it: " + str(backup))
            target.rename(backup)
        staging.rename(target)
    print("Provisioned LuaLS:", executable)


def install_go(data):
    binary_dir = data / "tools/languages/bin"
    binary_dir.mkdir(parents=True, exist_ok=True)
    env = os.environ.copy()
    env["GOBIN"] = str(binary_dir)
    env["GOTOOLCHAIN"] = "local"
    for name, module, version in (
        ("gopls", "golang.org/x/tools/gopls", GOPLS_VERSION),
        ("goimports", "golang.org/x/tools/cmd/goimports", GOIMPORTS_VERSION),
    ):
        binary = binary_dir / (name + (".exe" if os.name == "nt" else ""))
        if binary.is_file():
            metadata = subprocess.run(["go", "version", "-m", str(binary)], capture_output=True, text=True, check=True, timeout=10).stdout
            if version in metadata:
                print(name + " already provisioned:", binary)
                continue
        print("Building official", name, version, flush=True)
        subprocess.run(["go", "install", module + "@" + version], cwd=Path(__file__).resolve().parent, env=env, check=True, timeout=600)
        subprocess.run(["go", "version", "-m", str(binary)], check=True, timeout=10)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--data", required=True, type=Path)
    parser.add_argument("--lua", action="store_true")
    parser.add_argument("--go", action="store_true")
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args()
    if not args.lua and not args.go:
        parser.error("Select --lua and/or --go")
    if not args.apply:
        print(f"Preview: LuaLS={LUA_VERSION if args.lua else 'unchanged'}; gopls={GOPLS_VERSION if args.go else 'unchanged'}; data={args.data.resolve()}")
        return
    data = args.data.expanduser().resolve()
    if args.lua:
        install_lua(data)
    if args.go:
        install_go(data)


if __name__ == "__main__":
    main()
