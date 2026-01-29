{
  lib,
  wlib,
  collectOptions,
}:
{
  graph,
  options,
  config,
  ...
}:
let
  inherit (config) pkgs;
  meta-info =
    let
      zipper = builtins.zipAttrsWith (
        file: xs: {
          inherit file;
          description = builtins.foldl' (
            acc: v:
            acc
            // {
              ${if v.desc.pre or "" != "" then "pre" else null} = v.desc.pre;
              ${if v.desc.post or "" != "" then "post" else null} = v.desc.post;
            }
          ) { } xs;
          maintainers = builtins.filter (v: v != null) (map (v: v.ppl or null) xs);
        }
      );
      descriptions = map (v: {
        ${v.file} = {
          desc = v;
        };
      }) config.meta.description;
      maintainers = map (v: {
        ${v.file} = {
          ppl = v;
        };
      }) config.meta.maintainers;
    in
    zipper (descriptions ++ maintainers);

  # associate module files from graph with items in meta-info
  # all imports get grouped until the next one with an item in meta-info is found
  # merge the associated file paths into your meta-info for each item
  mergemeta =
    meta: file: new:
    meta
    // {
      ${file} = meta.${file} or { } // {
        associated = meta.${file}.associated or [ ] ++ [ new ];
      };
    };
  associate =
    current:
    builtins.foldl' (
      acc: v:
      if acc.${v.file} or null != null then
        associate v.file (mergemeta acc v.file { inherit (v) file key; }) v.imports
      else if current == null then
        associate current (mergemeta acc v.file { inherit (v) file key; }) v.imports
      else
        associate current (mergemeta acc current { inherit (v) file key; }) v.imports
    );

  # This will be used to sort the options from collectOptions
  modules-by-meta = builtins.attrValues (associate null meta-info graph);

  # og_options = collectOptions {
  #   inherit options;
  #   transform = x: if builtins.elem "_module" x.loc then [ ] else [ x ];
  # };
  # renderVal =
  #   v:
  #   if v ? _type && v ? text then
  #     if v._type == "literalExpression" then "`${toString v.text}`" else toString v.text
  #   else if lib.isStringLike v then
  #     "${toString v}"
  #   else
  #     v;
  # illiterate = map (v: builtins.mapAttrs (n: renderVal) v) og_options;
  # visible = lib.pipe illiterate [
  # ];
in
modules-by-meta
