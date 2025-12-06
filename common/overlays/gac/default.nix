importName: { uv2nix, pyproject-nix, pyproject-build-systems, gac-src, ... }:
(
  self: _super:
  let
    workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = gac-src; };
    overlay = workspace.mkPyprojectOverlay {
      sourcePreference = "wheel";
      dependencies = workspace.deps.all;
    };
    pythonSet =
      (self.callPackage pyproject-nix.build.packages {
        python = self.python3;
      }).overrideScope
        (
          self.lib.composeManyExtensions [
            pyproject-build-systems.overlays.wheel
            overlay
            (final: prev: {
              halo = prev.halo.overrideAttrs (old: {
                nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
                  (final.resolveBuildSystem { setuptools = []; })
                ];
              });
            })
          ]
        );
  in
  {
    # gotta get gac from the venv
    # but not python3 and other stuff that causes path collision.
    gac = (self.callPackages pyproject-nix.build.util { }).mkApplication {
      venv = pythonSet.mkVirtualEnv "gac-env" workspace.deps.default;
      package = pythonSet.gac;
    };
  }
)
