# Builder for a pure-nix Python application: packages a `buildPythonApplication`
# plus a matching `nix run` app and a `python.withPackages` dev shell.
#
# Dependencies are resolved from nixpkgs (not pip), so every dep must exist in
# nixpkgs. For PyPI-only deps, use the uv-based `python311` devShell instead.
#
# Returns full flake outputs ({ packages, apps, devShells }) keyed by system,
# defaulting to aarch64-darwin. Compose extra outputs with `//` if needed.
{ nixpkgs }:

{
  pname,
  src,
  version ? "0.1.0",
  deps ? (ps: [ ]), # runtime dependencies (ps == python.pkgs)
  devDeps ? (ps: [ ]), # extra dev/test-only python packages
  devPackages ? (pkgs: [ ]), # extra non-python dev tools (e.g. nodejs)
  program ? pname, # binary name exposed as apps.default
  python ? null, # defaults to nixpkgs python312
  systems ? [ "aarch64-darwin" ],
}:

let
  forSystems = nixpkgs.lib.genAttrs systems;

  perSystem =
    system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      py = if python == null then pkgs.python312 else python;

      app = py.pkgs.buildPythonApplication {
        inherit pname version src;
        pyproject = true;
        build-system = [ py.pkgs.hatchling ];
        dependencies = deps py.pkgs;
        doCheck = false;
      };

      devEnv = py.withPackages (ps: deps ps ++ devDeps ps);
    in
    {
      package = app;
      app = {
        type = "app";
        program = "${app}/bin/${program}";
      };
      devShell = pkgs.mkShell {
        packages = [ devEnv ] ++ devPackages pkgs;
        shellHook = ''
          export PYTHONPATH="$PWD/src:$PYTHONPATH"
          # Banner to stderr — stdout may be reserved for protocol output.
          echo "${pname} dev shell — python $(python --version)" 1>&2
        '';
      };
    };

  built = forSystems perSystem;
in
{
  packages = forSystems (s: {
    default = built.${s}.package;
  });
  apps = forSystems (s: {
    default = built.${s}.app;
  });
  devShells = forSystems (s: {
    default = built.${s}.devShell;
  });
}
