{
  lib,
  collectOptions,
  ...
}:
{
  graph,
  options,
  ...
}:
let
  get-meta =
    descs: authors:
    let
      zipper = builtins.zipAttrsWith (
        file: xs: {
          inherit file;
          description = builtins.foldl' (
            acc: v:
            acc
            // {
              ${if v.desc.pre or "" != "" then "pre" else null} = (if acc.desc.pre or "" != "" then acc.desc.pre + "\n\n" else "") + v.desc.pre;
              ${if v.desc.post or "" != "" then "post" else null} = (if acc.desc.post or "" != "" then acc.desc.post + "\n\n" else "") + v.desc.post;
            }
          ) { } xs;
          maintainers = builtins.filter (v: v != null) (map (v: v.ppl or null) xs);
        }
      );
      descriptions = map (v: {
        ${v.file} = {
          desc = v;
        };
      }) descs;
      maintainers = map (v: {
        ${v.file} = {
          ppl = v;
        };
      }) authors;
    in
    zipper (descriptions ++ maintainers);

  # associate module files from graph with items in meta-info
  # all imports get grouped until the next one with an item in meta-info is found
  # merge the associated file paths into your meta-info for each item
  associate =
    let
      mergemeta =
        meta: file: new:
        meta
        // {
          ${file} = meta.${file} or { } // {
            associated = meta.${file}.associated or [ ] ++ [ new ];
          };
        };
      associate' =
        current:
        builtins.foldl' (
          acc: v:
          if acc.${v.file} or null != null then
            associate' v.file (mergemeta acc v.file v.file) v.imports
          else if current == null then
            associate' current (mergemeta acc v.file v.file) v.imports
          else
            associate' current (mergemeta acc current v.file) v.imports
        );
    in
    associate' null;

  # This will be used to sort the options from collectOptions
  modules-by-meta = lib.pipe (get-meta options.meta.description.value options.meta.maintainers.value) [
    (v: associate v graph)
    (lib.mapAttrsToList (file: v: if v ? file then v else v // { inherit file; }))
  ];

  og_options = collectOptions {
    inherit options;
    transform = x: if builtins.elem "_module" x.loc then [ ] else [ x ];
  };
  partitioned = lib.partition (
    v: v.internal or false == true || v.visible or true == false
  ) og_options;
  invisible = lib.partition (v: v.internal or false == true) partitioned.right;
  internal = invisible.right;
  hidden = invisible.wrong;
  visible = partitioned.wrong;
  # TODO: put them with their associated meta info
in
{
  inherit modules-by-meta;
}
