{
  # note: the name birdeeOSSD is shared between
  # both PC disko configs. This means, you can run one
  # from the installer, and even if you have the other as a module
  # in your nixos config, the label will be the same and thus it will work fine.
  # it will be named disk-birdeeOSSD-{ESP, root, swap}
  disko.devices = {
    disk = {
      birdeeOSSD = {
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              end = "-5G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
            swap = {
              size = "100%";
              content = {
                type = "swap";
                resumeDevice = true; # resume from hiberation from this device
              };
            };
          };
        };
      };
    };
  };
}
