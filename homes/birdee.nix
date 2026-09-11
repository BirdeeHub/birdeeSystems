{ config, util, pkgs, lib, inputs, users, username, output-name, stateVersion, osConfig ? null, ...  }@args: let
in {
  birdeeMods = {
    bash.enable = true;
    flatpak.enable = true;
    firefox.enable = true;
    nixconfig.enable = true;
    theme.enable = true;
  };
  wrappers = {
    i3.enable = true;
    i3.updateDbusEnvironment = true;
    i3.i3Monager.enable = true;
    birdeeLua.enable = true;
    neovim.enable = true;
    wezterm.enable = true;
    fish.enable = true;
    zsh.enable = true;
    zsh.output-name = lib.mkIf (osConfig != null) output-name;
    zsh.home-output = if osConfig == null then output-name else username;
    zsh.hmSessionVariables = if osConfig == null then "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh" else null;
    opencode.enable = true;
    tmux.enable = true;
    xplr.enable = true;
    git.enable = true;
    nushell.enable = true;
    luakit.enable = true;
  };

  home.sessionVariables.JAVA_HOME = "${pkgs.jdk}";

  xdg.enable = true;
  xdg.userDirs = {
    enable = true;
    setSessionVariables = true;
    desktop = "${config.home.homeDirectory}/Desktop";
    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads";
    music = "${config.home.homeDirectory}/Music";
    pictures = "${config.home.homeDirectory}/Pictures";
    publicShare = "${config.home.homeDirectory}/Public";
    templates = "${config.home.homeDirectory}/Templates";
    videos = "${config.home.homeDirectory}/Videos";
    extraConfig = {
      MISC = "${config.home.homeDirectory}/Misc";
    };
  };
  xdg.mimeApps.defaultApplications = {
    "inode/directory" = [ "xplr.desktop" ];
    "application/pdf" = [ "firefox.desktop" "draw.desktop" "gimp.desktop" ];
  };

  home.packages = with pkgs; [
    (config.wrappers.neovim.wrap { settings.test_mode = true; })
    # nops # manix fzf alias
    # manix
    dep-tree
    minesweeper
    gac
    nix-inspect
    #

    ffuf
    kdePackages.kdenlive
    blender
    kdePackages.dolphin
    nmap
    sqlmap
    burpsuite
    zap
    metasploit
    yt-dlp
    bettercap
    openvpn
    openconnect
    ghidra
    nth
    xh
    gh

    jimtcl

    # dislocker
    ueberzugpp
    vlc
    nix-tree
    inputs.nix-graph.packages.${stdenv.hostPlatform.system}.default
    grex
    qbittorrent
    # galculator
    gparted
    exfatprogs
    ntfs3g
    lm_sensors
    btop
    graphviz-nox
    nix-output-monitor
    nh
    inputs.nsearch.packages.${stdenv.hostPlatform.system}.default
    nix-info
    direnv
    steam-run
    # ruffle
    # qemu
    # lxappearance
    qalculate-qt
    signal-desktop
    bitwarden-cli
    discord
    docker-compose
    libnotify
    obs-studio
    obs-do
    obs-cli
    obs-cmd
    gnumake
    cmake
    # gccgo just have a dev shell for c....
    # gccgo
    gotools
    go-tools
    sqlite-interactive
    evcxr

    clisp

    man-pages
    man-pages-posix
    _7zz
    # gnome.gnome-software
    steam
    heroic
    # lutris
    wineWow64Packages.stable
    winetricks
    python3
    distrobox
    lazygit
    nix-search-cli
    fastfetch
    lolcat
    nurl
    gping
    
    nix-prefetch
    wget
    openssl
    gimp
    # spotify
    tree
    fd
    fzf
    duf
    tldr
    lsof
    noti
    bat
    lsd
    zip
    dig
    unzip
    pciutils
    xclip
    xcp
    xsel
    xev
    psmisc
    xmodmap
    libreoffice
    wireshark
    chromium
    slack
    zoom-us
    remmina
    # ventoy-full

    jdk
    gradle
    kotlin
    kotlin-native
    # jetbrains.idea-community
    # android-studio
    visualvm

    ristretto
    tumbler
  ];

  dbus.packages = [
    # needed by ristretto
    pkgs.tumbler
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;
    # ".config/foo-dir".source = config.lib.file.mkOutOfStoreSymlink "apparently store or absolute is fine";
    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/birdee/etc/profile.d/hm-session-vars.sh
  #

  programs.home-manager.enable = true;
  home.stateVersion = stateVersion;
}
