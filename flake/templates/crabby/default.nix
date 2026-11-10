{ APPNAME
, rustPlatform
, ...
}: let
APPDRV = rustPlatform.buildRustPackage {
  pname = APPNAME;
  version = "0.0.0";
  src = ./.;
  # needed to use 2024 edition due to outdated cargo-auditable dependency in toolchain
  auditable = false;

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

};
in
APPDRV
