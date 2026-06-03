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

        if [ ! -d ".venv" ]; then
          # --seed installs pip/setuptools into the venv for tools that shell out to `pip`.
          uv venv --seed .venv
          source .venv/bin/activate
          if [ -f "pyproject.toml" ]; then
            uv pip install -e ".[dev]" || uv pip install -e .
          elif [ -f "requirements.txt" ]; then
            uv pip install -r requirements.txt
          fi
        else
          source .venv/bin/activate
        fi

        if [ -t 1 ] && [ -z "$IN_ZSH" ]; then
          export IN_ZSH=1
          exec ${pkgs.zsh}/bin/zsh
        fi
      '';
    };
  })
