import os
import sys
import subprocess
from pathlib import Path
import shutil
import subprocess

templates_path = Path(TEMPLATES_PATH)

choices = [p.name.replace(".nix", "") for p in templates_path.iterdir() if p.is_file()]

type = sys.argv[1]

if type not in choices:
    proc = subprocess.run(
        ["fzf", "--prompt", "template> "],
        input="\n".join(choices),
        text=True,
        capture_output=True,
    )

    if proc.returncode != 0 or not proc.stdout.strip():
        raise SystemExit("no template selected")

    type = proc.stdout.strip()

    if type not in choices:
        raise SystemExit("no template selected")

selected = templates_path / (type + ".nix")

shutil.copyfile(selected, "devenv.nix")

envrc = Path(".envrc")

envrc.write_text("""
#!/usr/bin/env bash

export DIRENV_WARN_TIMEOUT=20s

eval "$(devenv direnvrc)"

# `use devenv` supports the same options as the `devenv shell` command.
#
# To silence all output, use `--quiet`.
#
# Example usage: use devenv --quiet --impure --option services.postgres.enable:bool true
use devenv                        
""")

envrc.chmod(0o755)

subprocess.run(["direnv", "allow", "."]) 
