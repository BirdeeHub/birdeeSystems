_: {
  flake.wrappers.i3status = { config, pkgs, lib, wlib, ... }: {
    options.cputemppath = lib.mkOption {
      type = wlib.types.stringable;
      # default = "/sys/devices/platform/coretemp.0/hwmon/hwmon5/temp1_input";
      default = "/sys/class/thermal/thermal_zone0/temp";
    };
    options.general.output_format = lib.mkOption {
      type = lib.types.enum [ "i3bar" "dzen2" "xmobar" "lemonbar" "term" "none" null ];
      default = null;
    };
    options.general.interval = lib.mkOption {
      type = lib.types.nullOr lib.types.number;
      default = null;
    };
    options.general.color = lib.mkOption {
      type = lib.types.nullOr lib.types.bool;
      default = null;
    };
    options.general.color_good = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    options.general.color_degraded = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    options.general.color_bad = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    imports = [ wlib.modules.default ];
    config.flags."--config" = config.constructFiles.i3barcfg.path;
    config.package = lib.mkDefault pkgs.i3status;
    config.constructFiles.i3barcfg = {
      relPath = "${config.binName}-rc";
      content = lib.optionalString (builtins.any (v: v != null) (builtins.attrValues config.general)) (lib.pipe config.general [
        (lib.mapAttrsToList (n: v: if v == null then "" else "  ${n} = ${builtins.toJSON v}"))
        (builtins.concatStringsSep "\n")
        (s: "general {\n${s}\n}\n")
      ]) + ''
        order += "load"
        order += "cpu_usage"
        order += "cpu_temperature 0"
        order += "memory"
        order += "disk /"
        order += "disk /home"
        order += "run_watch DHCP"
        order += "run_watch VPNC"
        # order += "path_exists VPN"
        order += "ethernet enp2s0"
        order += "wireless wlo1"
        order += "time"

        time {
          format = "%Y-%m-%d, %a, %H:%M:%S"
        }
        disk "/" {
          format = "Nix: %avail/%total"
        }
        disk "/home" {
          format = "Home: %avail/%total"
        }
        cpu_usage {
          format = "CPU: %usage"
        }
        load {
          format = "%1min"
          max_threshold = "2"
          format_above_threshold = "%1min %5min"
        }
        memory {
          format = "RAM: %used/%total"
        }

        run_watch DHCP {
          pidfile = "/var/run/dhclient*.pid"
        }

        run_watch VPNC {
          # file containing the PID of a vpnc process
          pidfile = "/var/run/vpnc/pid"
        }

        path_exists VPN {
          # path exists when a VPN tunnel launched by nmcli/nm-applet is active
          path = "/proc/sys/net/ipv4/conf/tun0"
        }

        ethernet enp2s0 {
          format_up = "LAN: %ip (%speed)"
          format_down = ""
        }

        wireless wlo1 {
          format_up = "%essid %ip (%quality at %bitrate)"
          format_down = ""
        }
        cpu_temperature 0 {
          format = "%degrees °C"
          path = "${config.cputemppath}"
        }
      '';
    };
  };
}
