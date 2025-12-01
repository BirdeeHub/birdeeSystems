{
  config,
  lib,
  wlib,
  pkgs,
  ...
}:
# Produces a SOURCEABLE script which exports STARSHIP_CONFIG and then evals the prompt command
# This is because STARSHIP_CONFIG needs to be set in the SHELL, not just starship
let
  tomlFmt = pkgs.formats.toml { };
in
{
  imports = [ wlib.modules.default ];
  options = {
    settings = lib.mkOption {
      type = tomlFmt.type;
      default = { };
      description = "Starship configuration as a Nix attribute set. See https://starship.rs/config/";
      example = {
        add_newline = false;
        character = {
          success_symbol = "[>](bold green)";
          error_symbol = "[x](bold red)";
        };
        directory = {
          truncation_length = 3;
        };
      };
    };

    configFile = lib.mkOption {
      type = wlib.types.file pkgs;
      default.path = tomlFmt.generate "starship.toml" config.settings;
      description = "The starship configuration file.";
    };
  };

  config = {
    argv0type = lib.mkDefault (s: ''eval "$(${s})"'');
    package = lib.mkDefault pkgs.starship;
    env.STARSHIP_CONFIG = config.configFile.path;
    meta.platforms = lib.platforms.all;
    settings = {
      format =
        "$shell$sudo$vcsh$fossil_branch$fossil_metrics$git_branch$git_commit$git_state$git_metrics$git_status$hg_branch$pijul_channel$docker_context$package$line_break"
        + "$username$hostname$localip$shlvl$singularity$kubernetes$directory$fill"
        + "$c$cmake$cobol$daml$dart$deno$dotnet$elixir$elm$erlang$fennel$gleam$golang$guix_shell$haskell$haxe$helm$java$julia$kotlin$gradle$lua$nim$nodejs$ocaml$opa$perl$php$pulumi$purescript$python$quarto$raku$rlang$red$ruby$rust$scala$solidity$swift$terraform$typst$vlang$vagrant$zig$buf$nix_shell$conda$meson$spack$memory_usage$aws$gcloud$openstack$azure$nats$direnv$env_var$crystal$custom$cmd_duration$jobs$battery$os$container$time$status$line_break"
        + "$character";
      battery = {
        charging_symbol = "⚡";
        disabled = false;
        display = [
          {
            style = "bold red";
            threshold = 25;
          }
          {
            style = "bold yellow";
            threshold = 50;
          }
          {
            style = "green";
            threshold = 80;
          }
        ];
      };
      directory = {
        read_only = " 󰌾";
        truncate_to_repo = false;
        truncation_length = 255;
        use_logical_path = false;
      };
      git_branch = {
        format = "[$symbol$branch(:$remote_branch)]($style) ";
        symbol = " ";
      };
      git_metrics = {
        disabled = false;
        only_nonzero_diffs = true;
      };
      git_status = {
        ahead = ''⇡''${count}'';
        behind = ''⇣''${count}'';
        disabled = false;
        diverged = ''⇕⇡''${ahead_count}⇣''${behind_count}'';
        format = "([\\[$all_status$ahead_behind\\]]($style) )";
        staged = "[++$count](green)";
      };
      hostname = {
        format = "[$ssh_symbol$hostname]($style): ";
        ssh_only = false;
        ssh_symbol = " ";
      };
      shell.disabled = false;
      sudo = {
        disabled = false;
        format = "[$symbol]($style)";
      };
      time = {
        disabled = false;
        format = "[\\[ $time \\]]($style) ";
        style = "bold yellow";
        time_format = "%H:%M:%S";
        time_range = "00:00:00-23:59:59";
        use_12hr = false;
      };
      username = {
        format = "[$user]($style)@";
        show_always = true;
      };
      os = {
        disabled = false;
        symbols = {
          AlmaLinux = " ";
          Alpaquita = " ";
          Alpine = " ";
          Amazon = " ";
          Android = " ";
          Arch = " ";
          Artix = " ";
          CentOS = " ";
          Debian = " ";
          DragonFly = " ";
          Emscripten = " ";
          EndeavourOS = " ";
          Fedora = " ";
          FreeBSD = " ";
          Garuda = "󰛓 ";
          Gentoo = " ";
          HardenedBSD = "󰞌 ";
          Illumos = "󰈸 ";
          Kali = " ";
          Linux = " ";
          Mabox = " ";
          Macos = " ";
          Manjaro = " ";
          Mariner = " ";
          MidnightBSD = " ";
          Mint = " ";
          NetBSD = " ";
          NixOS = " ";
          OpenBSD = "󰈺 ";
          OracleLinux = "󰌷 ";
          Pop = " ";
          Raspbian = " ";
          RedHatEnterprise = " ";
          Redhat = " ";
          Redox = "󰀘 ";
          RockyLinux = " ";
          SUSE = " ";
          Solus = "󰠳 ";
          Ubuntu = " ";
          Unknown = " ";
          Void = " ";
          Windows = "󰍲 ";
          openSUSE = " ";
        };
      };
      git_commit.tag_symbol = "  ";
      fossil_branch.symbol = " ";
      aws.symbol = "  ";
      buf.symbol = " ";
      c.symbol = " ";
      conda.symbol = " ";
      crystal.symbol = " ";
      dart.symbol = " ";
      docker_context.symbol = " ";
      elixir.symbol = " ";
      elm.symbol = " ";
      fennel.symbol = " ";
      fill.symbol = " ";
      golang.symbol = " ";
      gradle.symbol = " ";
      guix_shell.symbol = " ";
      haskell.symbol = " ";
      haxe.symbol = " ";
      hg_branch.symbol = " ";
      java.symbol = " ";
      julia.symbol = " ";
      kotlin.symbol = " ";
      lua.symbol = " ";
      memory_usage.symbol = "󰍛 ";
      meson.symbol = "󰔷 ";
      nim.symbol = "󰆥 ";
      nix_shell.symbol = " ";
      nodejs.symbol = " ";
      ocaml.symbol = " ";
      package.symbol = "󰏗 ";
      perl.symbol = " ";
      php.symbol = " ";
      pijul_channel.symbol = " ";
      python.symbol = " ";
      rlang.symbol = "󰟔 ";
      ruby.symbol = " ";
      rust.symbol = "󱘗 ";
      scala.symbol = " ";
      zig.symbol = " ";
      swift.symbol = " ";
    };
  };
}
