{
  description = "Reusable Nix development environments (devShells) and builders (lib)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      # Import all devshells from ./devshells
      devshells = import ./devshells { inherit nixpkgs systems; };

      # Reusable builders (functions, not finished derivations).
      mkPythonApp = import ./lib/mkPythonApp.nix { inherit nixpkgs; };
      mkDevShell = import ./lib/mkDevShell.nix;
      mkUvShell = import ./lib/mkUvShell.nix;
    in
    {
      # Expose all reusable devShells
      devShells = devshells;

      # Expose reusable library functions
      # mkDevShell / mkUvShell are exported so a downstream flake can compose
      # a shell (its own packages and `flake-help` entries) rather than
      # overrideAttrs-ing a finished one.
      lib = {
        inherit mkPythonApp mkDevShell mkUvShell;
      };

      # `nix fmt` — format the whole tree (treefmt + nixfmt). `nix fmt -- --ci`
      # checks formatting without writing (used in CI).
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      # Smoke-test the builders against a minimal example app.
      checks = forAllSystems (system: {
        mkPythonApp-example =
          (mkPythonApp {
            pname = "example-app";
            src = ./examples/python-app;
            systems = [ system ];
          }).packages.${system}.default;
      });
    };
}
