local catUtils = require('nixCatsUtils')
if (catUtils.isNixCats and nixCats('lspDebugMode')) then
  vim.lsp.set_log_level("debug")
end
return {
  {
    "mason.nvim",
    enabled = not catUtils.isNixCats,
    dep_of = { "nvim-lspconfig" },
    load = function(name)
      require("birdee.utils").multi_packadd { name, "mason-lspconfig.nvim" }
      require('mason').setup()
      require('mason-lspconfig').setup { automatic_installation = true, }
    end,
  },
  {
    "nvim-lspconfig",
    for_cat = "general.core",
    on_require = { "lspconfig" },
    lsp = function(plugin)
      require('lspconfig')[plugin.name].setup(vim.tbl_extend("force",{
        capabilities = require('birdee.LSPs.caps_and_attach').get_capabilities(plugin.name),
        on_attach = require('birdee.LSPs.caps_and_attach').on_attach,
      }, plugin.lsp or {}))
    end,
    -- before = function(plugin)
    --   vim.api.nvim_create_autocmd('LspAttach', {
    --     group = vim.api.nvim_create_augroup('nixCats-lsp-attach', { clear = true }),
    --     callback = function(event)
    --       require('birdee.LSPs.caps_and_attach').on_attach(vim.lsp.get_client_by_id(event.data.client_id), event.buf)
    --     end,
    --   })
    -- end,
  },
  {
    "lazydev.nvim",
    for_cat = "neonixdev",
    cmd = { "LazyDev" },
    ft = "lua",
    after = function(_)
      require('lazydev').setup({
        library = {
          { words = { "uv", "vim%.uv", "vim%.loop" }, path = (nixCats.pawsible({"allPlugins", "start", "luvit-meta"}) or "luvit-meta") .. "/library" },
          { words = { "nixCats" }, path = (nixCats.nixCatsPath or "") .. '/lua' },
        },
      })
    end,
  },
  {
    "lua_ls",
    enabled = nixCats('lua') or nixCats('neonixdev'),
    lsp = {
      filetypes = { 'lua' },
      settings = {
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
      },
    },
  },
  {
    "nixd",
    enabled = catUtils.isNixCats and (nixCats('nix') or nixCats('neonixdev')),
    after = function(_)
      vim.api.nvim_create_user_command("StartNilLSP", function()
        require('lspconfig').nil_ls.setup { capabilities = require('birdee.LSPs.caps_and_attach').get_capabilities('nil_ls') }
      end, { desc = 'Run nil-ls (when you really need docs for the builtins and nixd refuse)' })
    end,
    lsp = {
      filetypes = { 'nix' },
      settings = {
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
              expr = nixCats.extra("nixdExtras.nixos_options")
            },
            -- (builtins.getFlake "<path_to_system_flake>").legacyPackages.<system>.homeConfigurations."<user@host>".options
            ["home-manager"] = {
              expr = nixCats.extra("nixdExtras.home_manager_options")
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
  },
  {
    "rnix",
    enabled = not catUtils.isNixCats,
    lsp = {
      filetypes = { "nix" },
    },
  },
  {
    "nil_ls",
    enabled = not catUtils.isNixCats,
    lsp = {
      filetypes = { "nix" },
    },
  },
  {
    "elixirls",
    for_cat = "elixir",
    lsp = {
      filetypes = { "elixir", "eelixir", "heex", "surface" },
      cmd = { "elixir-ls" },
    }
  },
  {
    "kotlin_language_server",
    for_cat = 'kotlin',
    lsp = {
      filetypes = { 'kotlin' },
      -- root_pattern = {"settings.gradle", "settings.gradle.kts", 'gradlew', 'mvnw'},
      settings = {
        kotlin = {
          formatters = {
            ignoreComments = true,
          },
          signatureHelp = { enabled = true },
          workspace = { checkThirdParty = true },
          telemetry = { enabled = false },
        },
      },
    }
  },
  {
    "jdtls",
    for_cat = 'java',
    lsp = {
      filetypes = { 'java', 'kotlin' },
    }
  },
  {
    "gradle_ls",
    enabled = nixCats('java') or nixCats('kotlin'),
    lsp = {
      filetypes = { "kotlin", "java" },
      root_pattern = { "settings.gradle", "settings.gradle.kts", 'gradlew', 'mvnw' },
      cmd = { nixCats.extra("javaExtras.gradle-ls") .. "/share/vscode/extensions/vscjava.vscode-gradle/lib/gradle-server" },
    }
  },
  {
    "bashls",
    for_cat = "bash",
    lsp = {
      filetypes = { "bash", "sh" },
    },
  },
  {
    "gopls",
    for_cat = "go",
    lsp = {
      filetypes = { "go", "gomod", "gowork", "gotmpl", "templ", },
    },
  },
  -- {"pyright", lsp = {}, },
  {
    "pylsp",
    for_cat = "python",
    lsp = {
      filetypes = { "python" },
      settings = {
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
      },
    }
  },
  {
    "marksman",
    for_cat = "general.markdown",
    lsp = {
      filetypes = { "markdown", "markdown.mdx" },
    },
  },
  {
    "harper_ls",
    for_cat = "general.markdown",
    lsp = {
      filetypes = { "markdown", "norg" },
      settings = {
        ["harper-ls"] = {},
      },
    },
  },
  {
    "templ",
    for_cat = "web.templ",
    lsp = {
      filetypes = { "templ" },
    },
  },
  {
    "tailwindcss",
    for_cat = "web.tailwindcss",
    lsp = {
    },
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
      filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
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
    lsp = {
      filetypes = { "cmake" },
    },
  },
  {
    "htmx",
    for_cat = "web.HTMX",
    lsp = {
    },
  },
  {
    "cssls",
    for_cat = "web.HTML",
    lsp = {
      filetypes = { "css", "scss", "less" },
    },
  },
  {
    "eslint",
    for_cat = "web.HTML",
    lsp = {
    },
  },
  {
    "jsonls",
    for_cat = "web.HTML",
    lsp = {
      filetypes = { "json", "jsonc" },
    },
  },
  {
    "html",
    for_cat = "web.HTML",
    lsp = {
      filetypes = { 'html', 'twig', 'hbs', 'templ' },
      settings = {
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
  },
}

-- NOTE: gets filetypes = {}, for server name in + register and puts it into the + register, overwriting server name.
-- :lua vim.fn.setreg([[+]],"filetypes = " .. vim.inspect(require('lspconfig')[vim.fn.getreg("+")].config_def.default_config.filetypes) .. ",")
