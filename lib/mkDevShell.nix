# Internal helper: wraps mkShellNoCC with the zsh behaviour shared by every
# devShell — zsh + git on PATH, SHELL set, and a one-shot `exec zsh` for
# interactive sessions. Each shell only declares what is unique to it.
#
# `commands` is the shell's self-documentation: a list of { name, summary }
# rendered by the `flake-help` command, which every shell gets. Downstream
# flakes extending a shell should append their own entries so one command
# answers "what can I run here?".
{
  pkgs,
  name,
  description ? "",
  packages ? [ ],
  commands ? [ ],
  shellHook ? "",
}:

let
  inherit (pkgs) lib;

  # Deliberately not called `help`: that is a bash builtin, so it would be
  # shadowed wherever a shell script (a project .envrc included) tries to run
  # it. zsh has no such builtin, which is what made the clash easy to miss.
  entries = commands ++ [
    {
      name = "flake-help";
      summary = "print this";
    }
  ];

  line =
    c: "printf '  %-18s %s\\n' ${lib.escapeShellArg c.name} ${lib.escapeShellArg (c.summary or "")}";

  flakeHelp = pkgs.writeShellApplication {
    name = "flake-help";
    text = ''
      echo
      ${lib.optionalString (description != "") "echo ${lib.escapeShellArg description}\n      echo"}
      ${lib.concatMapStringsSep "\n      " line entries}
      echo
    '';
  };
in
pkgs.mkShellNoCC {
  inherit name;
  meta.description = description;

  packages = [
    pkgs.zsh
    pkgs.git
    flakeHelp
  ]
  ++ packages;

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
