{ APPNAME
, rustPlatform
, ...
# override overrides these args
}: let
APPDRV = rustPlatform.buildRustPackage {
  pname = APPNAME;
  version = "0.0.0";
  src = ./.;

  cargoLock = let
    fixupLockFile = path: (builtins.readFile path);
  in {
    lockFileContents = fixupLockFile ./Cargo.lock;
  };

};
in
APPDRV
