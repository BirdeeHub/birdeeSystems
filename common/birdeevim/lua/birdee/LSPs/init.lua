local catUtils = require('nixCatsUtils')
if (catUtils.isNixCats and nixCats('lspDebugMode')) then
  vim.lsp.set_log_level("debug")
end

local M = {}
function M.on_attach(_, bufnr)
  -- we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.

  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')

  if nixCats('general.core') then
    -- NOTE: why are these functions that call the telescope builtin?
    -- because otherwise they would load telescope eagerly when this is defined.
    -- due to us using the on_require handler to make sure it is available.
    nmap('gr', function() require('telescope.builtin').lsp_references() end, '[G]oto [R]eferences')
    nmap('gI', function() require('telescope.builtin').lsp_implementations() end, '[G]oto [I]mplementation')
    nmap('<leader>ds', function() require('telescope.builtin').lsp_document_symbols() end, '[D]ocument [S]ymbols')
    nmap('<leader>ws', function() require('telescope.builtin').lsp_dynamic_workspace_symbols() end, '[W]orkspace [S]ymbols')
  end

  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
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

-- vim.api.nvim_create_autocmd('LspAttach', {
--   group = vim.api.nvim_create_augroup('nixCats-lsp-attach', { clear = true }),
--   callback = function(event)
--     M.on_attach(vim.lsp.get_client_by_id(event.data.client_id), event.buf)
--   end,
-- })

---------------------------------------------------------------------------------

require('lze').register_handlers(require('lzextras').lsp {
  {
    "nvim-lspconfig",
    for_cat = "general.core",
    on_require = { "lspconfig" },
    load = function(name)
      if catUtils.isNixCats then
        vim.cmd.packadd(name)
      else
        require("birdee.utils").multi_packadd({ name, "mason.nvim", "mason-lspconfig.nvim" })
        require('mason').setup()
        require('mason-lspconfig').setup()
      end
    end,
    lsp = function(plugin)
      local server_name = plugin.name
      local cfg = plugin.lsp
      require('lspconfig')[server_name].setup({
        capabilities = M.get_capabilities(server_name),
        on_attach = M.on_attach,
        settings = cfg,
        filetypes = (cfg or {}).filetypes,
        cmd = (cfg or {}).cmd,
        root_pattern = (cfg or {}).root_pattern,
      })
    end,
  },
})

if catUtils.isNixCats then
  vim.api.nvim_create_user_command("StartNilLSP", function()
    require('lspconfig').nil_ls.setup({ capabilities = require('birdee.LSPs').get_capabilities('nil_ls') })
  end, { desc = 'Run nil-ls (when you really need docs for the builtins and nixd refuse)' })
end
require('lze').load {
  {
    "lua_ls",
    enabled = nixCats('lua') or nixCats('neonixdev'),
    lsp = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        formatters = {
          ignoreComments = true,
        },
        signatureHelp = { enabled = true },
        diagnostics = {
          globals = { "nixCats", "vim", "make_test" },
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
    },
  },
  {
    "nixd",
    enabled = nixCats('nix') or nixCats('neonixdev'),
    lsp = {
      nixd = {
        nixpkgs = {
          expr = [[import (builtins.getFlake "]] .. nixCats.extra("nixdExtras.nixpkgs") .. [[") { }   ]],
        },
        formatting = {
          command = { "nixfmt" }
        },
        options = {
          -- (builtins.getFlake "<path_to_system_flake>").legacyPackages.<system>.nixosConfigurations."<user@host>".options
          nixos = {
            expr = [[(builtins.getFlake "]] ..
              nixCats.extra("nixdExtras.flake-path") .. [[").legacyPackages.]] ..
              nixCats.extra("nixdExtras.system") .. [[.nixosConfigurations."]] ..
              nixCats.extra("nixdExtras.systemCFGname") .. [[".options]]
          },
          -- (builtins.getFlake "<path_to_system_flake>").legacyPackages.<system>.homeConfigurations."<user@host>".options
          ["home-manager"] = {
            expr = [[(builtins.getFlake "]] ..
              nixCats.extra("nixdExtras.flake-path") .. [[").legacyPackages.]] ..
              nixCats.extra("nixdExtras.system") .. [[.homeConfigurations."]] ..
              nixCats.extra("nixdExtras.homeCFGname") .. [[".options]]
          }
        },
        diagnostic = {
          suppress = {
            "sema-escaping-with"
          }
        }
      }
    },
  },
  {
    "rnix",
    enabled = not catUtils.isNixCats,
    lsp = {},
  },
  {
    "nil_ls",
    enabled = not catUtils.isNixCats,
    lsp = {},
  },
  {
    "elixirls",
    for_cat = "elixir",
    lsp = {
      cmd = { "elixir-ls" },
    }
  },
  {
    "kotlin_language_server",
    for_cat = 'kotlin',
    lsp = {
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
  },
  {
    "jdtls",
    for_cat = 'java',
    lsp = {
      -- filetypes = { 'java', 'kotlin' },
    }
  },
  {
    "gradle_ls",
    enabled = nixCats('java') or nixCats('kotlin'),
    lsp = {
      root_pattern = { "settings.gradle", "settings.gradle.kts", 'gradlew', 'mvnw' },
      cmd = { nixCats.extra("javaExtras.gradle-ls") .. "/share/vscode/extensions/vscjava.vscode-gradle/lib/gradle-server" },
      filetypes = { "kotlin", "java" },
    }
  },
  {
    "bashls",
    for_cat = "bash",
    lsp = {}
  },
  {
    "gopls",
    for_cat = "go",
    lsp = {
      -- filetypes = { "go", "gomod", "gowork", "gotmpl", "templ", "tmpl", },
    },
  },
  {
    "pylsp",
    for_cat = "python",
  -- servers.pyright = {},
    lsp = {
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
  },
  {
    "marksman",
    for_cat = "general.markdown",
    lsp = {},
  },
  {
    "harper_ls",
    for_cat = "general.markdown",
    lsp = {
      ["harper-ls"] = {},
      filetypes = { "markdown", "norg" },
    },
  },
  {
    "templ",
    for_cat = "web.templ",
    lsp = {},
  },
  {
    "tailwindcss",
    for_cat = "web.tailwindcss",
    lsp = {},
  },
  {
    "ts_ls",
    for_cat = "web.JS",
    lsp = {
      filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
      },
    },
  },
  {
    "clangd",
    for_cat = "C",
    lsp = {
      -- unneded thanks to clangd_extensions-nvim I think
      -- clangd_config = {
      --   init_options = {
      --     compilationDatabasePath="./build",
      --   },
      -- }
    },
  },
  {
    "cmake",
    for_cat = "C",
    lsp = {},
  },
  {
    "htmx",
    for_cat = "web.HTMX",
    lsp = {},
  },
  {
    "cssls",
    for_cat = "web.HTML",
    lsp = {},
  },
  {
    "eslint",
    for_cat = "web.HTML",
    lsp = {},
  },
  {
    "jsonls",
    for_cat = "web.HTML",
    lsp = {},
  },
  {
    "html",
    for_cat = "web.HTML",
    lsp = {
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
    },
  },
}

return M
