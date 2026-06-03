{ nixpkgs, systems }:

let
  forAllSystems = nixpkgs.lib.genAttrs systems;
in
forAllSystems (system:
  let
    # terraform is unfree (BSL), so import nixpkgs with allowUnfree rather than
    # using legacyPackages (which has the default, restrictive config).
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in
  {
    terraform = pkgs.mkShellNoCC {
      name = "terraform-env-${system}";
      meta.description = "Base Terraform / IaC dev shell (extend with a cloud CLI via overrideAttrs)";

      packages = with pkgs; [
        zsh
        git
        terraform
        pre-commit
        jq
      ];

      shellHook = ''
        export SHELL=${pkgs.zsh}/bin/zsh
        export EDITOR="code --wait"

        # Only exec into zsh once per session
        if [ -t 1 ] && [ -z "$IN_ZSH" ]; then
          export IN_ZSH=1
          exec ${pkgs.zsh}/bin/zsh
        fi
      '';
    };
  })
