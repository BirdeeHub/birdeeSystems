{ inputs, ... }:
{
  config,
  lib,
  wlib,
  pkgs,
  ...
}:
let
  inherit (pkgs.callPackage "${wlib.modulesPath}/docs/per-mod" { inherit lib wlib; }) wrapperModuleMD;
  buildModuleDocs =
    {
      prefix ? "",
      title ? null,
      package ? null,
      includeCore ? true,
      descriptionStartsOpen ? null,
      descriptionIncluded ? null,
      moduleStartsOpen ? null,
    }:
    name: module:
    pkgs.runCommand "${name}-${prefix}-docs"
      {
        passAsFile = [ "modDoc" ];
        modDoc = wrapperModuleMD (
          wlib.evalModule [
            module
            {
              _module.check = false;
              inherit pkgs;
              ${if package != null then "package" else null} = package;
            }
          ]
          // {
            inherit includeCore;
            ${if descriptionStartsOpen != null then "descriptionStartsOpen" else null} = descriptionStartsOpen;
            ${if descriptionIncluded != null then "descriptionIncluded" else null} = descriptionIncluded;
            ${if moduleStartsOpen != null then "moduleStartsOpen" else null} = moduleStartsOpen;
          }
        );
      }
      ''
        echo ${lib.escapeShellArg (if title != null then "# ${title}" else "# `${prefix}${name}`")} > $out
        echo >> $out
        cat "$modDocPath" >> $out
      '';

  module_docs = builtins.mapAttrs (buildModuleDocs {
    prefix = "wlib.modules.";
    package = pkgs.hello;
    includeCore = false;
    moduleStartsOpen = _: _: true;
    descriptionStartsOpen =
      _: _: _:
      true;
    descriptionIncluded =
      _: _: _:
      true;
  }) wlib.modules;
  wrapper_docs = builtins.mapAttrs (buildModuleDocs {
    prefix = "wlib.wrapperModules.";
  }) wlib.wrapperModules;
in
{
  imports = [ ./module.nix ];
  books.nix-wrapper-modules = {
    book.book = {
      src = "src";
      authors = ["BirdeeHub"];
      language = "en";
      title = "nix-wrapper-modules";
    };
    book.output.html.git-repository-url = "https://github.com/BirdeeHub/nix-wrapper-modules";
    # "title"
    # "numbered"
    # "separator"
    # "prefix"
    # "suffix"
    # "draft"
    summary = [
      {
        data = "title";
        name = "nix-wrapper-modules";
      }
      {
        name = "Intro";
        data = "numbered";
        path = "md/intro.md";
        src = pkgs.runCommand "intro.md" { README = "${inputs.wrappers}/README.md"; } ''
          cat "$README" | sed 's|# \[nix-wrapper-modules\](https://birdeehub.github.io/nix-wrapper-modules/)|# [nix-wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules)|' > $out
        '';
      }
      {
        name = "Getting Started";
        data = "numbered";
        path = "md/getting-started.md";
        src = "${wlib.modulesPath}/docs/md/getting-started.md";
      }
      {
        name = "Lib Functions";
        data = "numbered";
        path = "md/lib-intro.md";
        src = "${wlib.modulesPath}/docs/md/lib-intro.md";
        subchapters = [
          {
            name = "wlib";
            data = "numbered";
            path = "lib/wlib.md";
            src = pkgs.runCommand "wrapper-lib-docs" { } ''
              ${pkgs.nixdoc}/bin/nixdoc --category "" --description '`wlib` main set documentation' --file "${inputs.wrappers}/lib/lib.nix" --prefix "wlib" >> $out
            '';
          }
          {
            name = "types";
            data = "numbered";
            path = "lib/types.md";
            src = pkgs.runCommand "wrapper-types-docs" { } ''
              ${pkgs.nixdoc}/bin/nixdoc --category "types" --description '`wlib.types` set documentation' --file "${inputs.wrappers}/lib/types.nix" --prefix "wlib" >> $out
            '';
          }
          {
            name = "dag";
            data = "numbered";
            path = "lib/dag.md";
            src = pkgs.runCommand "wrapper-dag-docs" { } ''
              ${pkgs.nixdoc}/bin/nixdoc --category "dag" --description '`wlib.dag` set documentation' --file "${inputs.wrappers}/lib/dag.nix" --prefix "wlib" >> $out
            '';
          }
        ];
      }
      {
        name = "Core Options Set";
        data = "numbered";
        path = "lib/core.md";
        src = buildModuleDocs {
          prefix = "";
          package = pkgs.hello;
          title = "Core (builtin) Options set";
        } "core" wlib.core;
      }
      {
        name = "`wlib.modules.default`";
        data = "numbered";
        path = "modules/default.md";
        src = module_docs.default;
      }
      {
        name = "Helper Modules";
        data = "numbered";
        path = "md/helper-modules.md";
        src = "${wlib.modulesPath}/docs/md/helper-modules.md";
        subchapters = lib.mapAttrsToList (n: v: {
          name = n;
          data = "numbered";
          path = "modules/${n}.md";
          src = v;
        }) (removeAttrs module_docs [ "default" ]);
      }
      {
        name = "Wrapper Modules";
        data = "numbered";
        path = "md/wrapper-modules.md";
        src = "${wlib.modulesPath}/docs/md/wrapper-modules.md";
        subchapters = lib.mapAttrsToList (n: v: {
          name = n;
          data = "numbered";
          path = "wrapperModules/${n}.md";
          src = v;
        }) wrapper_docs;
      }
    ];
  };
}
