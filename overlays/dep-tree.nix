importName: inputs: let
  overlay = self: super: (let
  in {
    dep-tree = self.buildGoModule (let
      # testDeps = {
      #   react-stl-viewer = self.fetchFromGitHub {
      #     owner = "gabotechs";
      #     repo = "react-stl-viewer";
      #     rev = "2.2.4";
      #     sha256 = "sha256-0u9q0UgOn43PE1Y6BUhl1l6RnVjpPraFqZWB+HhQ0s8=";
      #   };
      #
      #   react-gcode-viewer = self.fetchFromGitHub {
      #     owner = "gabotechs";
      #     repo = "react-gcode-viewer";
      #     rev = "2.2.4";
      #     sha256 = "sha256-76ib8KMjTS2iUOwkQYCsoeL3GwBaA/MRQU2eGjJEpOo=";
      #   };
      #
      #   graphql-js = self.fetchFromGitHub {
      #     owner = "graphql";
      #     repo = "graphql-js";
      #     rev = "v17.0.0-alpha.2";
      #     sha256 = "sha256-76ib8KMjTS2iUOwkQYCsoeL3GwBaA/MRQU2eGjJEpOo=";
      #   };
      #
      #   warp = self.fetchFromGitHub {
      #     owner = "seanmonstar";
      #     repo = "warp";
      #     rev = "v0.3.3";
      #     sha256 = "sha256-76ib8KMjTS2iUOwkQYCsoeL3GwBaA/MRQU2eGjJEpOo=";
      #   };
      # };
      # depscommands = builtins.mapAttrs (name: value: "mkdir -p /tmp/dep-tree-tests/${name}; cp -rv ${value.outPath}/* /tmp/dep-tree-tests/${name};") testDeps;
      # depscommandsjoined = builtins.concatStringsSep "\n" (builtins.attrValues depscommands);
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
      checkFlags = [ "-skip=TestTui" ];
      # this does in fact show the expected copies taking place
      # but go's os.Stat still cant find them.
      # preCheck = ''
      #   ${depscommandsjoined}
      #   ls -la /tmp/dep-tree-tests
      # '';
    });
  });
in
overlay
