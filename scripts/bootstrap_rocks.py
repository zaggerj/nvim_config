#!/usr/bin/env python3
"""Install the repository's isolated Lua/LuaRocks toolchain without disabling TLS.

Used by lazy.nvim's hererocks build hook on Windows and macOS. Downloaded
archives are shared across builds and verified before hererocks consumes them.
"""

from __future__ import annotations

import argparse
import hashlib
import os
import re
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import urllib.error
import urllib.request


LUA_VERSION = "5.1.5"
ROCKS_VERSION = "3.11.1"
TREE_SITTER_VERSION = "0.22.6"  # Generates ABI 14 parsers for Neovim 0.10.
LUA_SHA256 = "2640fc56a795f29d28ef15e13c34a47e223960b0240e8cb0a82d9b0738695333"
ROCKS_REPOSITORY = "https://github.com/luarocks/luarocks"
ROCKS_COMMIT = "fa2736e7c68094710643577b0153dac72ce4bcdc"  # v3.11.1


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def archive(cache: Path, name: str, expected: str, urls: list[str]) -> Path:
    target = cache / name
    if target.is_file() and sha256(target) == expected:
        print(f"Verified cached {name}", flush=True)
        return target
    cache.mkdir(parents=True, exist_ok=True)
    failures = []
    for url in urls:
        # The platform's default trust store and certificate/date checks remain
        # enabled. SHA-256 also makes mirrors equivalent to the upstream archive.
        fd, staged_name = tempfile.mkstemp(prefix=name + ".", suffix=".part", dir=cache)
        staged = Path(staged_name)
        try:
            print(f"Downloading {url}", flush=True)
            with os.fdopen(fd, "wb") as output:
                request = urllib.request.Request(url, headers={"User-Agent": "nvim-config-bootstrap"})
                with urllib.request.urlopen(request, timeout=30) as response:
                    shutil.copyfileobj(response, output)
            observed = sha256(staged)
            if observed != expected:
                raise ValueError(f"SHA-256 mismatch for {name}: {observed}")
            os.replace(staged, target)
            print(f"Verified {name}: {expected}", flush=True)
            return target
        except (OSError, urllib.error.URLError, ValueError) as error:
            failures.append(f"{url}: {error}")
            print(f"Download source failed: {error}", file=sys.stderr, flush=True)
        finally:
            # Only remove the staged file created by this invocation.
            staged.unlink(missing_ok=True)
    raise RuntimeError("No verified download source succeeded:\n" + "\n".join(failures))


def output(argv: list[str], env: dict[str, str]) -> str:
    result = subprocess.run(argv, check=True, env=env, text=True,
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    return result.stdout.strip()


def rocks_source(cache: Path, env: dict[str, str]) -> Path:
    source = cache / f"luarocks-source-{ROCKS_VERSION}"
    if not source.exists():
        # A shallow tag checkout avoids downloading unrelated repository history.
        # The commit check below protects against a moved upstream tag.
        subprocess.run(["git", "clone", "--depth", "1", "--branch", f"v{ROCKS_VERSION}",
                        ROCKS_REPOSITORY, str(source)], check=True, env=env, timeout=180)
    commit = output(["git", "-C", str(source), "rev-parse", "HEAD"], env)
    if commit != ROCKS_COMMIT:
        raise RuntimeError(f"Unexpected LuaRocks source commit in {source}: {commit}")
    return source


def build_environment() -> tuple[dict[str, str], list[str]]:
    env = os.environ.copy()
    if os.name == "nt":
        gcc = shutil.which("gcc", path=env.get("PATH"))
        if gcc:
            shim = Path(gcc).with_suffix(".shim")
            if shim.is_file():
                content = shim.read_text(encoding="utf-8")
                target = re.search(r'path\s*=\s*"([^"]+)"', content)
                if target and not re.search(r'args\s*=', content) and Path(target[1]).is_file():
                    gcc = target[1]
            machine = output([gcc, "-dumpmachine"], env)
            if "mingw" in machine.lower() or "w64" in machine.lower():
                # Ensure ar/ranlib/strip come from the same native toolchain,
                # even when launched inside Git Bash or MSYS2 zsh.
                env["PATH"] = str(Path(gcc).resolve().parent) + os.pathsep + env.get("PATH", "")
                print(f"Native MinGW compiler: {machine}", flush=True)
                return env, ["--target", "mingw"]
        if shutil.which("cl", path=env.get("PATH")):
            return env, ["--target", "vs"]
        raise RuntimeError("Windows needs a native MinGW-w64 GCC toolchain or a Visual Studio developer environment.")
    if not shutil.which("cc") or not shutil.which("make"):
        raise RuntimeError("Install the platform C compiler and make (macOS: xcode-select --install).")
    return env, ["--target", "macosx"] if sys.platform == "darwin" else []


def verify(root: Path, env: dict[str, str]) -> None:
    lua = root / "bin" / ("lua.exe" if os.name == "nt" else "lua")
    rocks = root / "bin" / ("luarocks.bat" if os.name == "nt" else "luarocks")
    version = output([str(lua), "-v"], env)
    if f"Lua {LUA_VERSION}" not in version:
        raise RuntimeError(f"Unexpected Lua runtime: {version}")
    # subprocess uses native Windows command processing for a .bat launcher;
    # the command and arguments remain separate values throughout this script.
    rocks_version = output([str(rocks), "--version"], env)
    if ROCKS_VERSION not in rocks_version:
        raise RuntimeError(f"Unexpected LuaRocks runtime: {rocks_version}")
    print(version, flush=True)
    print(rocks_version, flush=True)


def tree_sitter(data: Path, env: dict[str, str]) -> None:
    """Build the official CLI once; do not depend on npm's download postinstall."""
    root = data / "tools" / "tree-sitter"
    binary = root / "bin" / ("tree-sitter.exe" if os.name == "nt" else "tree-sitter")
    if binary.is_file() and f"tree-sitter {TREE_SITTER_VERSION}" in output([str(binary), "--version"], env):
        return
    cargo = shutil.which("cargo", path=env.get("PATH"))
    if not cargo:
        raise RuntimeError("Building the HTTP parser needs Rust/Cargo (https://rustup.rs). Install it and retry :Lazy build hererocks.")
    subprocess.run([cargo, "install", "tree-sitter-cli", "--version", TREE_SITTER_VERSION,
                    "--locked", "--root", str(root)], env=env, check=True)
    if f"tree-sitter {TREE_SITTER_VERSION}" not in output([str(binary), "--version"], env):
        raise RuntimeError("Unexpected tree-sitter CLI version")


def rest_rocks(data: Path, source: Path, env: dict[str, str]) -> None:
    """Honor the checked-out rockspec, rather than installing the latest release."""
    tools = data / "lazy-rocks" / "hererocks" / "bin"
    env = env.copy()
    env["PATH"] = str(tools) + os.pathsep + str(data / "tools" / "tree-sitter" / "bin") + os.pathsep + env.get("PATH", "")
    rocks = tools / ("luarocks.bat" if os.name == "nt" else "luarocks")
    subprocess.run([str(rocks), "--tree", str(data / "lazy-rocks" / "rest.nvim"),
                    "--lua-version", "5.1", "make", "--deps-mode", "one",
                    "rest.nvim-scm-1.rockspec"], cwd=source, env=env, check=True)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--data", required=True, type=Path, help="Neovim stdpath('data')")
    parser.add_argument("--hererocks", required=True, type=Path, help="Checked-out hererocks plugin directory")
    parser.add_argument("--rest", type=Path, help="Build dependencies from this rest.nvim checkout")
    args = parser.parse_args()
    data = args.data.expanduser().resolve()
    hererocks = args.hererocks.expanduser().resolve()
    entry = hererocks / "hererocks.py"
    if not entry.is_file():
        raise RuntimeError(f"Missing hererocks source: {entry}")
    if not shutil.which("git"):
        raise RuntimeError("Git is required for the pinned official LuaRocks source.")
    cache = data / "bootstrap" / "downloads"
    root = data / "lazy-rocks" / "hererocks"
    env, target_args = build_environment()
    tree_sitter(data, env)
    installed = False
    if (root / "bin" / ("lua.exe" if os.name == "nt" else "lua")).is_file() and (
            root / "bin" / ("luarocks.bat" if os.name == "nt" else "luarocks")).is_file():
        try:
            verify(root, env)
            installed = True
        except (RuntimeError, subprocess.CalledProcessError):
            print("Installed toolchain needs repair; rebuilding pinned versions.", flush=True)
    if installed:
        print("The pinned toolchain is already installed.", flush=True)
        if args.rest:
            rest_rocks(data, args.rest.resolve(), env)
        return
    archive(cache, f"lua-{LUA_VERSION}.tar.gz", LUA_SHA256, [
        f"https://www.lua.org/ftp/lua-{LUA_VERSION}.tar.gz",
        f"https://sources.buildroot.net/lua/lua-{LUA_VERSION}.tar.gz",
    ])
    # The official Git tag also avoids platform-specific release packaging;
    # hererocks supports this source form on both Windows and Unix.
    source = rocks_source(cache, env)
    command = [sys.executable, str(entry), "--verbose", "--no-readline",
               "--downloads", str(cache), "-l", LUA_VERSION, "-r", str(source),
               *target_args, str(root)]
    print(f"Installing isolated toolchain into {root}", flush=True)
    subprocess.run(command, cwd=hererocks, env=env, check=True)
    env["PATH"] = str(root / "bin") + os.pathsep + env.get("PATH", "")
    verify(root, env)
    if args.rest:
        rest_rocks(data, args.rest.resolve(), env)


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError, OSError, subprocess.SubprocessError) as error:
        print(f"Lua toolchain bootstrap failed: {error}", file=sys.stderr)
        sys.exit(1)
