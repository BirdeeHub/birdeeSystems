{
  wlib,
  lib,
  normWrapperDocs,
}:
{ options, graph, ... }:
let
  renderVal =
    v:
    if v ? _type && v ? text then
      if v._type == "literalExpression" then "`${toString v.text}`" else toString v.text
    else if lib.isStringLike v && !builtins.isString v then
      builtins.unsafeDiscardStringContext "<${v.name or v}>"
    else
      v;
  normed = normWrapperDocs { inherit options graph; };
in
normed
