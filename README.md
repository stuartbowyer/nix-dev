# nix-dev

Reusable **Nix Flake Dev Environments** for common toolchains.

## Available DevShells

| Name | Description |
|------|--------------|
| `ansible-k3s` | Ansible, kubectl, FluxCD shell for managing K3s clusters |
| `python311` | Generic Python 3.11 shell with auto-managed `.venv` (runs `uv sync` for `pyproject.toml`, or installs `requirements.txt`) |

## Quick start

Enter a shell directly, without adding anything to your project:

```bash
nix develop "github:stuartbowyer/nix-dev#python311"
nix develop "github:stuartbowyer/nix-dev#ansible-k3s"
```

Or with direnv, add an `.envrc` to your project:

```bash
# .envrc
use flake "github:stuartbowyer/nix-dev#python311"
```

then run `direnv allow`.

## Use in a project flake

Use in another project:

```nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nix-dev.url = "github:stuartbowyer/nix-dev";
  # Share a single nixpkgs so versions stay consistent.
  inputs.nix-dev.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, nix-dev }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-linux" ];
    in
    {
      devShells = forAllSystems (system: {
        default = nix-dev.devShells.${system}.ansible-k3s;
      });
    };
}
```

The `ansible-k3s` shell defaults `KUBECONFIG` to `$PWD/secrets/.kubeconfig` and
`SOPS_AGE_KEY_FILE` to `$PWD/secrets/sops/age/keys.txt`. Override either by
exporting it before entering the shell (e.g. in a project `.envrc`).

## Structure

```
nix-dev/
  flake.nix              # main flake definition
  devshells/             # reusable devShell definitions (auto-discovered)
```

Adding a new shell is just dropping a `devshells/<name>.nix` file that returns
`forAllSystems (system: { <name> = pkgs.mkShellNoCC { ... }; })` — it is picked
up automatically.

## Notes

- The flake supports multiple systems (`aarch64-darwin`, `x86_64-linux`).
- You can extend any shell locally via `overrideAttrs` to add extra packages.
- Each devShell is self-contained and reproducible — no global dependencies.
- `nix flake check` is run in CI on Linux and macOS.
