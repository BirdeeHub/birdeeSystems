{
  description = "A basic gomod2nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    gomod2nix.url = "github:nix-community/gomod2nix";
    gomod2nix.inputs.nixpkgs.follows = "nixpkgs";
    gomod2nix.inputs.flake-utils.follows = "flake-utils";
    templ.url = "github:a-h/templ";
    templ.inputs.nixpkgs.follows = "nixpkgs";
    templ.inputs.gomod2nix.follows = "gomod2nix";
    htmx = {
      url = "github:bigskysoftware/htmx";
      flake = false;
    };
    hyperscript = {
      url = "github:bigskysoftware/_hyperscript";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, gomod2nix, ... }@inputs: let
    forEachSystem = flake-utils.lib.eachSystem inputs.flake-utils.lib.allSystems;
  in
  forEachSystem (system: let
    pkgs = nixpkgs.legacyPackages.${system};

    # The current default sdk for macOS fails to compile go projects, so we use a newer one for now.
    # This has no effect on other platforms.
    callPackage = pkgs.darwin.apple_sdk_11_0.callPackage or pkgs.callPackage;

    APPNAME = "REPLACE_ME";

    # NOTE: the program
    default = callPackage ./. {
      inherit (gomod2nix.legacyPackages.${system}) buildGoApplication;
      inherit inputs APPNAME;
    };
    # NOTE: the build environment
    devShellDefault = callPackage ./shell.nix {
      inherit (gomod2nix.legacyPackages.${system}) mkGoEnv gomod2nix;
      inherit inputs APPNAME;
    };

    /*NOTE:
      commands to build, load, and run with published port and persistent volume:
      nix build .#docker.x86_64-linux.default
      # (on zsh remember to escape #) then:
      docker load < ./result
      docker run -p 8080:8080 --mount source=foodvol,target=/var/db/foodb --rm birdee.io/foodbar
    */
    WhaleJail = pkgs.dockerTools.buildLayeredImage {
      name = "birdee.io/${APPNAME}";
      tag = "latest";
      # contents = with pkgs; [
      #   cacert
      # ];

      enableFakechroot = true;
      fakeRootCommands = ''
        #!${pkgs.bash}/bin/bash
        mkdir -p /data/db
        chown -R 1000:1000 /data/db
      '';
      config = {
        User = "1000:1000";
        Cmd = [
          "${default}/bin/${APPNAME}"
          "-more"
          "-flags"
        ];
        ExposedPorts = { "8080/tcp" = {}; };
        Volumes = { "/data" = {}; };
        ReadonlyRootfs = true;
        CapDrop = [
          "ALL"
        ];
        CapAdd = [
          "NET_BIND_SERVICE"
        ];
      };
    };

  in
  {
    docker.default = WhaleJail;
    packages = {
      default = default;
      rundocker = pkgs.writeShellScript "dockerloadmountandrun" ''
        ${pkgs.docker}/bin/docker load < ${WhaleJail}
        ${pkgs.docker}/bin/docker run -p $1:8080 --mount source=${APPNAME}vol,target=/var/db/${APPNAME}db --rm birdee.io/${APPNAME}
      '';
    };
    devShells.default = devShellDefault;
  }) ;
}
