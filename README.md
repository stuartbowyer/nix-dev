# nix-dev

Reusable **Nix Flake Dev Environments** for common toolchains.

## Available DevShells

| Name | Description |
|------|--------------|
| `ansible-k3s` | Ansible, kubectl, FluxCD shell for managing K3s clusters |

Use in another project:

```nix
inputs.nix-dev.url = "github:stuartbowyer/nix-dev";
devShells.${system}.default = nix-dev.devShells.ansible-k3s.${system};
```

Or start a new project directly:

```bash
nix flake init -t github:stuartbowyer/nix-dev#ansible-k3s
```

## Structure

```
nix-dev/
  flake.nix              # main flake definition
  devshells/             # reusable devShell definitions
  templates/             # project templates using those shells
```

## Notes

- The flake supports multiple systems (`aarch64-darwin`, `x86_64-linux`).
- You can extend any shell locally via `overrideAttrs` to add extra packages.
- Each devShell is self-contained and reproducible — no global dependencies.
