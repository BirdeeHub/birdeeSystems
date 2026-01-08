{
  config,
  lib,
  wlib,
  pkgs,
  ...
}:
let
  summaryType =
    (
      wlib.types.dalOf
      // {
        modules = [
          {
            options.subchapters = lib.mkOption {
              type = lib.types.listOf summaryType;
              default = [ ];
            };
            options.path = lib.mkOption {
              type = lib.types.nullOr wlib.types.nonEmptyLine;
              default = null;
            };
            options.src = lib.mkOption {
              type = lib.types.nullOr (lib.types.addCheck wlib.types.stringable wlib.types.nonEmptyLine);
              default = null;
            };
          }
        ];
      }
    )
      (
        lib.types.enum [
          "prefix"
          "suffix"
          "title"
          "numbered"
          "draft"
          "separator"
        ]
      );

  renderBook =
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
              (
                dag:
                wlib.dag.sortAndUnwrap {
                  inherit dag;
                  name = "mdbook";
                }
              )
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
                ++ map (recsort depth + 1) v.subchapters
              ))
            ];
        in
        recsort 0;

      sortedBook = sortBook config.summary;
      bookSrc =
        "${placeholder "out"}/"
        + config.generated-book-subdir
        + "/"
        + lib.removePrefix "/" (lib.removeSuffix "/" config.book.book.src);
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
            mkdir -p "$(basename ${p})"
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
            ''cat { [ -e "$summaryMDPath" ] && cat "$summaryMDPath" || echo "$summaryMD"; } > ${lib.escapeShellArg "${bookSrc}/SUMMARY.md"}''
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

  jsontype = (pkgs.formats.json { }).type;
in
{
  imports = [ wlib.modules.default ];
  options = {
    book = lib.mkOption {
      type = lib.types.submodule {
        freeformType = jsontype;
        options.book = lib.mkOption {
          type = lib.types.submodule {
            freeformType = jsontype;
            options.src = lib.mkOption {
              type = wlib.types.nonEmptyLine;
              default = "src";
            };
          };
        };
      };
    };
    generated-book-subdir = {
      type = lib.types.str;
      readOnly = true;
      default = "${config.binName}-book-dir";
    };
    summary = lib.mkOption {
      type = summaryType;
      default = [ ];
    };
  };

  config = {
    env.MDBOOK_BOOK = builtins.toJSON config.book;
    drv = {
      inherit (config) generated-book-subdir;
      summaryMD = renderBook.summaryMD;
      passAsFile = [ "summaryMD" ];
      buildPhase = "runHook preBuild\n" + renderBook.linkCmds + "\nrunHook postBuild";
    };
    package = pkgs.mdbook;
    meta.maintainers = [ wlib.maintainers.birdee ];
  };
}
