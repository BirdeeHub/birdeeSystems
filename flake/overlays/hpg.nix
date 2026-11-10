{
  lib,
  cmake,
  fetchFromGitLab,
  stdenv,
  gtest,
  hdf5-cpp,
  hpg-src ? null,
  kokkos4,
  fftw,
  cudaPackages,
  cudatoolkit,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "hpg";
  version = "3.4.1";
  src =
    if hpg-src != null then
      hpg-src
    else
      fetchFromGitLab {
        group = "dsa-2000";
        owner = "rcp";
        repo = "hpg";
        rev = "v${finalAttrs.version}";
        hash = "sha256-tJl/eufKv1z0Hig+zvdi+xykjuPSCCW1SgzsibthcwY=";
      };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    gtest
    hdf5-cpp
    kokkos4
    fftw
    cudaPackages.libcufft
    cudatoolkit
  ];

  cmakeFlags = [
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_GOOGLETEST" "${gtest.src}")
    (lib.cmakeBool "Hpg_ENABLE_SERIAL" true)
    (lib.cmakeBool "HAVE_SERIAL" true)
  ];

  postPatch = ''
    # Remove CONFIG from find_package to use FindHDF5.cmake module instead
    substituteInPlace CMakeLists.txt \
        --replace 'find_package(HDF5 1.14 REQUIRED COMPONENTS C CXX shared CONFIG)' \
                  'find_package(HDF5 1.14 REQUIRED COMPONENTS C CXX)'

    # Fix hardcoded library names in tests
    substituteInPlace tests/CMakeLists.txt \
      --replace 'hdf5-shared' 'hdf5' \
      --replace 'hdf5_cpp-shared' 'hdf5_cpp'
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
})
