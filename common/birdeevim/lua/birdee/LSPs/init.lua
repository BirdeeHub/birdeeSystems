local catUtils = require('nixCatsUtils')
local servers = {}
if nixCats('neonixdev') then
  servers.lua_ls = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      formatters = {
        ignoreComments = true,
      },
      signatureHelp = { enabled = true },
      diagnostics = {
        globals = { "nixCats", "vim" },
        disable = { 'missing-fields' },
      },
      workspace = {
        checkThirdParty = false,
        library = {
          -- '${3rd}/luv/library',
          -- unpack(vim.api.nvim_get_runtime_file('', true)),
        },
      },
      completion = {
        callSnippet = 'Replace',
      },
      telemetry = { enabled = false },
    },
    filetypes = { 'lua' },
  }
  if catUtils.isNixCats then
    servers.nixd = {
      nixd = {
        nixpkgs = {
          expr = [[import (builtins.getFlake "]] .. nixCats("nixdExtras.nixpkgs") .. [[") { }   ]],
        },
        formatting = {
          command = { "nixfmt" }
        },
        options = {
          -- (builtins.getFlake "<path_to_system_flake>").legacyPackages.<system>.nixosConfigurations."<user@host>".options
          nixos = {
            expr = [[(builtins.getFlake "]] ..
              nixCats("nixdExtras.flake-path") .. [[").legacyPackages.]] ..
              nixCats("nixdExtras.system") .. [[.nixosConfigurations."]] ..
              nixCats("nixdExtras.systemCFGname") .. [[".options]]
          },
          -- (builtins.getFlake "<path_to_system_flake>").legacyPackages.<system>.homeConfigurations."<user@host>".options
          ["home-manager"] = {
            expr = [[(builtins.getFlake "]] ..
              nixCats("nixdExtras.flake-path") .. [[").legacyPackages.]] ..
              nixCats("nixdExtras.system") .. [[.homeConfigurations."]] ..
              nixCats("nixdExtras.homeCFGname") .. [[".options]]
          }
        },
        diagnostic = {
          suppress = {
            "sema-escaping-with"
          }
        }
      }
    }
    vim.api.nvim_create_user_command("StartNilLSP", function()
      require('lspconfig').nil_ls.setup({ capabilities = require('birdee.LSPs').get_capabilities('nil_ls') })
    end, { desc = 'Run nil-ls (when you really need docs for the builtins and nixd refuse)' })
  else
    servers.rnix = {}
    servers.nil_ls = {}
  end
elseif nixCats('nix') then
  servers.nixd = {}
  servers.nil_ls = {}
elseif nixCats('lua') then
  servers.lua_ls = {
    Lua = {
      formatters = {
        ignoreComments = true,
      },
      signatureHelp = { enabled = true },
      workspace = { checkThirdParty = true },
      telemetry = { enabled = false },
    },
    filetypes = { 'lua' },
  }
end
if nixCats('elixir') then
  servers.elixirls = {
    cmd = { "elixir-ls" },
  }
end
if nixCats('kotlin') then
  servers.kotlin_language_server = {
    kotlin = {
      formatters = {
        ignoreComments = true,
      },
      signatureHelp = { enabled = true },
      workspace = { checkThirdParty = true },
      telemetry = { enabled = false },
    },
    -- filetypes = { 'kotlin' },
    -- root_pattern = {"settings.gradle", "settings.gradle.kts", 'gradlew', 'mvnw'},
  }
end
if nixCats('java') then
  servers.jdtls = {
    -- filetypes = { 'java', 'kotlin' },
  }
end
if nixCats('java') or nixCats('kotlin') then
  servers.gradle_ls = {
    root_pattern = { "settings.gradle", "settings.gradle.kts", 'gradlew', 'mvnw' },
    cmd = { nixCats("javaExtras.gradle-ls") .. "/share/vscode/extensions/vscjava.vscode-gradle/lib/gradle-server" },
    filetypes = { "kotlin", "java" },
  }
end
if nixCats('bash') then
  servers.bashls = {}
end
if nixCats('go') then
  servers.gopls = {
    -- filetypes = { "go", "gomod", "gowork", "gotmpl", "templ", "tmpl", },
  }
end
if nixCats('python') then
  -- servers.pyright = {},
  servers.pylsp = {
    pylsp = {
      plugins = {
        -- formatter options
        black = { enabled = false },
        autopep8 = { enabled = false },
        yapf = { enabled = false },
        -- linter options
        pylint = { enabled = true, executable = "pylint" },
        pyflakes = { enabled = false },
        pycodestyle = { enabled = false },
        -- type checker
        pylsp_mypy = { enabled = true },
        -- auto-completion options
        jedi_completion = { fuzzy = true },
        -- import sorting
        pyls_isort = { enabled = true },
      },
    },
  }
end

if nixCats('general.markdown') then
  servers.marksman = {}
  servers.harper_ls = {
    ["harper-ls"] = {},
    filetypes = { "markdown", "norg" },
  }
end

if nixCats('web.templ') then
  servers.templ = {}
end
if nixCats('web.tailwindcss') then
  servers.tailwindcss = {}
end
if nixCats('web.JS') then
  servers.ts_ls = {
    filetypes = {
      "javascript",
      "javascriptreact",
      "javascript.jsx",
      "typescript",
      "typescriptreact",
      "typescript.tsx",
    },
  }
end
if nixCats('web.HTMX') then
  servers.htmx = {}
end
if nixCats('web.HTML') then
  servers.cssls = {}
  servers.eslint = {}
  servers.jsonls = {}
  servers.html = {
    filetypes = { 'html', 'twig', 'hbs', 'templ' },
    html = {
      format = {
        templating = true,
        wrapLineLength = 120,
        wrapAttributes = 'auto',
      },
      hover = {
        documentation = true,
        references = true,
      },
    },
  }
end
if nixCats('C') then
  servers.clangd = {
    -- unneded thanks to clangd_extensions-nvim I think
    -- clangd_config = {
    --   init_options = {
    --     compilationDatabasePath="./build",
    --   },
    -- }
  }
  servers.cmake = {}
end

if nixCats('rust') then
  servers.rust_analyzer = {}
end


--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------


if (catUtils.isNixCats and nixCats('lspDebugMode')) then
  vim.lsp.set_log_level("debug")
end

local M = {}
function M.on_attach(_, bufnr)
  local map = function(keys, func, desc)
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
  end
  --  To jump back, press <C-T>.
  map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
  map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
  map('K', vim.lsp.buf.hover, 'Hover Documentation')
  -- WARN: This is not Goto Definition, this is Goto Declaration.
  --  For example, in C this would take you to the header
  map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  -- The following two autocommands are used to highlight references of the
  -- word under your cursor when your cursor rests there for a little while.
  --    See `:help CursorHold` for information about when this is executed
  -- When you move your cursor, the highlights will be cleared (the second autocommand).
  -- local client = vim.lsp.get_client_by_id(event.data.client_id)
  -- if client and client.server_capabilities.documentHighlightProvider then
  --   vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
  --     buffer = event.buf,
  --     callback = vim.lsp.buf.document_highlight,
  --   })

  --   vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
  --     buffer = event.buf,
  --     callback = vim.lsp.buf.clear_references,
  --   })
  -- end
end

function M.get_capabilities(server_name)
  -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  if nixCats('general.cmp') then
    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
  end
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  --vim.tbl_extend('keep', capabilities, require'coq'.lsp_ensure_capabilities())
  --vim.api.nvim_out_write(vim.inspect(capabilities))
  return capabilities
end

---------------------------------------------------------------------------------

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('nixCats-lsp-attach', { clear = true }),
  callback = function(event)
    M.on_attach(vim.lsp.get_client_by_id(event.data.client_id), event.buf)
  end,
})

---------------------------------------------------------------------------------

require('lze').load {
  {
    "nvim-lspconfig",
    event = "FileType",
    dep_of = { "otter-nvim", },
    load = (catUtils.isNixCats and nil) or function(name)
      require("birdee.utils").safe_packadd({ name, "mason.nvim", "mason-lspconfig" })
    end,
    after = function(plugin)
      if catUtils.isNixCats then
        for server_name, cfg in pairs(servers) do
          require('lspconfig')[server_name].setup({
            capabilities = M.get_capabilities(server_name),
            -- on_attach = M.on_attach,
            settings = cfg,
            filetypes = (cfg or {}).filetypes,
            cmd = (cfg or {}).cmd,
            root_pattern = (cfg or {}).root_pattern,
          })
        end
      else
        require('mason').setup()
        local mason_lspconfig = require 'mason-lspconfig'
        mason_lspconfig.setup {
          ensure_installed = vim.tbl_keys(servers),
        }
        mason_lspconfig.setup_handlers {
          function(server_name)
            require('lspconfig')[server_name].setup {
              capabilities = M.get_capabilities(server_name),
              -- on_attach = M.on_attach,
              settings = servers[server_name],
              filetypes = (servers[server_name] or {}).filetypes,
            }
          end,
        }
      end
    end,
  }
}

return M
