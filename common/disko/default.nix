{
  flake = {
    diskoConfigurations = {
      sda_swap = import ./sda_swap.nix;
      sdb_swap = import ./sdb_swap.nix;
      nvme0n1_swap = import ./nvme0n1_swap.nix;
      vmware_bios = import ./vmware_bios.nix;
      noswap_bios = import ./noswap_bios.nix;
    };
  };
}
