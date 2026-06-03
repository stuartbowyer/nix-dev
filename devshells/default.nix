{ nixpkgs, systems }:

let
  inherit (nixpkgs) lib;
  forAllSystems = lib.genAttrs systems;

  # Auto-discover every devshell module in this directory (except this file).
  shellFiles = lib.filterAttrs (
    name: type: type == "regular" && name != "default.nix" && lib.hasSuffix ".nix" name
  ) (builtins.readDir ./.);

  shellModules = lib.mapAttrsToList (
    name: _: import (./. + "/${name}") { inherit nixpkgs systems; }
  ) shellFiles;
in
# Each module is `forAllSystems (system: { <name> = derivation; })`; merge them.
forAllSystems (system: lib.foldl' (acc: mod: acc // mod.${system}) { } shellModules)
