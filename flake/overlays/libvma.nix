# call with pkgs.callPackage
let
  pname = "libvma";
in {
  lib,
  pkg-config,
  autoreconfHook,
  rdma-core,
  libnl,
  libcap,
  fetchFromGitHub,
  stdenv,
  # can also come from flake input
  libvma-src ? fetchFromGitHub {
    repo = "libvma";
    rev = "9.8.84";
    owner = "Mellanox";
    hash = "sha256-vm9yeoW65HdkzGhoV9cdNf7sEIgloxFNXM/Bqfp7als=";
  },
  ...
}:
stdenv.mkDerivation {
  version = libvma-src.rev or "master";
  inherit pname;
  src = libvma-src;
  nativeBuildInputs = [ pkg-config autoreconfHook rdma-core libnl libcap ];
  meta = {
    mainProgram = pname;
    description = "Linux user space library for network socket acceleration based on RDMA compatible network adaptors";
    homepage = "https://github.com/${libvma-src.owner or "Mellanox"}/${pname}/tree/${libvma-src.rev or "master"}";
    maintainers = [ lib.maintainers.birdee ];
  };
}
