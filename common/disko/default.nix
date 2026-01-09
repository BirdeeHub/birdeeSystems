{
  PCs = {
    sda_swap = ./PCs/sda_swap.nix;
    sdb_swap = ./PCs/sdb_swap.nix;
    nvme0n1_swap = ./PCs/nvme0n1_swap.nix;
  };
  VMs = {
    vmware_bios = ./VMs/vmware_bios.nix;
    noswap_bios = ./VMs/noswap_bios.nix;
  };
}
