{ nixpkgs, systems }:

let
  forAllSystems = nixpkgs.lib.genAttrs systems;
  ansibleK3sShells = import ./ansible-k3s.nix { inherit nixpkgs systems; };
in

forAllSystems (system: {
  ansible-k3s = ansibleK3sShells.${system}.ansible-k3s;
})
