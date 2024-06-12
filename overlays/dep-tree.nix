importName: inputs: let
  overlay = self: super: (let
    dep-tree-pkg = {lib, stdenv, fetchFromGitHub, writeText, buildGoModule, linkFarm, ... }:
      buildGoModule (let
        testDeps = {
          react-stl-viewer = fetchFromGitHub {
            owner = "gabotechs";
            repo = "react-stl-viewer";
            rev = "2.2.4";
            sha256 = "sha256-0u9q0UgOn43PE1Y6BUhl1l6RnVjpPraFqZWB+HhQ0s8=";
          };

          react-gcode-viewer = fetchFromGitHub {
            owner = "gabotechs";
            repo = "react-gcode-viewer";
            rev = "2.2.4";
            sha256 = "sha256-FHBICLdy0k4j3pPKStg+nkIktMpKS1ADa4m1vYHJ+AQ=";
          };

          graphql-js = fetchFromGitHub {
            owner = "graphql";
            repo = "graphql-js";
            rev = "v17.0.0-alpha.2";
            sha256 = "sha256-y55SNiMivL7bRsjLEIpsKKyaluI4sXhREpiB6A5jfDU=";
          };

          warp = fetchFromGitHub {
            owner = "seanmonstar";
            repo = "warp";
            rev = "v0.3.3";
            sha256 = "sha256-76ib8KMjTS2iUOwkQYCsoeL3GwBaA/MRQU2eGjJEpOo=";
          };
        };
        testFarm = linkFarm "dep-tree_testDepsFarm"
            (builtins.attrValues
              (builtins.mapAttrs (name: value: { name = name; path = value; }) testDeps));
      in rec {
        pname = "dep-tree";
        version = "0.20.3";

        src = fetchFromGitHub {
          repo = pname;
          owner = "gabotechs";
          rev = "v${version}";
          sha256 = "sha256-w0t6SF0Kqr+XAKPNJpDJGDTm2Tc6J9OzbXtRUNkqp2k=";
        };

        vendorHash = "sha256-ZDADo1takCemPGYySLwPAODUF+mEJXsaxZn4WWmaUR8=";
        doCheck = true;
        # TestTui downloads 4 different repos to /tmp/dep-tree-tests/<reponame>
        # I fixed them instead of skipping the offending tests
        # checkFlags = [ "-skip=TestTui" ];
        preCheck = ''
          substituteInPlace internal/tui/tui_test.go \
            --replace-fail /tmp/dep-tree-tests ${testFarm}
        '';
        meta = {
          description = "A tool for visualizing interconnectedness of codebases in multiple languages.";
          longDescription = ''
            dep-tree is a tool for interactively visualizing the complexity of a code base.
            It helps analyze the interconnectedness of the codebase and create goals to improve maintainability.
          '';
          homepage = "https://github.com/gabotechs/dep-tree";
          changelog = "https://github.com/gabotechs/dep-tree/releases/tag/v${version}";
          license = lib.licenses.mit;
          platforms = lib.platforms.all;
          mainProgram = "dep-tree";
        };
      });
  in {
    dep-tree = self.callPackage dep-tree-pkg {};
  });
in
overlay
