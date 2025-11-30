{ inputs ? {}, pkgs }: (inputs.wrappers.lib.evalModule (pkgs.lib.modules.importApply ./module.nix inputs)).config.wrap { inherit pkgs; }
