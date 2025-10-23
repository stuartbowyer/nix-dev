{
  description = "Ansible + K3s + FluxCD project using nix-dev shared devShell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-dev.url = "github:stuartbowyer/nix-dev";
  };

  outputs = { self, nixpkgs, nix-dev }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in
    {
      devShells = forAllSystems (system: {
        default = nix-dev.devShells.${system}.ansible-k3s;
      });

      # Metadata for flake show
      meta = {
        maintainers = [ "stuartbowyer" ];
        description = "Development environment for K3s automation with Ansible & FluxCD.";
      };
    };
}
