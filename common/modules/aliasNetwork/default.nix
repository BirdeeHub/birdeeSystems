{ moduleNamespace, inputs, ... }:
{ config, pkgs, lib, ... }: let
  cfg = config.${moduleNamespace}.aliasNetwork;
in {
  options = {
    ${moduleNamespace} = {
      aliasNetwork = {
        enable = lib.mkEnableOption "alias network to different subnet";
      };
    };
  };
  config = lib.mkIf cfg.enable (let
  in {
    # networking.dhcpcd.extraConfig = ''
    #   interface tun0
    #   metric 42
    #   gateway
    # '';
    # networking.networkmanager.dhcp = "dhcpcd";
    # networking.nftables.enable = true;
    # networking.nftables.tables = {
    #   sdnsorddns = {
    #     content = ''
    #       Stuff to go in the sdnsorddns table
    #     '';
    #     family = "inet";  # Use "inet" for IPv4
    #   };
    # };
    # networking.networkmanager.insertNameservers = [ "10.0.0.2" ];

  });
}
