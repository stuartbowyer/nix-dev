{
  description = "Reusable Nix development environments (devShells)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "aarch64-darwin" "x86_64-linux" ];

      # Import all devshells from ./devshells
      devshells = import ./devshells { inherit nixpkgs systems; };
    in
    {
      # Expose all reusable devShells
      devShells = devshells;
    };
}
