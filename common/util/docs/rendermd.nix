{
  wlib,
  lib,
  normWrapperDocs,
}:
{ options, graph, ... }:
let
  sanitize =
    v:
    if v ? _type && v ? text then
      if v._type == "literalExpression" then "`${toString v.text}`" else toString v.text
    else if lib.isStringLike v && !builtins.isString v then
      builtins.unsafeDiscardStringContext "<${v.name or v}>"
    else if builtins.isString v then
      builtins.unsafeDiscardStringContext v
    else if builtins.isList v then
      map sanitize v
    else if lib.isFunction v then
      "<function with arguments ${lib.pipe v [
        lib.functionArgs
        (lib.mapAttrsToList (n: v: "${n}${lib.optionalString v "?"}"))
      ]}>"
    else if builtins.isAttrs v then
      builtins.mapAttrs (n: sanitize) v
    else
      v;
  normed = normWrapperDocs { inherit options graph; };
  cleaned = sanitize normed;
in
cleaned
