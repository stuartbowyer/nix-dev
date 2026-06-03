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
    in
    {
      # Expose all reusable devShells
      devShells = devshells;

      # Expose reusable library functions
      lib = { inherit mkPythonApp; };

      # `nix fmt` — format all Nix files with the community standard.
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

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
