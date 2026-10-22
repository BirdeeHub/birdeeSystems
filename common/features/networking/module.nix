{ inputs, moduleNamespace, ... }:
let
  name = "networking";
in
{
  flake.modules.nixos.${name} = { pkgs, config, lib, ... }: let
    cfg = config.${moduleNamespace}.${name};
  in {
    options.${moduleNamespace}.${name} = {
      enable = lib.mkEnableOption name;
    };
    config = lib.mkIf cfg.enable {
      # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

      # Configure network proxy if necessary
      # networking.proxy.default = "http://user:password@proxy:port/";
      # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

      # Enable networking
      networking.networkmanager.enable = true;

      # Open ports in the firewall.
      # networking.firewall.allowedTCPPorts = [ ... ];
      # networking.firewall.allowedUDPPorts = [ ... ];
      # Or disable the firewall altogether.
      # networking.firewall.enable = false;


      # I was trying to alias my network to a different subnet...
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
      # networking = {
      #   nftables = {
      #     enable = true;
      #     ruleset = ''
      #         table ip nat {
      #           chain PREROUTING {
      #             type nat hook prerouting priority dstnat; policy accept;
      #             iifname "ens3" tcp dport 80 dnat to 10.100.0.3:80
      #           }
      #         }
      #     '';
      #   };
      #   firewall = {
      #     enable = true;
      #     allowedTCPPorts = [ 80 ];
      #   };
      #   nat = {
      #     enable = true;
      #     internalInterfaces = [ "ens3" ];
      #     externalInterface = "wg0";
      #     forwardPorts = [
      #       {
      #         sourcePort = 80;
      #         proto = "tcp";
      #         destination = "10.100.0.3:80";
      #       }
      #     ];
      #   };
      # };
    };
  };
}
