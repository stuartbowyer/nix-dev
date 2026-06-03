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
    ansible-k3s = mkDevShell {
      inherit pkgs;
      name = "ansible-k3s-env-${system}";
      description = "Development shell for managing K3s clusters with Ansible and FluxCD";
      packages = with pkgs; [ ansible kubectl fluxcd age sops ];
      shellHook = ''
        # Default kubeconfig / sops age key paths; override by exporting these
        # before entering the shell (e.g. in a project .envrc).
        export KUBECONFIG="''${KUBECONFIG:-$PWD/secrets/.kubeconfig}"
        export SOPS_AGE_KEY_FILE="''${SOPS_AGE_KEY_FILE:-$PWD/secrets/sops/age/keys.txt}"
        export EDITOR="code --wait"
      '';
    };
  })
