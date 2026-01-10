{
  flake = {
    diskoConfigurations = {
      sda_swap = ./sda_swap.nix;
      sdb_swap = ./sdb_swap.nix;
      nvme0n1_swap = ./nvme0n1_swap.nix;
      vmware_bios = ./vmware_bios.nix;
      noswap_bios = ./noswap_bios.nix;
    };
  };
}
