{
  graph = [
    {
      disabled = false;
      file = "<unknown-file>";
      imports = [ ];
      key = ":anon-1";
    }
    {
      disabled = false;
      file = "/nix/store/5wrajzbddlpixvjf3zshrxwd1b1fh5pq-source/parts.nix";
      imports = [
        {
          disabled = false;
          file = "/nix/store/5wrajzbddlpixvjf3zshrxwd1b1fh5pq-source/lib/core.nix";
          imports = [ ];
          key = "/nix/store/5wrajzbddlpixvjf3zshrxwd1b1fh5pq-source/lib/core.nix";
        }
      ];
      key = ":anon-2";
    }
    {
      disabled = false;
      file = "<unknown-file>";
      imports = [ ];
      key = ":anon-3";
    }
    {
      disabled = false;
      file = "/nix/store/grpw7h19fprplgy33kmrs56i9x8db86m-source/common/wrappers";
      imports = [
        {
          disabled = false;
          file = "/nix/store/grpw7h19fprplgy33kmrs56i9x8db86m-source/common/wrappers/git";
          imports = [
            {
              disabled = false;
              file = "/nix/store/5wrajzbddlpixvjf3zshrxwd1b1fh5pq-source/wrapperModules/g/git/module.nix";
              imports = [
                {
                  disabled = false;
                  file = "/nix/store/5wrajzbddlpixvjf3zshrxwd1b1fh5pq-source/modules/default/module.nix";
                  imports = [
                    {
                      disabled = false;
                      file = "/nix/store/5wrajzbddlpixvjf3zshrxwd1b1fh5pq-source/modules/symlinkScript/module.nix";
                      imports = [ ];
                      key = "/nix/store/5wrajzbddlpixvjf3zshrxwd1b1fh5pq-source/modules/symlinkScript/module.nix";
                    }
                    {
                      disabled = false;
                      file = "/nix/store/5wrajzbddlpixvjf3zshrxwd1b1fh5pq-source/modules/makeWrapper/module.nix";
                      imports = [
                        {
                          disabled = false;
                          file = "/nix/store/5wrajzbddlpixvjf3zshrxwd1b1fh5pq-source/modules/makeWrapper/module.nix";
                          imports = [ ];
                          key = "/nix/store/5wrajzbddlpixvjf3zshrxwd1b1fh5pq-source/modules/makeWrapper/module.nix:anon-1";
                        }
                      ];
                      key = "/nix/store/5wrajzbddlpixvjf3zshrxwd1b1fh5pq-source/modules/makeWrapper/module.nix";
                    }
                  ];
                  key = "/nix/store/5wrajzbddlpixvjf3zshrxwd1b1fh5pq-source/modules/default/module.nix";
                }
              ];
              key = "/nix/store/5wrajzbddlpixvjf3zshrxwd1b1fh5pq-source/wrapperModules/g/git/module.nix";
            }
          ];
          key = "/nix/store/grpw7h19fprplgy33kmrs56i9x8db86m-source/common/wrappers/git";
        }
      ];
      key = ":anon-4";
    }
    {
      disabled = false;
      file = "REPLFILE";
      imports = [ ];
      key = ":anon-5";
    }
  ];
  meta = {
    "/nix/store/5wrajzbddlpixvjf3zshrxwd1b1fh5pq-source/lib/core.nix" = {
      description = { pre = "# Core (builtin) Options set\n\nThese are the core options that make everything else possible.\n\nThey include the `.extendModules`, `.apply`, `.eval`, and `.wrap` functions, and the `.wrapper` itself\n\nThey are always imported with every module evaluation.\n\nThey are somewhat minimal by design. They pertain to building the derivation, not the wrapper script.\n\nThe default `builderFunction` value provides no options.\n\nThe default `wrapperFunction` is null.\n\n`wlib.modules.default` provides great values for these options, and creates many more for you to use.\n\nBut you may want to wrap your package via different means, provide different options, or provide modules for others to use to help do those things!\n\nDoing it this way allows wrapper modules to do anything you might wish involving wrapping some source/package in a derivation.\n\nExcited to see what ways to use these options everyone comes up with! Docker helpers? BubbleWrap? If it's a derivation, it should be possible!\n\n---\n"; };
      file = "/nix/store/5wrajzbddlpixvjf3zshrxwd1b1fh5pq-source/lib/core.nix";
      maintainers = [
        {
          email = null;
          file = "/nix/store/5wrajzbddlpixvjf3zshrxwd1b1fh5pq-source/lib/core.nix";
          github = "BirdeeHub";
          githubId = 85372418;
          matrix = null;
          name = "birdee";
        }
      ];
    };
    "/nix/store/5wrajzbddlpixvjf3zshrxwd1b1fh5pq-source/modules/default/module.nix" = {
      description = { pre = "This module imports both `wlib.modules.makeWrapper` and `wlib.modules.symlinkScript` for convenience\n\n## `wlib.modules.makeWrapper`\n\nAn implementation of the `makeWrapper` interface via type safe module options.\n\nAllows you to choose one of several underlying implementations of the `makeWrapper` interface.\n\nWherever the type includes `DAG` you can mentally substitute this with `attrsOf`\n\nWherever the type includes `DAL` or `DAG list` you can mentally substitute this with `listOf`\n\nHowever they also take items of the form `{ data, name ? null, before ? [], after ? [] }`\n\nThis allows you to specify that values are added to the wrapper before or after another value.\n\nThe sorting occurs across ALL the options, thus you can target items in any `DAG` or `DAL` within this module from any other `DAG` or `DAL` option within this module.\n\nThe `DAG`/`DAL` entries in this module also accept an extra field, `esc-fn ? null`\n\nIf defined, it will be used instead of the value of `options.escapingFunction` to escape that value.\n\n## `wlib.modules.symlinkScript`\n\nAdds extra options compared to the default `builderFunction` option value.\n\n---\n"; };
      file = "/nix/store/5wrajzbddlpixvjf3zshrxwd1b1fh5pq-source/modules/default/module.nix";
      maintainers = [
        {
          email = null;
          file = "/nix/store/5wrajzbddlpixvjf3zshrxwd1b1fh5pq-source/modules/default/module.nix";
          github = "BirdeeHub";
          githubId = 85372418;
          matrix = null;
          name = "birdee";
        }
      ];
    };
    "/nix/store/5wrajzbddlpixvjf3zshrxwd1b1fh5pq-source/modules/makeWrapper/module.nix" = {
      description = {
        post = "---\n\n## The `makeWrapper` library:\n\nShould you ever need to redefine `config.wrapperFunction`, or use these options somewhere else,\nthis module doubles as a library for doing so!\n\n`makeWrapper = import wlib.modules.makeWrapper;`\n\nIf you import it like shown, you gain access to some values.\n\nFirst, you may modify the module itself.\n\nFor this it offers:\n\n`exclude_wrapper = true;` to stop it from setting `config.wrapperFunction`\n\n`wrapperFunction = ...;` to override the default `config.wrapperFunction` that it sets instead of excluding it.\n\n`exclude_meta = true;` to stop it from setting any values in `config.meta`\n\n`excluded_options = { ... };` where you may include `optionname = true`\nin order to not define that option.\n\nIn order to change these values, you change them in the set before importing the module like so:\n\n```nix\n  imports = [ (import wlib.modules.makeWrapper // { excluded_options.wrapperVariants = true; }) ];\n```\n\nIt also offers 4 functions for using those options to generate build instructions for a wrapper\n\n- `wrapAll`: generates build instructions for the main target and all variants\n- `wrapMain`: generates build instructions for the main target\n- `wrapVariants`: generates build instructions for all variants but not the main target\n- `wrapVariant`: generates build instructions for a single variant\n\nAll 4 of them return a string that can be added to the derivation definition to build the specified wrappers.\n\nThe first 3, `wrapAll`, `wrapMain`, and `wrapVariants`, are used like this:\n\n(import wlib.modules.makeWrapper).wrapAll {\n  inherit config wlib;\n  inherit (pkgs) callPackage; # or `inherit pkgs`;\n};\n\nThe 4th, `wrapVariant`, has an extra `name` argument:\n\n(import wlib.modules.makeWrapper).wrapVariant {\n  inherit config wlib;\n  inherit (pkgs) callPackage; # or `inherit pkgs`;\n  name = \\\"attribute\\\";\n};\n\nWhere `attribute` is an attribute of the `config.wrapperVariants` set\n\nOther than whatever options from the `wlib.modules.makeWrapper` module\nare defined in the `config` variable passed,\neach one relies on `config` containing `binName`, `package`, and `exePath`.\n\nIf `config.exePath` is not a string or is an empty string,\n`config.package` will be the full path wrapped.\nOtherwise, it will wrap `\"\${config.package}/\${config.binName}`.\n\nIf `config.binName` or `config.package` are not provided it will return an empty string for that target.\n\nIn addition, if a variant has `enable` set to `false`, it will also not be included in the returned string.\n";
        pre = "An implementation of the `makeWrapper` interface via type safe module options.\n\nAllows you to choose one of several underlying implementations of the `makeWrapper` interface.\n\nImported by `wlib.modules.default`\n\nWherever the type includes `DAG` you can mentally substitute this with `attrsOf`\n\nWherever the type includes `DAL` or `DAG list` you can mentally substitute this with `listOf`\n\nHowever they also take items of the form `{ data, name ? null, before ? [], after ? [] }`\n\nThis allows you to specify that values are added to the wrapper before or after another value.\n\nThe sorting occurs across ALL the options, thus you can target items in any `DAG` or `DAL` within this module from any other `DAG` or `DAL` option within this module.\n\nThe `DAG`/`DAL` entries in this module also accept an extra field, `esc-fn ? null`\n\nIf defined, it will be used instead of the value of `options.escapingFunction` to escape that value.\n\nIt also has a set of submodule options under `config.wrapperVariants` which allow you\nto duplicate the effects to other binaries from the package, or add extra ones.\n\nEach one contains an `enable` option, and a `mirror` option.\n\nThey also contain the same options the top level module does, however if `mirror` is `true`,\nas it is by default, then they will inherit the defaults from the top level as well.\n\nThey also have their own `package`, `exePath`, and `binName` options, with sensible defaults.\n\n---\n";
      };
      file = "/nix/store/5wrajzbddlpixvjf3zshrxwd1b1fh5pq-source/modules/makeWrapper/module.nix";
      maintainers = [
        {
          email = null;
          file = "/nix/store/5wrajzbddlpixvjf3zshrxwd1b1fh5pq-source/modules/makeWrapper/module.nix";
          github = "BirdeeHub";
          githubId = 85372418;
          matrix = null;
          name = "birdee";
        }
      ];
    };
    "/nix/store/5wrajzbddlpixvjf3zshrxwd1b1fh5pq-source/modules/symlinkScript/module.nix" = {
      description = { pre = "Adds extra options compared to the default `builderFunction` option value.\n\nImported by `wlib.modules.default`\n\n---\n"; };
      file = "/nix/store/5wrajzbddlpixvjf3zshrxwd1b1fh5pq-source/modules/symlinkScript/module.nix";
      maintainers = [
        {
          email = null;
          file = "/nix/store/5wrajzbddlpixvjf3zshrxwd1b1fh5pq-source/modules/symlinkScript/module.nix";
          github = "BirdeeHub";
          githubId = 85372418;
          matrix = null;
          name = "birdee";
        }
      ];
    };
    "/nix/store/5wrajzbddlpixvjf3zshrxwd1b1fh5pq-source/wrapperModules/g/git/module.nix" = {
      description = { pre = "Nix uses git for all sorts of things. Including fetching flakes!\n\nSo if you put this one in an overlay, name it something other than `pkgs.git`!\n\nOtherwise you will probably get infinite recursion.\n\nThe vast majority of other packages do not have this issue. And,\ndue to the passthrough of `.override` and `.overrideAttrs`,\nmost other packages are safe to replace with their wrapped counterpart in overlays directly.\n"; };
      file = "/nix/store/5wrajzbddlpixvjf3zshrxwd1b1fh5pq-source/wrapperModules/g/git/module.nix";
      maintainers = [
        {
          email = null;
          file = "/nix/store/5wrajzbddlpixvjf3zshrxwd1b1fh5pq-source/wrapperModules/g/git/module.nix";
          github = "BirdeeHub";
          githubId = 85372418;
          matrix = null;
          name = "birdee";
        }
      ];
    };
  };
}
