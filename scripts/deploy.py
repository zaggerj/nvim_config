"""Preview or copy an existing Coc installation into Neovim's canonical data directory.

python scripts/deploy.py --data <stdpath('data')> --coc-from <old-coc-dir> [--apply]
The old installation is retained. Existing destination installations are never overwritten.
"""
import argparse
import json
from pathlib import Path
import shutil
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--data", required=True, type=Path)
    parser.add_argument("--coc-from", type=Path)
    parser.add_argument("--bootstrap-lazy", action="store_true", help="Explicitly install the locked lazy.nvim checkout")
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args()
    repository = Path(__file__).resolve().parent.parent
    data = args.data.expanduser().resolve()
    if args.bootstrap_lazy:
        lazy = data / "lazy" / "lazy.nvim"
        if lazy.is_dir():
            print(f"lazy.nvim already present: {lazy}; use :Lazy restore for version changes")
        elif not args.apply:
            print(f"Would install locked lazy.nvim into {lazy}")
        else:
            lock = json.loads((repository / "lazy-lock.json").read_text(encoding="utf-8"))
            subprocess.run(["git", "clone", "--filter=blob:none", "--no-checkout",
                            "https://github.com/folke/lazy.nvim.git", str(lazy)], check=True, timeout=180)
            subprocess.run(["git", "-C", str(lazy), "checkout", "--detach", lock["lazy.nvim"]["commit"]],
                           check=True, timeout=90)
    if not args.coc_from:
        if not args.bootstrap_lazy:
            parser.error("Specify --coc-from or --bootstrap-lazy")
        return
    source = args.coc_from.expanduser().resolve()
    destination = data / "coc"
    marker = data / "coc-deploy-incomplete"
    manifest = json.loads((repository / "coc-extensions.json").read_text(encoding="utf-8"))
    if source == destination:
        raise SystemExit("Source and destination must differ")
    if not (source / "extensions" / "package.json").is_file():
        raise SystemExit("Source is not a Coc data directory")
    print(f"Coc source: {source}\nCanonical destination: {destination}")
    if destination.exists():
        if marker.exists():
            raise SystemExit("Previous deployment is incomplete; preserve and inspect the destination before retrying")
        metadata = destination / "extensions" / "package.json"
        state = json.loads(metadata.read_text(encoding="utf-8"))
        if set(manifest["retired"]) <= set(state.get("disabled", [])):
            print("Canonical Coc installation already deployed; no files changed")
            return
        raise SystemExit("Destination already exists with different extension policy; inspect before changing it")
    if not args.apply:
        print("Preview only; add --apply to copy. The source will be retained.")
        return
    destination.parent.mkdir(parents=True, exist_ok=True)
    # A marker prevents a partial copy from being mistaken for a complete deployment.
    marker.write_text(str(source), encoding="utf-8")
    shutil.copytree(source, destination)
    metadata = destination / "extensions" / "package.json"
    state = json.loads(metadata.read_text(encoding="utf-8"))
    disabled = set(state.get("disabled", [])) | set(manifest["retired"])
    state["disabled"] = sorted(disabled)
    metadata.write_text(json.dumps(state, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    marker.unlink()
    print("Copied Coc state; retired extensions are disabled. Original files retained.")


if __name__ == "__main__":
    main()
