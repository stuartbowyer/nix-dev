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
      meta.description = "Generic Python 3.11 dev shell with auto-managed .venv";

      packages = [
        python
        pkgs.git
        pkgs.zsh
      ];

      shellHook = ''
        export SHELL=${pkgs.zsh}/bin/zsh

        if [ ! -d ".venv" ]; then
          ${python}/bin/python -m venv .venv
          source .venv/bin/activate
          pip install --upgrade pip
          if [ -f "pyproject.toml" ]; then
            pip install -e ".[dev]" || pip install -e .
          elif [ -f "requirements.txt" ]; then
            pip install -r requirements.txt
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
