-- [[ Configure LSP ]]

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
  -- clangd = {},
  -- gopls = {},
  -- pyright = {},
  -- rust_analyzer = {},
  -- tsserver = {},
  -- html = { filetypes = { 'html', 'twig', 'hbs'} },
  jdtls = {
    filetypes = { "kotlin", "java" },
    workspace = { checkThirdParty = false },
  },
  kotlin_language_server = {
    filetypes = { "kotlin" },
    kotlin = {
      -- formatters = {
      --   ignoreComments = true,
      -- },
      signatureHelp = { enabled = true }
    },
    workspace = { checkThirdParty = false },
    telemetry = { enabled = false }
  },
  lua_ls = {
    Lua = {
      formatters = {
        ignoreComments = true,
      },
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = require("cap-onattach").get_capabilities(),
      -- on_attach = require("cap-onattach").on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end
}

-- require'lspconfig'.jdtls.setup {
--   capabilities = require("birdee.lsp.birdeelspconfigs").get_capabilities(),
--   on_attach = require("birdee.lsp.birdeelspconfigs").on_attach,
--   filetypes = { "kotlin", "java" },
--   settings = {
--     java = {
--       formatters = {
--         ignoreComments = true,
--       },
--       signatureHelp = { enabled = true },
--     },
--     workspace = { checkThirdParty = true },
--     telemetry = { enabled = false },
--   },
-- }
-- require'lspconfig'.kotlin_language_server.setup {
--   capabilities = require("birdee.lsp.birdeelspconfigs").get_capabilities(),
--   on_attach = require("birdee.lsp.birdeelspconfigs").on_attach,
--   filetypes = { "kotlin" },
--   settings = {
--     kotlin = {
--       formatters = {
--         ignoreComments = true,
--       },
--       signatureHelp = { enabled = true },
--     },
--     workspace = { checkThirdParty = false },
--     telemetry = { enabled = false },
--   }
-- }

--local autocmd = vim.api.nvim_create_autocmd
--autocmd("FileType", {
--    pattern = "kotlin",
--    callback = function()
--        local root_dir = vim.fs.dirname(
--            vim.fs.find({ 'mvnw', 'gradlew', '.git' }, { upward = true })[1]
--        )
--        local client = vim.lsp.start({
--            name = 'kotlin-language-server',
--            cmd = { 'kotlin-language-server' },
--            root_dir = root_dir,
--        })
--        if(client ~= nil)
--        then
--          vim.lsp.buf_attach_client(0, client)
--        end
--    end
--})

