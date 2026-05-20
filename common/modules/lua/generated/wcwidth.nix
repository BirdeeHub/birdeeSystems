{ buildLuarocksPackage, fetchFromGitHub, fetchurl, luaOlder }:
buildLuarocksPackage {
  pname = "wcwidth";
  version = "0.5-1";
  knownRockspec = (fetchurl {
    url    = "mirror://luarocks/wcwidth-0.5-1.rockspec";
    sha256 = "0hyl8f3fvmiq2grhafz1cbnkp60mb58y2p8jg7yafin9kk69zg64";
  }).outPath;
  src = fetchFromGitHub {
    owner = "aperezdc";
    repo = "lua-wcwidth";
    tag = "v0.5";
    hash = "sha256-q2M2bE11c/Eg9akACaGYoB+8yTlgppGURUUxKhBuwqs=";
  };

  disabled = luaOlder "5.1";

  meta = {
    homepage = "https://github.com/aperezdc/lua-wcwidth";
    license.fullName = "MIT/X11";
    description = "Pure Lua implementation of the wcwidth() function";
  };
}
