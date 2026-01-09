# call with pkgs.callPackage
{
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
  version = libvma-src.rev;
  pname = libvma-src.repo;
  src = libvma-src;
  nativeBuildInputs = [ pkg-config autoreconfHook rdma-core libnl libcap ];
  meta = {
    mainProgram = libvma-src.repo;
    description = "Linux user space library for network socket acceleration based on RDMA compatible network adaptors";
    homepage = "https://github.com/${libvma-src.owner}/${libvma-src.repo}/tree/${libvma-src.rev}";
    maintainers = [ lib.maintainers.birdee ];
  };
}
