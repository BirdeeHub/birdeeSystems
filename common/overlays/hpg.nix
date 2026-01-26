# call with pkgs.callPackage
let
  pname = "hpg";
in {
  lib,
  pkg-config,
  cmake,
  hdf5,
  kokkos,
  fftw,
  cudatoolkit,
  fetchFromGitLab,
  stdenv,
  # can also come from flake input
  hpg-src ? fetchFromGitLab {
    repo = pname;
    group = "dsa-2000";
    rev = "main";
    owner = "rcp";
    hash = "sha256-tJl/eufKv1z0Hig+zvdi+xykjuPSCCW1SgzsibthcwY=";
  },
  ...
}:
let
in
stdenv.mkDerivation {
  version = "main";
  inherit pname;
  src = hpg-src;
  nativeBuildInputs = [ pkg-config cmake hdf5.bin hdf5.dev kokkos fftw cudatoolkit ];
  cmakeFlags = [
    "-DHDF5_DIR=${hdf5.dev}/lib/cmake"
    "-DHDF5_TOOLS_DIR=${hdf5.bin}/bin"
  ];
  meta = {
    mainProgram = pname;
  };
}
