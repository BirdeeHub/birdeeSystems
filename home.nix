{ config, pkgs, self, inputs, homeDirectory, username, stateVersion, ...  }: let
    poshTheme = builtins.toFile "atomic-emodipt.omp.json" (builtins.readFile ./term/atomic-emodipt.omp.json);
  in {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = username;
  home.homeDirectory = homeDirectory;

  birdeeVim.enable = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = stateVersion; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = let
    alakittycfg = builtins.toFile "alacritty.yml" (builtins.readFile ./term/alacritty.yml);
    alakitty = pkgs.writeScriptBin "alacritty" ''
      #!/bin/sh
      exec ${pkgs.alacritty}/bin/alacritty --config-file ${alakittycfg} "$@"
    '';
  in
  with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
    openmoji-color
    noto-fonts-emoji
    (nerdfonts.override { fonts = [ "FiraMono" "Go-Mono" ]; })

    alakitty
    galculator
    qalculate-qt
    oh-my-posh
    firefox
    signal-desktop
    bitwarden-cli
    discord
    jdk
    gradle
    kotlin
    kotlin-native
    go
    distrobox
    wget
    gimp
    spotify
    zsh
    tree
    zip
    unzip
    git
    pciutils
    glxinfo
    xclip
    xsel

    chromium
    slack
    zoom-us
    remmina

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];
  fonts.fontconfig.enable = true;
  qt.platformTheme = "gtk";

  programs = {
    bash = {
      initExtra = ''
        eval "$(oh-my-posh init bash --config ${poshTheme})"
      '';
    };
    zsh = {
      shellAliases = {};
      enable = true;
      enableAutosuggestions = true;
      completionInit = (builtins.readFile ./term/compinstallOut);
      history.ignoreAllDups = true;
      initExtra = ''
        # Lines configured by zsh-newuser-install
        HISTFILE=~/.histfile
        HISTSIZE=1000
        SAVEHIST=10000
        setopt extendedglob
        unsetopt autocd nomatch
        bindkey -v
        # End of lines configured by zsh-newuser-install
        eval "$(oh-my-posh init zsh --config ${poshTheme})"
      '';
    };
    # fish = {
    #   enable = true;
    #   interactiveShellInit = ''
    #     oh-my-posh init fish --config ${poshTheme} | source
    #   '';
    # };
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

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
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
