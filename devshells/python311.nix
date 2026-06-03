{ nixpkgs, systems }:

let
  forAllSystems = nixpkgs.lib.genAttrs systems;
in
forAllSystems (system:
  let
    pkgs = nixpkgs.legacyPackages.${system};
    python = pkgs.python311;
  in
  {
    python311 = pkgs.mkShellNoCC {
      name = "python311-env-${system}";
      meta.description = "Generic Python 3.11 dev shell with uv-managed .venv";

      packages = [
        python
        pkgs.uv
        pkgs.git
        pkgs.zsh
      ];

      shellHook = ''
        export SHELL=${pkgs.zsh}/bin/zsh

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

        if [ -t 1 ] && [ -z "$IN_ZSH" ]; then
          export IN_ZSH=1
          exec ${pkgs.zsh}/bin/zsh
        fi
      '';
    };
  })
