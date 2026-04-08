{
  inputs,
  util,
  ...
}:
{
  flake.wrappers.zsh =
    {
      pkgs,
      wlib,
      lib,
      config,
      ...
    }@top:
    {
      imports = [ wlib.wrapperModules.zsh ];
      options.flake-path = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = util.flake-path;
      };
      options.output-name = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      options.home-output = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
      };
      config.zshrc.content = /* zsh */ ''
        . ${./compinstallOut}

        HISTFILE="$HOME/.zsh_history"
        HISTSIZE="10000"
        SAVEHIST="10000"
        setopt extendedglob hist_ignore_all_dups
        unsetopt autocd nomatch
        bindkey -v
        ZSH_AUTOSUGGEST_STRATEGY=(history completion)
        source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
        source ${pkgs.runCommand "fzfinit" { } "${pkgs.fzf}/bin/fzf --zsh > $out"}
        . ${
          inputs.self.wrappers.starship.wrap {
            inherit pkgs;
            shell = "zsh";
          }
        }/bin/starship
      '';
      config.zshAliases =
        let
          git = inputs.self.wrappers.git.wrap { inherit pkgs; };
          model = "qwen2.5-coder:7b";
          prompt = pkgs.writeShellScript "prompt" /* bash */ ''
            model=''${1:-'${model}'}
            prompt='
            Generate a silly commit message. Follow these rules:

            Rules:
            - Output ONLY the message — no quotes, no formatting, no explanation.
            - Do NOT use any Twitter-style hashtags (#).
            - Do NOT start with "Refactored the code".
            - Do NOT wrap the reply in quotes, parentheses, or brackets.
            - The output should be raw, like: Fixed the flux capacitor again

            Now reply with just the message.'
            prompt=''${2:-$prompt}
            ollama run "$model" "$prompt"
            echo "(auto-msg $model)"
            ${git}/bin/git status
          '';
          nh = wlib.wrapPackage (
            { config, wlib, ... }:
            {
              config.pkgs = pkgs;
              config.package = pkgs.nh;
              config.env.NH_FLAKE = top.config.flake-path;
              config.argv0type = v: "sudo -v && exec -a \"$0\" ${v}";
              options.eval-type = lib.mkOption {
                type = lib.types.str;
                default = "os";
              };
              options.eval-action = lib.mkOption {
                type = lib.types.str;
                default = "switch";
              };
              options.eval-target = lib.mkOption {
                type = lib.types.str;
                default = top.config.output-name;
              };
              options.flags = lib.mkOption {
                type = lib.types.attrsOf (
                  wlib.types.spec {
                    before = [ "NIX_RUN_MAIN_PACKAGE" ];
                    after = [ "STARTARG" ];
                  }
                );
              };
              options.addFlag = lib.mkOption {
                type = lib.types.listOf (
                  wlib.types.spec {
                    before = [ "NIX_RUN_MAIN_PACKAGE" ];
                    after = [ "STARTARG" ];
                  }
                );
              };
              config.flags."-v" = true;
              config.flags."-t" = true;
              config.flags."-H" = lib.mkIf (config.eval-type == "os") config.eval-target;
              config.flags."-c" = lib.mkIf (config.eval-type == "home") config.eval-target;
              config.addFlag = [
                {
                  name = "STARTARG";
                  data = [
                    config.eval-type
                    config.eval-action
                  ];
                  after = lib.mkForce [ ];
                }
              ];
            }
          );
        in
        {
          ${if config.flake-path != null && config.output-name != null then "rebuild-system" else null} =
            lib.getExe nh;
          ${if config.flake-path != null && config.output-name != null then "rebuild-home" else null} =
            lib.getExe
              (nh.wrap { eval-type = "home"; });
          flakeUpAndAddem = "${pkgs.writeShellScript "flakeUpAndAddem.sh" /* bash */ ''
            target=""; [[ $# > 0 ]] && target=".#$1" && shift 1;
            git add . && nix flake update && nom build --show-trace $target && git add .; $@
          ''}";
          spkgname = "${pkgs.writeShellScript "searchCLIname" /* bash */ ''
            ${pkgs.nix-search-cli}/bin/nix-search -n "$@"
          ''}";
          spkgprog = "${pkgs.writeShellScript "searchCLIprog" /* bash */ ''
            ${pkgs.nix-search-cli}/bin/nix-search -q  "package_programs:("$@")"
          ''}";
          spkgdesc = "${pkgs.writeShellScript "searchCLIdesc" /* bash */ ''
            ${pkgs.nix-search-cli}/bin/nix-search -q  "package_description:("$@")"
          ''}";
          autorepl = "${pkgs.writeShellScript "autorepl" ''
            exec nix repl --show-trace --expr 'rec { wlib = (import ${inputs.wrappers.outPath} { inherit pkgs; }).lib; pkgs = import ${inputs.nixpkgs.outPath} { system = "${pkgs.stdenv.hostPlatform.system}"; config.allowUnfree = true; }; }' "$@"
          ''}";
          yolo = ''${git}/bin/git add . && ${git}/bin/git commit -m "$(curl -fsSL https://whatthecommit.com/index.txt)" -m '(auto-msg whatthecommit.com)' -m "$(${git}/bin/git status)" && ${git}/bin/git push'';
          yoloAI = ''${git}/bin/git add . && ${git}/bin/git commit -m "$(${prompt})" && ${git}/bin/git push'';
          ai-msg = "${prompt}";
          scratch = ''export OGDIR="$(realpath .)" && export SCRATCHDIR="$(mktemp -d)" && cd "$SCRATCHDIR"'';
          exitscratch = ''cd "$OGDIR" && rm -rf "$SCRATCHDIR"'';
          yeet = "rm -rf";
          ccd = ''cd "$(${
            inputs.self.wrappers.xplr.wrap { inherit pkgs; }
          }/bin/xplr --print-pwd-as-result)"'';
          # Ok, so, this is not an alias, but I find it fun and I wanted to save it so its just a comment
          # bat(){ if [[ ! -t 0 || $# != 0 ]]; then local f; for f in "${@-/dev/stdin}"; do echo "$(<"$f")"; done; fi }
          dugood = "${pkgs.writeShellScript "dugood" "du -hxd1 $@ | sort -hr"}";
          run = "nohup xdg-open";
          find-nix-roots = "${pkgs.writeShellScript "find-nix-roots" "find \"\${1:-.}\" -type l -lname '/nix/store/*'"}";
          lsnc = "${pkgs.lsd}/bin/lsd --color=never";
          la = "${pkgs.lsd}/bin/lsd -a";
          ll = "${pkgs.lsd}/bin/lsd -lh";
          l = "${pkgs.lsd}/bin/lsd -alh";
        };
    };
}
