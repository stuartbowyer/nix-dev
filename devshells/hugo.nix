{ nixpkgs, systems }:

let
  forAllSystems = nixpkgs.lib.genAttrs systems;
  mkDevShell = import ../lib/mkDevShell.nix;
in
forAllSystems (system:
  let
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    hugo = mkDevShell {
      inherit pkgs;
      name = "hugo-env-${system}";
      description = "Static-site dev shell with Hugo";
      packages = [ pkgs.hugo ];
    };
  })
