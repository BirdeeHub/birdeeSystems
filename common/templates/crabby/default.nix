{ APPNAME
, rustPlatform
, ...
# override overrides these args
}: let
APPDRV = rustPlatform.buildRustPackage {
  pname = APPNAME;
  version = "0.0.0";
  src = ./.;

  cargoLock = {
    cargoLock.lockFile = ./Cargo.lock;
  };

};
in
APPDRV
