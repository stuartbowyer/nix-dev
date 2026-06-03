# nix-dev

Reusable **Nix Flake Dev Environments** for common toolchains.

## Available DevShells

| Name | Description |
|------|--------------|
| `ansible-k3s` | Ansible, kubectl, FluxCD shell for managing K3s clusters |
| `python311` | Generic Python 3.11 shell with auto-managed `.venv` (runs `uv sync` for `pyproject.toml`, or installs `requirements.txt`) |
| `terraform` | Base Terraform / IaC shell (terraform, pre-commit, jq). Add a cloud CLI via `overrideAttrs` |

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

## Use in a project

There are two ways to consume a shell. Both keep tool versions identical across
every project, because in both cases **nix-dev's pinned nixpkgs is the source of
truth** — do *not* add `nix-dev.inputs.nixpkgs.follows`, which would let each
project's own nixpkgs override the pin and drift apart.

### 1. As-is — point direnv straight at it (no local flake)

If a project just needs a shell unchanged, skip the flake entirely:

```bash
# .envrc
use flake "github:stuartbowyer/nix-dev#terraform"
```

(or run `nix develop "github:stuartbowyer/nix-dev#terraform"` ad hoc). The repo
keeps no `flake.lock`, so it always tracks nix-dev's current pin.

### 2. Add tools — wrap it in a thin flake

When a project needs to *extend* a shell, take a single `nix-dev` input, reuse
nix-dev's nixpkgs, and `overrideAttrs` to append packages:

```nix
{
  inputs.nix-dev.url = "github:stuartbowyer/nix-dev";

  outputs = { nix-dev, ... }:
    let
      nixpkgs = nix-dev.inputs.nixpkgs; # nix-dev's pinned nixpkgs
      forAllSystems = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-linux" ];
    in
    {
      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system}; in
        {
          default = nix-dev.devShells.${system}.terraform.overrideAttrs (old: {
            # mkShell puts `packages` into nativeBuildInputs.
            nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.google-cloud-sdk ];
          });
        });
    };
}
```

(Use `nixpkgs.legacyPackages.${system}` unless an extra is unfree, in which case
`import nixpkgs { inherit system; config.allowUnfree = true; }`.)

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
