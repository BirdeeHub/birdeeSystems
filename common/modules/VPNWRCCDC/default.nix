{ moduleNamespace, inputs, ... }:
{ config, pkgs, lib, ... }: let
  cfg = config.${moduleNamespace}.vpnwrccdc;
in {
  options = {
    ${moduleNamespace} = {
      vpnwrccdc = {
        enable = lib.mkEnableOption "fix ip tables";
      };
    };
  };
  config = lib.mkIf cfg.enable (let
  in {
    networking.dhcpcd.extraConfig = ''
      interface tun0
      metric 42
      gateway
    '';
    networking.networkmanager.dhcp = "dhcpcd";
    # networking.nftables.enable = true;
    # networking.nftables.tables = {
    #   wrccdc = {
    #     content = ''
    #       chain prerouting {
    #         type filter hook prerouting priority 0;
    #         ip saddr 10.3.3.127 accept
    #         counter drop
    #       }
    #
    #       chain output {
    #         type filter hook output priority 0;
    #         accept
    #       }
    #     '';
    #     family = "inet";  # Use "inet" for IPv4
    #   };
    # };

    networking.networkmanager.insertNameservers = [ "10.0.0.2" ];

  });
}
