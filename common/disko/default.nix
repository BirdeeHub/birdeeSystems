{
  PCs = {
    sda_swap = import ./PCs/sda_swap.nix;
    sdb_swap = import ./PCs/sdb_swap.nix;
    nvme0n1_swap = import ./PCs/nvme0n1_swap.nix;
  };
  VMs = {
    vmware_bios = import ./VMs/vmware_bios.nix;
    noswap_bios = import ./VMs/noswap_bios.nix;
  };
}
