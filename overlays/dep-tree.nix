importName: inputs: let
  overlay = self: super: (let
  in {
    dep-tree = self.buildGoModule (let
      testDeps = {
        react-stl-viewer = self.fetchFromGitHub {
          owner = "gabotechs";
          repo = "react-stl-viewer";
          rev = "2.2.4";
          sha256 = "sha256-0u9q0UgOn43PE1Y6BUhl1l6RnVjpPraFqZWB+HhQ0s8=";
        };

        react-gcode-viewer = self.fetchFromGitHub {
          owner = "gabotechs";
          repo = "react-gcode-viewer";
          rev = "2.2.4";
          sha256 = "sha256-FHBICLdy0k4j3pPKStg+nkIktMpKS1ADa4m1vYHJ+AQ=";
        };

        graphql-js = self.fetchFromGitHub {
          owner = "graphql";
          repo = "graphql-js";
          rev = "v17.0.0-alpha.2";
          sha256 = "sha256-y55SNiMivL7bRsjLEIpsKKyaluI4sXhREpiB6A5jfDU=";
        };

        warp = self.fetchFromGitHub {
          owner = "seanmonstar";
          repo = "warp";
          rev = "v0.3.3";
          sha256 = "sha256-76ib8KMjTS2iUOwkQYCsoeL3GwBaA/MRQU2eGjJEpOo=";
        };
      };
      depscommands = builtins.mapAttrs (name: value: "mkdir -p $out/${name}; cp -rv ${value.outPath}/* $out/${name};") testDeps;
      depscommandsjoined = builtins.concatStringsSep "\n" (builtins.attrValues depscommands);
      depsDRV = self.stdenv.mkDerivation {
        name = "dep-tree_testDeps";
        builder = self.writeText "dep-tree_testDeps" ''
          source $stdenv/setup
          ${depscommandsjoined}
        '';
      };
    in rec {
      pname = "dep-tree";
      version = "0.20.3";

      src = self.fetchFromGitHub {
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
          --replace-fail /tmp/dep-tree-tests ${depsDRV}
      '';
    });
  });
in
overlay
