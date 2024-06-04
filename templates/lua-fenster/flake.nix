{
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
		flake-utils.url = "github:numtide/flake-utils";
		lua-fenster = {
			flake = false;
			url = "github:jonasgeiler/lua-fenster";
		};
	};
	outputs = inputs: let
		forEachSystem = inputs.flake-utils.lib.eachSystem inputs.flake-utils.lib.allSystems;
	in forEachSystem (system: let
		pkgs = import inputs.nixpkgs { inherit system; };
		fensterDrv = { buildLuarocksPackage, luaOlder, pkgs }:
			buildLuarocksPackage {
				pname = "fenster";
				version = "1.0.1-1";
				knownRockspec = "${inputs.lua-fenster}/fenster-dev-1.rockspec";
				src = inputs.lua-fenster;
				propagatedBuildInputs = [ pkgs.xorg.libX11 ];

				disabled = luaOlder "5.1";

				meta = {
					homepage = "https://github.com/jonasgeiler/lua-fenster";
					description = "The most minimal cross-platform GUI library - now in Lua!";
					license.fullName = "MIT";
				};
			};
		fenster = fensterDrv { inherit (pkgs.lua5_1.pkgs) buildLuarocksPackage luaOlder; inherit pkgs; };
	in {
		packages = {
			inherit fenster;
			default = fenster;
			lua = pkgs.lua5_1.withPackages (_: [ fenster ]);
		};
	});
}
