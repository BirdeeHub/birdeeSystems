{
  inputs = {
    gradle2nix.url = "github:tadfisher/gradle2nix/v2";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, ... }@inputs: let
      forEachSystem = inputs.flake-utils.lib.eachSystem inputs.flake-utils.lib.allSystems;
  in forEachSystem (system: let
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    defaultPackage = inputs.gradle2nix.builders.${system}.buildGradlePackage {
      pname = "myProgram";
      version = "1.0";
      src = ./.;
      lockFile = ./gradle.lock;
      gradleFlags = [ "installDist" ];
    };
  in {
    packages.default = defaultPackage;
    devShells = {
      default = pkgs.mkShell {
        name = "gradle2nix";
        packages = [ inputs.gradle2nix.packages.${system}.gradle2nix ];
        inputsFrom = [ ];
        GRADLE_HOME = "${pkgs.gradle}";
        JAVA_HOME = "${pkgs.jdk}";
        DEVSHELL = 0;
        shellHook = ''
          exec ${pkgs.zsh}/bin/zsh
        '';
      };
    };
  });
}
