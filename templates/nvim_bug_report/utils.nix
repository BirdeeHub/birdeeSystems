with builtins; {
  mkCFG = toLua: path: nixvals:
    /*lua*/''
      -- create require('nixvals') table
      package.preload["nixvals"] = function()
        return ${toLua nixvals}
      end
      -- load current directory as config directory
      vim.opt.rtp:remove(vim.fn.stdpath("config"))
      vim.opt.packpath:remove(vim.fn.stdpath("config"))
      vim.opt.rtp:remove(vim.fn.stdpath("config") .. "/after")
      vim.opt.rtp:prepend("${path}")
      vim.opt.packpath:prepend("${path}")
      vim.opt.rtp:append("${path}/after")
      if vim.fn.filereadable("${path}/init.lua") == 1 then
        dofile("${path}/init.lua")
      end
    '';
  ezPluginOverlay = inputs:
  (self: super:
  let
    inherit (super.vimUtils) buildVimPlugin;
    plugins = builtins.filter
      (s: (builtins.match "plugins-.*" s) != null)
      (builtins.attrNames inputs);
    plugName = input:
      builtins.substring
        (builtins.stringLength "plugins-")
        (builtins.stringLength input)
        input;
    plugAttrName = input: builtins.replaceStrings [ "." ] [ "-" ] (plugName input);
    buildPlug = name: buildVimPlugin {
      pname = plugName name;
      version = "master";
      src = builtins.getAttr name inputs;
    };
  in
  {
    neovimPlugins = builtins.listToAttrs (map
      (plugin: {
        name = plugAttrName plugin;
        value = buildPlug plugin;
      })
      plugins);
  });
}
