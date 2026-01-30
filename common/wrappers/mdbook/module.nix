{
  config,
  lib,
  wlib,
  pkgs,
  ...
}@top:
let
  summaryType = lib.types.listOf (wlib.types.spec {
    options.data = lib.mkOption {
      type = lib.types.enum [
        "prefix"
        "suffix"
        "title"
        "numbered"
        "draft"
        "separator"
      ];
    };
    options.name = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
    options.before = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    options.after = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    options.subchapters = lib.mkOption {
      type = summaryType;
      default = [ ];
    };
    options.path = lib.mkOption {
      type = lib.types.nullOr wlib.types.nonEmptyLine;
      default = null;
    };
    options.src = lib.mkOption {
      type = lib.types.nullOr wlib.types.stringable;
      default = null;
    };
  });

  renderBook =
    subdir: book_src: summary: summaryVarname: bookVarname:
    let
      renderItemSummary =
        node:
        assert
          (node.depth or null != null) || throw "Type error: node must have depth given by sortBook function";
        let
          genStr = str: num: builtins.concatStringsSep "" (builtins.genList (_: str) num);
          i = genStr "  " node.depth;
        in
        if node.data == "title" then
          assert (node.name != null) || throw "Type error: title node must have name";
          ''
            # ${toString node.name}
          ''
        else if node.data == "separator" then
          ''
            ---
          ''
        else if node.data == "prefix" || node.data == "suffix" then
          assert
            (node.name != null && node.path != null)
            || throw "Type error: prefix/suffix node must have name, and path";
          ''
            [${toString node.name}](${toString node.path})
          ''
        else if node.data == "draft" then
          assert (node.name != null) || throw "Type error: draft node must have name";
          ''
            ${i}- [${toString node.name}]()
          ''
        else if node.data == "numbered" then
          assert
            (node.name != null && node.path != null)
            || throw "Type error: numbered node must have name, and path";
          ''
            ${i}- [${toString node.name}](${toString node.path})
          ''
        else
          throw "Unknown summary type: ${node.data}";

      sortBook =
        let
          recsort =
            depth:
            lib.flip lib.pipe [
              (wlib.dag.unwrapSort "mdbook")
              (builtins.concatMap (
                v:
                [
                  (
                    v
                    // {
                      inherit depth;
                      subchapters = [ ];
                    }
                  )
                ]
                ++ recsort (depth + 1) (v.subchapters or [ ])
              ))
            ];
        in
        recsort 0;

      sortedBook = sortBook summary;
      bookSrc =
        "${placeholder "out"}/" + subdir + "/" + lib.removePrefix "/" (lib.removeSuffix "/" book_src);
      summaryMD = builtins.concatStringsSep "\n" (
        map (
          v:
          builtins.addErrorContext "while rendering summary item ${builtins.toJSON v}" (renderItemSummary v)
        ) sortedBook
      );
      mkLink =
        node:
        if node.src != null && node.path != null then
          let
            p = lib.escapeShellArg "${bookSrc}/${lib.removePrefix "/" node.path}";
          in
          ''
            mkdir -p "$(dirname ${p})"
            ln -s ${lib.escapeShellArg node.src} ${lib.escapeShellArg "${bookSrc}/${lib.removePrefix "/" node.path}"}
          ''
        else
          "";
      linkCmds = lib.pipe sortedBook [
        (map mkLink)
        (
          v:
          [
            "mkdir -p ${lib.escapeShellArg "${bookSrc}"}"
            (
              ''{ [ -e "$''
              + ''${summaryVarname}Path" ] && cat "$''
              + ''${summaryVarname}Path" || echo "$''
              + ''${summaryVarname}"; } > ${lib.escapeShellArg "${bookSrc}/SUMMARY.md"}''
            )
            (''json2toml "$'' + ''${bookVarname}Path" ${lib.escapeShellArg "${placeholder "out"}/${subdir}/book.toml"}'')
          ]
          ++ v
        )
        (builtins.concatStringsSep "\n")
      ];
    in
    {
      summaryMD = summaryMD;
      linkCmds = linkCmds;
    };

  tomltype = (pkgs.formats.toml { }).type;

  sanitizeShellVar =
    s:
    let
      splitter = builtins.split "([^A-Za-z0-9_]+)";
      genStr = str: num: builtins.concatStringsSep "" (builtins.genList (_: str) num);
      body = lib.pipe s [
        splitter
        (map (
          v:
          if builtins.isList v then
            let
              bad = builtins.concatStringsSep "" v;
            in
            genStr "_" (builtins.stringLength bad)
          else
            v
        ))
        (builtins.concatStringsSep "")
      ];
    in
    # ensure valid first character
    if builtins.match "[A-Za-z_].*" body != null then body else "_" + body;
in
{
  imports = [ wlib.modules.default ];
  options = {
    books = lib.mkOption {
      default = { };
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, config, ... }:
          let
            pages =
              renderBook config.generated-book-subdir config.book.book.src config.summary
                config.generated-summary-varname config.generated-book-json-varname;
          in
          {
            options = {
              book = lib.mkOption {
                type = lib.types.submodule {
                  freeformType = tomltype;
                  options.book = lib.mkOption {
                    type = lib.types.submodule {
                      freeformType = tomltype;
                      options.src = lib.mkOption {
                        type = wlib.types.nonEmptyLine;
                        default = "src";
                      };
                    };
                  };
                };
              };
              enable = lib.mkEnableOption "the book `${name}`" // {
                default = true;
              };
              summary = lib.mkOption {
                type = summaryType;
                default = [ ];
              };
              generatedSummary = lib.mkOption {
                type = lib.types.str;
                readOnly = true;
                internal = true;
                default = pages.summaryMD;
              };
              buildCommands = lib.mkOption {
                type = lib.types.str;
                readOnly = true;
                internal = true;
                default = pages.linkCmds;
              };
              generated-book-subdir = lib.mkOption {
                type = lib.types.str;
                readOnly = true;
                default = "${top.config.binName}-book-dir/${name}";
              };
              generated-book-json-varname = lib.mkOption {
                type = lib.types.str;
                readOnly = true;
                internal = true;
                default = "generated_book_json_${sanitizeShellVar name}";
              };
              generated-summary-varname = lib.mkOption {
                type = lib.types.str;
                readOnly = true;
                internal = true;
                default = "generated_summary_${sanitizeShellVar name}";
              };
            };
          }
        )
      );
    };
  };

  config = {
    wrapperVariants = builtins.mapAttrs (_: v: {
      config.appendFlag = [ "${placeholder "out"}/${v.generated-book-subdir}" ];
      options.addFlag = lib.mkOption {
        type = lib.types.listOf (
          wlib.types.spec {
            after = lib.mkDefault [ "build" ];
          }
        );
      };
      options.flags = lib.mkOption {
        type = lib.types.attrsOf (
          wlib.types.spec {
            after = lib.mkDefault [ "build" ];
          }
        );
      };
      config.enable = v.enable;
      config.flags.build = true;
      config.flags."-d" = {
        data = "\"$uservar\"";
        esc-fn = v: v;
      };
      config.runShell = [ "uservar=\${1:-_site}; shift 1" ];
      config.exePath = config.exePath;
    }) config.books;
    drv =
      builtins.foldl' (acc: v: acc // v) {} (lib.mapAttrsToList (_: v: { ${v.generated-summary-varname} = v.generatedSummary; ${v.generated-book-json-varname} = builtins.toJSON v.book; }) config.books)
      // {
        passAsFile = builtins.concatLists (lib.mapAttrsToList (_: v: [ v.generated-summary-varname v.generated-book-json-varname ]) config.books);
        nativeBuildInputs = [ pkgs.remarshal ];
        buildPhase =
          "runHook preBuild\n"
          + builtins.concatStringsSep "\n" (lib.mapAttrsToList (_: v: v.buildCommands) config.books)
          + "\nrunHook postBuild";
      };
    package = pkgs.mdbook;
    meta.maintainers = [ wlib.maintainers.birdee ];
  };
}
