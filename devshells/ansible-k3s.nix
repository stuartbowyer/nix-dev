{ nixpkgs, systems }:

let
  forAllSystems = nixpkgs.lib.genAttrs systems;
in
forAllSystems (system:
  let
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    ansible-k3s = pkgs.mkShellNoCC {
      name = "ansible-k3s-env-${system}";
      meta.description = "Development shell for managing K3s clusters with Ansible and FluxCD";

      packages = with pkgs; [
        zsh
        git
        ansible
        kubectl
        fluxcd
      ];

      shellHook = ''
        # Use zsh as the default interactive shell
        export SHELL=${pkgs.zsh}/bin/zsh

        # Point kubectl to local playbook config
        export KUBECONFIG="$PWD/playbooks/.kubeconfig"

        # Only exec into zsh once per session
        if [ -t 1 ] && [ -z "$IN_ZSH" ]; then
          export IN_ZSH=1
          exec ${pkgs.zsh}/bin/zsh
        fi
      '';
    };
  })
