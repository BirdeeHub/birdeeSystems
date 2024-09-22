{
	description = ''
		Android development environment
		NOT MY WORK
		ALL CREDIT TO https://git.voronind.com/voronind
	'';

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
	};

	outputs = { self, nixpkgs } @inputs: let
		system = "x86_64-linux";
		lib    = nixpkgs.lib;
		pkgs = import nixpkgs {
			system = system;
			config = {
				allowUnfree                = true;
				android_sdk.accept_license = true;
			};
		};
		jdk        = pkgs.jdk11;
		buildTools = "31.0.0";
		androidComposition = pkgs.androidenv.composeAndroidPackages {
			abiVersions          = [ "armeabi-v7a" "arm64-v8a" ];
			buildToolsVersions   = [ buildTools ];
			cmdLineToolsVersion  = "8.0";
			includeEmulator      = false;
			includeNDK           = false;
			includeSources       = false;
			includeSystemImages  = false;
			platformToolsVersion = "34.0.5";
			platformVersions     = [ "31" ];
			toolsVersion         = "26.1.1";
			useGoogleAPIs        = false;
			useGoogleTVAddOns    = false;
			# cmakeVersions        = [ "3.10.2" ];
			# emulatorVersion      = "30.3.4";
			# includeExtras        = [ "extras;google;gcm" ];
			# ndkVersions          = ["22.0.7026061"];
			# systemImageTypes     = [ "google_apis_playstore" ];
		};
		androidSdk = androidComposition.androidsdk;
		tex = (pkgs.texlive.combine {
			inherit (pkgs.texlive) scheme-basic
				amsmath
				babel
				capt-of
				catchfile
				collection-fontsextra
				cyrillic
				dvipng
				dvisvgm
				environ
				etoolbox
				fancyhdr
				fontspec
				geometry
				hyperref
				luacode
				luatexbase
				montserrat
				parskip
				pgf
				tcolorbox
				tocloft
				ulem
				wrapfig
				xcolor;

				#(setq org-latex-compiler "lualatex")
				#(setq org-preview-latex-default-process 'dvisvgm)
		});
	in {
		devShells.${system} = {
			dev = pkgs.mkShell rec {
				nativeBuildInputs = with pkgs; [
					android-tools
					androidSdk
					glibc
					gnumake
					jdk
					jq # For curl scripts.
				];
				buildInputs = with pkgs; [];

				GRADLE_OPTS      = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidSdk}/libexec/android-sdk/build-tools/${buildTools}/aapt2";
				JAVA_HOME        = "${jdk}";
				LD_LIBRARY_PATH  = "${lib.makeLibraryPath buildInputs}";
				ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk/";
				DEVSHELL = 0;
				shellHook = ''
					exec ${pkgs.zsh}/bin/zsh
				'';
			};

			doc = pkgs.mkShell rec {
				nativeBuildInputs = with pkgs; [
					gnumake
					jdk
					tex
				];
				buildInputs = with pkgs; [];

				JAVA_HOME = "${jdk}";
				DEVSHELL = 0;
				shellHook = ''
					exec ${pkgs.zsh}/bin/zsh
				'';
			};
		};
	};
}
