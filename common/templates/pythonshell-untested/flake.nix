{
  # TODO: TRY THIS OUT
  #NOTE: I HAVE NO CLUE IF THIS WORKS BUT IM DOING SOMETHING ELSE RIGHT NOW
  # JUST SAVING THIS FOR LATER TO TRY IT. GOT THIS FROM A REDDIT COMMENT BUT DIDNT BOOKMARK SO IDK WHERE...
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, ... }@inputs: let
    forEachSystem = inputs.flake-utils.lib.eachSystem inputs.flake-utils.lib.allSystems;
  in
  forEachSystem (system: let
    pkgs = import nixpkgs { inherit system; };
    default_package = pkgs.callPackage ./. { inherit inputs; };
  in{
    packages = {
      default = default_package;
    };
    devShells = {
      default = let
        python = pkgs.python312;
        pythonPackages = python.pkgs;
        lib-path = with pkgs; lib.makeLibraryPath [
          libffi
          openssl
          stdenv.cc.cc
        ];
      in with pkgs; mkShell {
        packages = [
          pythonPackages.pydantic
          pythonPackages.psycopg2
          pythonPackages.orjson
          pythonPackages.sqlalchemy
          pythonPackages.uvicorn
          pythonPackages.fastapi
          pythonPackages.venvShellHook
        ];

        buildInputs = [
          readline
          libffi
          openssl
          git
          openssh
          rsync
        ];

        shellHook = ''
          SOURCE_DATE_EPOCH=$(date +%s)
          export "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${lib-path}"
          VENV=.venv

          if test ! -d $VENV; then
            python3.12 -m venv $VENV
          fi
          source ./$VENV/bin/activate
          export PYTHONPATH=`pwd`/$VENV/${python.sitePackages}/:$PYTHONPATH
          pip install -r requirements.txt
        '';

        postShellHook = ''
          ln -sf ${python.sitePackages}/* ./.venv/lib/python3.12/site-packages
        '';
      };
    };
  });
}

