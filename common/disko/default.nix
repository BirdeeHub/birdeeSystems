{
  PCs = {
    sda_swap = import ./PCs/sda_swap.nix;
    sdb_swap = import ./PCs/sdb_swap.nix;
  };
  VMs = {
    vmware_bios = import ./VMs/vmware_bios.nix;
  };
}
