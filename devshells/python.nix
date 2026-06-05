{ nixpkgs, systems }:

let
  forAllSystems = nixpkgs.lib.genAttrs systems;
  mkUvShell = import ../lib/mkUvShell.nix;

  # Add a Python version by adding its nixpkgs attr name here; it becomes a
  # devShell of the same name (e.g. `python313`).
  pythons = [
    "python311"
    "python312"
  ];
in
forAllSystems (
  system:
  let
    pkgs = nixpkgs.legacyPackages.${system};
  in
  nixpkgs.lib.genAttrs pythons (
    p:
    mkUvShell {
      inherit pkgs;
      name = "${p}-env-${system}";
      python = pkgs.${p};
      description = "Generic ${p} dev shell with uv-managed .venv";
    }
  )
)
