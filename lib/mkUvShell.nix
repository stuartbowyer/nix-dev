# Internal helper: a uv-managed Python dev shell for a given interpreter.
# Shares the common zsh behaviour via mkDevShell; on entry it syncs .venv from
# pyproject.toml (uv.lock-respecting) or requirements.txt.
{
  pkgs,
  python,
  name,
  description ? "",
}:

import ./mkDevShell.nix {
  inherit pkgs name description;
  packages = [
    python
    pkgs.uv
  ];
  shellHook = ''
    # Let uv use the Nix-provided interpreter rather than downloading its own.
    export UV_PYTHON="${python}/bin/python"
    export UV_PYTHON_DOWNLOADS=never

    if [ -f "pyproject.toml" ]; then
      # uv sync respects uv.lock and is idempotent, so run it on every entry
      # to pick up dependency changes. It creates/updates .venv as needed.
      uv sync
    elif [ -f "requirements.txt" ]; then
      # --seed installs pip/setuptools for tools that shell out to `pip`.
      [ -d ".venv" ] || uv venv --seed .venv
      uv pip install -r requirements.txt
    else
      [ -d ".venv" ] || uv venv --seed .venv
    fi
    source .venv/bin/activate
  '';
}
