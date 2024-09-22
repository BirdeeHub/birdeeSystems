{
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
		flake-utils.url = "github:numtide/flake-utils";
		lua-fenster = {
			url = "github:jonasgeiler/lua-fenster";
			flake = false;
		};
	};
	outputs = inputs: let
		forEachSystem = inputs.flake-utils.lib.eachSystem inputs.flake-utils.lib.allSystems;
		buildFenster = pkgs: lua: lua.pkgs.buildLuarocksPackage {
			pname = "lua-fenster";
			version = "1.0.1-1";
			knownRockspec = "${inputs.lua-fenster}/fenster-dev-1.rockspec";
			src = inputs.lua-fenster;
			propagatedBuildInputs = [ pkgs.xorg.libX11 ];
			disabled = lua.pkgs.luaOlder "5.1";
			meta = {
				homepage = "https://github.com/jonasgeiler/lua-fenster";
				description = "The most minimal cross-platform GUI library - now in Lua!";
				license.fullName = "MIT";
			};
		};
	in (forEachSystem (system: let
		pkgs = import inputs.nixpkgs { inherit system; };
		thisLua = pkgs.lua5_3;
		lua-fenster = buildFenster pkgs thisLua;
		program = import ./. {
			inherit pkgs;
			inherit (pkgs) lib;
			appname = "ferret";
			source = ./src;
			extra_launcher_lua = "";
			extra_launcher_commands = "";
			args = [];
			to_bin = true;
			isJIT = false;
			luaEnv = thisLua.withPackages (lpkgs: with lpkgs; [
				luafilesystem
				cjson
				busted
				inspect
				http
				cqueues
				stdlib
				lua-fenster
			]);
			procPath = with pkgs; [
				coreutils
				findutils
				gnumake
				gnused
				gnugrep
				gawk
			];
		};
	in {
		packages = {
			inherit lua-fenster;
			default = program;
		};
	}) // { inherit buildFenster; });
}
