if not require('nixCatsUtils').isNixCats then
  -- mason-lspconfig requires that these setup functions are called in this order
  -- before setting up the servers.
  require('mason').setup()
  require('mason-lspconfig').setup()
end

local servers = {}
if (nixCats('neonixdev')) then
  require('neodev').setup({})
  -- this allows our thing to have plugin library detection
  -- despite not being in our .config/nvim folder
  -- I learned about it here:
  -- https://github.com/lecoqjacob/nixCats-nvim/blob/main/.neoconf.json
  require("neoconf").setup({
    plugins = {
      lua_ls = {
        enabled = true,
        enabled_for_neovim_config = true,
      },
    },
  })
  servers.lua_ls = {
    Lua = {
      formatters = {
        ignoreComments = true,
      },
      signatureHelp = { enabled = true },
      diagnostics = {
        globals = { "nixCats" },
      },
    },
    workspace = { checkThirdParty = true },
    telemetry = { enabled = false },
    filetypes = { 'lua' },
  }
  if require('nixCatsUtils').isNixCats then servers.nixd = {}
  else servers.rnix = {}
  end
  servers.nil_ls = {}

elseif (nixCats('nix')) then
  servers.nixd = {}
  servers.nil_ls = {}
elseif (nixCats('lua')) then
  servers.lua_ls = {
    Lua = {
      formatters = {
        ignoreComments = true,
      },
      signatureHelp = { enabled = true },
    },
    workspace = { checkThirdParty = true },
    telemetry = { enabled = false },
    filetypes = { 'lua' },
  }
end
if (nixCats('kotlin')) then
  servers.kotlin_language_server = {
    Lua = {
      formatters = {
        ignoreComments = true,
      },
      signatureHelp = { enabled = true },
    },
    workspace = { checkThirdParty = true },
    telemetry = { enabled = false },
    filetypes = { 'kotlin' },
    root_pattern = {"settings.gradle", "settings.gradle.kts", 'gradlew', 'mvnw'},
  }
end
if (nixCats('java')) then
local userHome = vim.fn.expand('$HOME')
  servers.jdtls = {
    Lua = {
      formatters = {
        ignoreComments = true,
      },
      signatureHelp = { enabled = true },
    },
    workspace = { checkThirdParty = true },
    telemetry = { enabled = false },
    filetypes = { "kotlin", "java" },
    cmd = { "jdt-language-server", "-configuration", userHome .."/.cache/jdtls/config", "-data", userHome .."/.cache/jdtls/workspace" },
  }
end
if (require('nixCatsUtils').isNixCats and nixCats('lspDebugMode')) then
  vim.lsp.set_log_level("debug")
end

-- This is this flake's version of what kickstarter has set up for mason handlers.
-- This is a convenience function that calls lspconfig on the lsps we downloaded via nix
-- This will not download your lsp. Nix does that.

--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--  All of them are listed in https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
--  You may do the same thing with cmd

-- servers.clangd = {},
-- servers.gopls = {},
-- servers.pyright = {},
-- servers.rust_analyzer = {},
-- servers.tsserver = {},
-- servers.html = { filetypes = { 'html', 'twig', 'hbs'} },

if not require('nixCatsUtils').isNixCats then
  -- Ensure the servers above are installed
  local mason_lspconfig = require 'mason-lspconfig'

  mason_lspconfig.setup {
    ensure_installed = vim.tbl_keys(servers),
  }

  mason_lspconfig.setup_handlers {
    function(server_name)
      require('lspconfig')[server_name].setup {
        capabilities = require('caps-onattach').get_capabilities(),
        on_attach = require('caps-onattach').on_attach,
        settings = servers[server_name],
        filetypes = (servers[server_name] or {}).filetypes,
      }
    end,
  }
else
  for server_name,_ in pairs(servers) do
    require('lspconfig')[server_name].setup({
      capabilities = require('caps-onattach').get_capabilities(),
      on_attach = require('caps-onattach').on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
      cmd = (servers[server_name] or {}).cmd,
      root_pattern = (servers[server_name] or {}).root_pattern,
    })
  end
end
