{
  lib,
  writeShellScriptBin,
  writeText,
  alacritty,
  fontconfig,
  libGL,
  alacrittyfontpackage ? null,
  nerdfonts,
  nerdfontsfontstrs ? [ "FiraMono" "Go-Mono" ],
  zsh,
  shell ? "zsh",
  shellArgs ? [ "-l" ],
  italic ? "FiraMono Nerd Font",
  italic_style ? "Italic",
  bold_italic ? "FiraMono Nerd Font",
  bold_italic_style ? "Bold Italic",
  bold ? "FiraMono Nerd Font",
  bold_style ? "Bold",
  normal ? "FiraMono Nerd Font",
  normal_style ? "Regular",
  size ? "11.0",
  extraPATH ? [],
  extraLIB ? [],
  extraTOML ? ""
}:
let

  alakitty-toml = /*toml*/''
    # https://alacritty.org/config-alacritty.html
    # [env]
    # TERM = "xterm-256color"

    [shell]
    program = "${zsh}/bin/${shell}"
    args = [ "${builtins.concatStringsSep ''" "'' shellArgs}" ]

    [font]
    size = ${size}

    [font.bold]
    family = "${bold}"
    style = "${bold_style}"

    [font.bold_italic]
    family = "${bold_italic}"
    style = "${bold_italic_style}"

    [font.italic]
    family = "${italic}"
    style = "${italic_style}"

    [font.normal]
    family = "${normal}"
    style = "${normal_style}"
  '';

  newFC = fontconfig.override {
    dejavu_fonts = {
      minimal =
        if alacrittyfontpackage != null then
          alacrittyfontpackage
        else
          (nerdfonts.override {
            fonts = nerdfontsfontstrs;
          });
    };
  };

  final-alakitty-toml = writeText "alacritty.toml" (builtins.concatStringsSep "\n" [ alakitty-toml extraTOML ]);

  final-alacritty = alacritty.override { fontconfig = newFC; };

  alakitty = writeShellScriptBin "alacritty" ''
    export PATH="${newFC}/bin:${lib.makeBinPath extraPATH}:$PATH"
    export LD_LIBRARY_PATH="${libGL}/bin:${lib.makeLibraryPath extraLIB}:$PATH"
    exec ${final-alacritty}/bin/alacritty --config-file ${final-alakitty-toml} "$@"
  '';
in
alakitty
