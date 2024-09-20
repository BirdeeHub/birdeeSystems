{ config, lib, pkgs, self, modulesPath, system-modules, inputs, is_minimal ? true, ... }: let
  tx = pkgs.writeShellScriptBin "tx" ''
    if ! echo "$PATH" | grep -q "${pkgs.tmux}/bin"; then
      export PATH=${pkgs.tmux}/bin:$PATH
    fi
    if [[ $(tmux list-sessions -F '#{?session_attached,1,0}' | grep -c '0') -ne 0 ]]; then
      selected_session=$(tmux list-sessions -F '#{?session_attached,,#{session_name}}' | tr '\n' ' ' | awk '{print $1}')
      exec tmux new-session -At $selected_session
    else
      exec tmux new-session
    fi
  '';
  # TODO: if you use zsh it prompts you to set it up every time...
  # change it back to zsh when you make it have an empty .zshrc for user
  login_shell = "fish";

in {
  imports = with system-modules; [
    "${modulesPath}/installer/cd-dvd/installation-cd-base.nix"
    ./minimal-graphical-base.nix
    shell.bash
    shell.${login_shell}
    ranger
    birdeeVim.nixosModules.default
  ];

  # TODO: make a more minimal config for this later so you can include it...
  birdeeVim = {
    enable = ! is_minimal;
    packageNames = [ "noAInvim" ];
  };

  boot.kernelModules = [ "wl" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # Allow flakes and new command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.shellAliases = let
  in {
    birdeeOS = "${pkgs.writeShellScript "birdeeOS" ''
      output=$1
      username=$2
      sudo disko --mode disko --flake github:BirdeeHub/birdeeSystems#$output
      sudo nixos-install --show-trace --flake github:BirdeeHub/birdeeSystems#$output
      echo "please set password for user $username"
      sudo passwd --root /mnt $username
      mkdir -p /mnt/home/$username/birdeeSystems
      git clone https://github.com/BirdeeHub/birdeeSystems /mnt/home/$username/birdeeSystems
      sudo chmod -R go-rwx /mnt/home/$username/birdeeSystems
      sudo chown -R $username:users /mnt/home/$username/birdeeSystems
    ''}";
    birdeeOS-disko = "${pkgs.writeShellScript "birdeeOS-disko" ''
      output=$1
      sudo disko --mode disko --flake github:BirdeeHub/birdeeSystems#$output
    ''}";
    birdeeOS-install = "${pkgs.writeShellScript "birdeeOS-install" ''
      output=$1
      username=$2
      sudo nixos-install --show-trace --flake github:BirdeeHub/birdeeSystems#$output
      echo "please set password for user $username"
      sudo passwd --root /mnt $username
      mkdir -p /mnt/home/$username/birdeeSystems
      git clone https://github.com/BirdeeHub/birdeeSystems /mnt/home/$username/birdeeSystems
      sudo chmod -R go-rwx /mnt/home/$username/birdeeSystems
      sudo chown -R $username:users /mnt/home/$username/birdeeSystems
    ''}";
    lsnc = "lsd --color=never";
    la = "ls -a";
    ll = "ls -l";
    l  = "ls -alh";
  };

  isoImage.contents = lib.mkIf (builtins.isPath "${self}/secrets") [
    { source = "${self}/secrets"; target = "/secrets";}
  ];

  isoImage.isoBaseName = "birdeeOS_installer";

  toppings = {
    ${login_shell}.enable = true;
    bash.enable = true;
    ranger = {
      enable = true;
      withoutDragon = true;
    };
  };

  services.xserver.enable = true;
  services.xserver.desktopManager.session = (let
    alakitty = pkgs.callPackage ./alatoml.nix {
      maximize_program = inputs.maximizer.packages.${pkgs.system}.default;
      inherit tx;
      shellStr = "${pkgs.${login_shell}}/bin/${login_shell}";
    };
  in [
    { name = "alacritty";
      start = /*bash*/ ''
        ${pkgs.xorg.xrandr}/bin/xrandr --output Virtual-1 --primary --preferred
        ${pkgs.alacritty}/bin/alacritty --config-file ${alakitty} &
        waitPID=$!
      '';
    }
  ]);

  services.displayManager.defaultSession = "alacritty";

  users.defaultUserShell = pkgs.${login_shell};

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraMono" ]; })
  ];
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [ "FiraMono Nerd Font" ];
      sansSerif = [ "FiraMono Nerd Font" ];
      monospace = [ "FiraMono Nerd Font" ];
    };
  };
  fonts.fontDir.enable = true;

  services.libinput.enable = true;
  services.libinput.touchpad.disableWhileTyping = true;
  environment.systemPackages = with pkgs; [
    inputs.disko.packages.${system}.default
    tmux
    tx
    git
    findutils
    coreutils
    xclip
  ] ++ (if is_minimal then [ pkgs.neovim ] else with pkgs; [
  ]);

  # for xterm instead, these should be useful
  # services.xserver.displayManager.sessionCommands = /*bash*/ ''
  #   ${pkgs.xorg.xrdb}/bin/xrdb -merge ${pkgs.writeText "Xresources" ''
  #     XTerm*termName: xterm-256color
  #     XTerm*faceName: FiraMono Nerd Font
  #     XTerm*faceSize: 12
  #     XTerm*background: black
  #     XTerm*foreground: white
  #   ''}
  # '';

}
