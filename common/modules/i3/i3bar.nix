{}: ''
order += "load"
order += "cpu_usage"
order += "cpu_temperature 0"
order += "memory"
order += "disk /"
order += "disk /mnt/win-sdb"
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
disk /mnt/win-sdb {
    format = "Win: %avail/%total"
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
        path = "/sys/devices/platform/coretemp.0/hwmon/hwmon5/temp1_input"
}
''
