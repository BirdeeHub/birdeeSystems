{
  config,
  lib,
  wlib,
  pkgs,
  ...
}:

let
  tomlFmt = pkgs.formats.toml { };
in
{
  imports = [ wlib.modules.default ];
  options = {
    settings = lib.mkOption {
      type = tomlFmt.type;
      default = {
        format =
          "$shell"
          + "$sudo"
          + "$vcsh"
          + "$fossil_branch"
          + "$fossil_metrics"
          + "$git_branch"
          + "$git_commit"
          + "$git_state"
          + "$git_metrics"
          + "$git_status"
          + "$hg_branch"
          + "$pijul_channel"
          + "$docker_context"
          + "$package"
          + "$line_break"
          + "$username"
          + "$hostname"
          + "$localip"
          + "$shlvl"
          + "$singularity"
          + "$kubernetes"
          + "$directory"
          + "$fill"
          + "$c"
          + "$cmake"
          + "$cobol"
          + "$daml"
          + "$dart"
          + "$deno"
          + "$dotnet"
          + "$elixir"
          + "$elm"
          + "$erlang"
          + "$fennel"
          + "$gleam"
          + "$golang"
          + "$guix_shell"
          + "$haskell"
          + "$haxe"
          + "$helm"
          + "$java"
          + "$julia"
          + "$kotlin"
          + "$gradle"
          + "$lua"
          + "$nim"
          + "$nodejs"
          + "$ocaml"
          + "$opa"
          + "$perl"
          + "$php"
          + "$pulumi"
          + "$purescript"
          + "$python"
          + "$quarto"
          + "$raku"
          + "$rlang"
          + "$red"
          + "$ruby"
          + "$rust"
          + "$scala"
          + "$solidity"
          + "$swift"
          + "$terraform"
          + "$typst"
          + "$vlang"
          + "$vagrant"
          + "$zig"
          + "$buf"
          + "$nix_shell"
          + "$conda"
          + "$meson"
          + "$spack"
          + "$memory_usage"
          + "$aws"
          + "$gcloud"
          + "$openstack"
          + "$azure"
          + "$nats"
          + "$direnv"
          + "$env_var"
          + "$crystal"
          + "$custom"
          + "$cmd_duration"
          + "$jobs"
          + " $battery"
          + "$os"
          + "$container"
          + "$time"
          + "$status"
          + "$line_break"
          + "$character";

        username = {
          show_always = true;
          format = "[$user]($style)@";
        };

        hostname = {
          ssh_only = false;
          ssh_symbol = " ";
          format = "[$ssh_symbol$hostname]($style): ";
        };

        directory = {
          read_only = " 󰌾";
          truncation_length = 255;
          truncate_to_repo = false;
          use_logical_path = false;
        };

        shell = {
          disabled = false;
          # bash_indicator = "b"
          # fish_indicator = "f"
          # zsh_indicator = "z"
        };

        sudo = {
          disabled = false;
          format = "[$symbol]($style)";
        };

        battery = {
          disabled = false;
          charging_symbol = "⚡";
          # discharging_symbol = "🔋"
          # full_symbol = "🔋"
          display = [
            {
              threshold = 25;
              style = "bold red";
            }
            {
              threshold = 50;
              style = "bold yellow";
            }
            {
              threshold = 80;
              style = "green";
            }
          ];
        };

        os = {
          disabled = false;
        };

        fill = {
          symbol = " ";
        };

        git_status = {
          disabled = false;
          format = "([$all_status$ahead_behind]($style) )";
          ahead = "⇡\${count}";
          diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
          behind = "⇣\${count}";
          staged = "[++$count](green)";
        };

        git_metrics = {
          disabled = false;
          only_nonzero_diffs = true;
        };

        time = {
          disabled = false;
          use_12hr = false;
          style = "bold yellow";
          format = "[[ $time ]]($style) ";
          time_format = "%H:%M:%S";
          time_range = "00:00:00-23:59:59";
        };

        aws = {
          symbol = "  ";
        };
        buf = {
          symbol = " ";
        };
        c = {
          symbol = " ";
        };
        conda = {
          symbol = " ";
        };
        crystal = {
          symbol = " ";
        };
        dart = {
          symbol = " ";
        };
        docker_context = {
          symbol = " ";
        };
        elixir = {
          symbol = " ";
        };
        elm = {
          symbol = " ";
        };
        fennel = {
          symbol = " ";
        };
        fossil_branch = {
          symbol = " ";
        };

        git_branch = {
          format = "[$symbol$branch(:$remote_branch)]($style) ";
          symbol = " ";
        };

        git_commit = {
          tag_symbol = "  ";
        };
        golang = {
          symbol = " ";
        };
        guix_shell = {
          symbol = " ";
        };
        haskell = {
          symbol = " ";
        };
        haxe = {
          symbol = " ";
        };
        hg_branch = {
          symbol = " ";
        };
        java = {
          symbol = " ";
        };
        julia = {
          symbol = " ";
        };
        kotlin = {
          symbol = " ";
        };
        lua = {
          symbol = " ";
        };

        memory_usage = {
          symbol = "󰍛 ";
        };
        meson = {
          symbol = "󰔷 ";
        };
        nim = {
          symbol = "󰆥 ";
        };
        nix_shell = {
          symbol = " ";
        };
        nodejs = {
          symbol = " ";
        };
        ocaml = {
          symbol = " ";
        };

        os.symbols = {
          Alpaquita = " ";
          Alpine = " ";
          AlmaLinux = " ";
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
          openSUSE = " ";
          OracleLinux = "󰌷 ";
          Pop = " ";
          Raspbian = " ";
          Redhat = " ";
          RedHatEnterprise = " ";
          RockyLinux = " ";
          Redox = "󰀘 ";
          Solus = "󰠳 ";
          SUSE = " ";
          Ubuntu = " ";
          Unknown = " ";
          Void = " ";
          Windows = "󰍲 ";
        };

        package = {
          symbol = "󰏗 ";
        };
        perl = {
          symbol = " ";
        };
        php = {
          symbol = " ";
        };
        pijul_channel = {
          symbol = " ";
        };
        python = {
          symbol = " ";
        };
        rlang = {
          symbol = "󰟔 ";
        };
        ruby = {
          symbol = " ";
        };
        rust = {
          symbol = "󱘗 ";
        };
        scala = {
          symbol = " ";
        };
        swift = {
          symbol = " ";
        };
        zig = {
          symbol = " ";
        };
        gradle = {
          symbol = " ";
        };
      };
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
      default.path = toString (tomlFmt.generate "starship.toml" config.settings);
      description = "The starship configuration file.";
    };
  };

  config = {
    package = lib.mkDefault pkgs.starship;
    env.STARSHIP_CONFIG = config.configFile.path;
    meta.platforms = lib.platforms.all;
  };
}
