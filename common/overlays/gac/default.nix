importName: inputs:
(
  self: super:
  let
    workspace = inputs.uv2nix.lib.workspace.loadWorkspace { workspaceRoot = inputs.gac-src; };
    overlay = workspace.mkPyprojectOverlay {
      sourcePreference = "wheel";
      dependencies = workspace.deps.all;
    };
    pythonSets =
      (self.callPackage inputs.pyproject-nix.build.packages {
        python = self.python3;
      }).overrideScope
        (
          self.lib.composeManyExtensions [
            inputs.pyproject-build-systems.overlays.wheel
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
    gac = pythonSets.mkVirtualEnv "gac-env" workspace.deps.default;
  }
)
