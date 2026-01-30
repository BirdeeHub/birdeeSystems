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
  coredocs = {
    core = buildModuleDocs {
      prefix = "";
      package = pkgs.hello;
      title = "Core (builtin) Options set";
    } "core" wlib.core;
  };

  libdocs = {
    dag = pkgs.runCommand "wrapper-dag-docs" { } ''
      ${pkgs.nixdoc}/bin/nixdoc --category "dag" --description '`wlib.dag` set documentation' --file "${wlib.modulesPath}/lib/dag.nix" --prefix "wlib" >> $out
    '';
    wlib = pkgs.runCommand "wrapper-lib-docs" { } ''
      ${pkgs.nixdoc}/bin/nixdoc --category "" --description '`wlib` main set documentation' --file "${wlib.modulesPath}/lib/lib.nix" --prefix "wlib" >> $out
    '';
    types = pkgs.runCommand "wrapper-types-docs" { } ''
      ${pkgs.nixdoc}/bin/nixdoc --category "types" --description '`wlib.types` set documentation' --file "${wlib.modulesPath}/lib/types.nix" --prefix "wlib" >> $out
    '';
  };
in
{
  imports = [ ./module.nix ];
  books.nix-wrapper-modules = {
    book.book.src = "src";
    # "prefix"
    # "suffix"
    # "title"
    # "numbered"
    # "draft"
    # "separator"
    summary = [
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
