{ inputs, moduleNamespace, ... }:
let
  name = "printing";
in
{
  flake.modules.nixos.${name} = { pkgs, config, lib, ... }: let
    cfg = config.${moduleNamespace}.${name};
  in {
    options.${moduleNamespace}.${name} = {
      enable = lib.mkEnableOption name;
    };
    config = lib.mkIf cfg.enable {
      # Enable CUPS to print documents.
      services.system-config-printer.enable = true;
      programs.system-config-printer.enable = true;
      services.printing.enable = true;
      services.printing.drivers = with pkgs; [
        gutenprint
        hplip
        splix
      ];
      services.printing.webInterface = false;
      environment.systemPackages = [ pkgs.hplip ];
    };
  };
}
