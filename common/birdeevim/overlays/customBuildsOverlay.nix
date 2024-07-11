importName: inputs: let
  overlay = self: super: { 
    ${importName} = {
		buildFenster = lua: lua.pkgs.buildLuarocksPackage {
			pname = "lua-fenster";
			version = "1.0.1-1";
			knownRockspec = "${inputs.lua-fenster}/fenster-dev-1.rockspec";
			src = inputs.lua-fenster;
			propagatedBuildInputs = [ self.xorg.libX11 ];
			disabled = lua.pkgs.luaOlder "5.1";
			meta = {
				homepage = "https://github.com/jonasgeiler/lua-fenster";
				description = "The most minimal cross-platform GUI library - now in Lua!";
				license.fullName = "MIT";
			};
		};
    };
  };
in
overlay
