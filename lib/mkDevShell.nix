# Internal helper: wraps mkShellNoCC with the zsh behaviour shared by every
# devShell — zsh + git on PATH, SHELL set, and a one-shot `exec zsh` for
# interactive sessions. Each shell only declares what is unique to it.
{ pkgs, name, description ? "", packages ? [ ], shellHook ? "" }:

pkgs.mkShellNoCC {
  inherit name;
  meta.description = description;

  packages = [ pkgs.zsh pkgs.git ] ++ packages;

  shellHook = ''
    export SHELL=${pkgs.zsh}/bin/zsh

    ${shellHook}

    # Only exec into zsh once per session
    if [ -t 1 ] && [ -z "$IN_ZSH" ]; then
      export IN_ZSH=1
      exec ${pkgs.zsh}/bin/zsh
    fi
  '';
}
