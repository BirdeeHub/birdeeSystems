{ config, lib, pkgs, self, modulesPath, system-modules, inputs, is_minimal ? true, use_alacritty ? false, ... }: let
  # TODO: non_minimal should also include calamares installer, i3, firefox,
  # and also disk utilities so that you dont have to nix shell them all

  final_tmux = pkgs.tmux.override (prev: {
    term_string = if use_alacritty then "alacritty" else "xterm-256color";
  });

  tx = pkgs.writeShellScriptBin "tx" ''
    if [[ $(${final_tmux}/bin/tmux list-sessions -F '#{?session_attached,1,0}' | grep -c '0') -ne 0 ]]; then
      selected_session=$(${final_tmux}/bin/tmux list-sessions -F '#{?session_attached,,#{session_name}}' | tr '\n' ' ' | awk '{print $1}')
      ${final_tmux}/bin/tmux new-session -At $selected_session
    else
      ${final_tmux}/bin/tmux new-session
    fi
  '';
  nerd_font_string = "FiraMono";
  font_string = "${nerd_font_string} Nerd Font";
  login_shell = "zsh";

in {
  imports = with system-modules; [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-base.nix"
    # "${modulesPath}/installer/cd-dvd/installation-cd-base.nix"
    # ./minimal-graphical-base.nix
    shell.${login_shell}
    ranger
  ] ++ (lib.optional (login_shell != "bash") system-modules.shell.bash);

  birdeeMods = {
    ${login_shell}.enable = true;
    ranger = {
      enable = true;
      withoutDragon = true;
    };
  } // (lib.optionalAttrs (login_shell != "bash") {
    bash.enable = true;
  });

  nix.settings = {
    extra-trusted-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  environment.systemPackages = with pkgs; [
    inputs.disko.packages.${system}.default
    final_tmux
    tx
    git
    findutils
    coreutils
    xclip
  ] ++ (if is_minimal then [
    pkgs.neovim
  ] else with pkgs; [
    # todo make a version that counts as minimal to include above
    system-modules.birdeevim.packages.${system}.noAInvim
  ]);

  isoImage.isoBaseName = "birdeeOS_installer";
  isoImage.contents = lib.mkIf (builtins.isPath "${self}/secrets") [
    { source = "${self}/secrets"; target = "/secrets";}
  ];

  environment.shellAliases = {
    birdeeOS = "${pkgs.writeShellScript "birdeeOS" ''
      output=$1
      username=$2
      repo=''${3:-"birdeeSystems"}
      sudo disko --mode disko --flake github:BirdeeHub/$repo#$output
      sudo nixos-install -v --show-trace --flake github:BirdeeHub/$repo#$output
      echo "please set password for user $username"
      sudo passwd --root /mnt $username
      mkdir -p /mnt/home/$username/$repo
      git clone https://github.com/BirdeeHub/$repo /mnt/home/$username/$repo
      sudo chmod -R go-rwx /mnt/home/$username/$repo
      sudo chown -R $username:users /mnt/home/$username/$repo
    ''}";
    birdeeOS-disko = "${pkgs.writeShellScript "birdeeOS-disko" ''
      output=$1
      repo=''${2:-"birdeeSystems"}
      sudo disko --mode disko --flake github:BirdeeHub/$repo#$output
    ''}";
    birdeeOS-install = "${pkgs.writeShellScript "birdeeOS-install" ''
      output=$1
      username=$2
      repo=''${3:-"birdeeSystems"}
      sudo nixos-install -v --show-trace --flake github:BirdeeHub/$repo#$output
      echo "please set password for user $username"
      sudo passwd --root /mnt $username
      mkdir -p /mnt/home/$username/$repo
      git clone https://github.com/BirdeeHub/$repo /mnt/home/$username/$repo
      sudo chmod -R go-rwx /mnt/home/$username/$repo
      sudo chown -R $username:users /mnt/home/$username/$repo
    ''}";
    lsnc = "ls --color=never";
    la = "ls -a";
    ll = "ls -l";
    l  = "ls -alh";
  };

  boot.kernelModules = [ "wl" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" "pipe-operators" ];
  nix.settings.show-trace = true;
  services.libinput.enable = true;
  services.libinput.touchpad.disableWhileTyping = true;

  users.defaultUserShell = pkgs.${login_shell};
  system.activationScripts.silencezsh.text = ''
    [ ! -e "/home/nixos/.zshrc" ] && echo "# dummy file" > /home/nixos/.zshrc
  '';

  fonts.packages = with pkgs; [
    nerd-fonts.fira-mono
  ];
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [ font_string ];
      sansSerif = [ font_string ];
      monospace = [ font_string ];
    };
  };
  fonts.fontDir.enable = true;

  services.xserver.enable = true;
  services.displayManager.defaultSession = if use_alacritty then "alacritty" else "xterm-installer";
  services.xserver.desktopManager.session = let
    alacritty_dm = (let
      alakitty = pkgs.callPackage ./alatoml.nix {
        maximizer = "${inputs.maximizer.packages.${pkgs.system}.default}/bin/maximize_program";
        inherit tx font_string;
        shellStr = "${pkgs.${login_shell}}/bin/${login_shell}";
      };
    in [
      { name = "alacritty";
        start = /*bash*/ ''
          ${pkgs.alacritty}/bin/alacritty --config-file ${alakitty} &
          waitPID=$!
        '';
      }
    ]);
    xterm_dm = (let
      maximizer = "${inputs.maximizer.packages.${pkgs.system}.default}/bin/maximize_program";
      launchScript = pkgs.writeShellScript "mysh" /*bash*/ ''
        ${maximizer} xterm > /dev/null 2>&1 &
        exec ${tx}/bin/tx
      '';
    in [
      { name = "xterm-installer";
        start = /*bash*/ ''
          ${pkgs.xorg.xrdb}/bin/xrdb -merge ${pkgs.writeText "Xresources" ''
            xterm*termName: xterm-256color
            xterm*faceName: ${font_string}
            xterm*faceSize: 12
            xterm*background: black
            xterm*foreground: white
            xterm*title: xterm
            xterm*loginShell: true
          ''}
          ${pkgs.xterm}/bin/xterm -name xterm -e ${launchScript} &
          waitPID=$!
        '';
      }
    ]);
  in
  if use_alacritty then alacritty_dm else xterm_dm;

}
