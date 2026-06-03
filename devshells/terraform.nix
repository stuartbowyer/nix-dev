{ nixpkgs, systems }:

let
  forAllSystems = nixpkgs.lib.genAttrs systems;
  mkDevShell = import ../lib/mkDevShell.nix;
in
forAllSystems (
  system:
  let
    # terraform is unfree (BSL), so import nixpkgs with allowUnfree rather than
    # using legacyPackages (which has the default, restrictive config).
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in
  {
    terraform = mkDevShell {
      inherit pkgs;
      name = "terraform-env-${system}";
      description = "Base Terraform / IaC dev shell (extend with a cloud CLI via overrideAttrs)";
      packages = with pkgs; [
        terraform
        pre-commit
        jq
      ];
      shellHook = ''
        export EDITOR="code --wait"
      '';
    };
  }
)
