local M ={}
function M.setupJDTLS()
  if not require('nixCatsUtils').isNixCats then
    vim.cmd([[packadd nvim-jdtls]])
    local ok, jdtls = pcall(require, "jdtls")
    if not ok then
      vim.notify("jdtls could not be loaded")
      return
    end

    local ok_mason, mason_registry = pcall(require, "mason-registry")
    local jdtls_path
    local jt_path
    local jda_path
    local jt_server_jars
    local jda_server_jar
    if ok_mason then
      jdtls_path = mason_registry.get_package("jdtls"):get_install_path()
      jt_path = mason_registry.get_package("java-test"):get_install_path()
      jda_path = mason_registry.get_package("java-debug-adapter"):get_install_path()
      jt_server_jars = vim.fn.glob(jt_path .. "/extension/server/*.jar")
      jda_server_jar = vim.fn.glob(jda_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar")
    else
      jdtls_path = vim.fn.exepath('jdtls')
      if nixCats("javaExtras") then
        jt_path = nixCats("javaExtras.java-test")
        jda_path = nixCats("javaExtras.java-debug-adapter")
        if jt_path and jda_path then
          jt_server_jars = vim.fn.glob(jt_path .. "/share/vscode/extensions/vscjava.vscode-java-test/server/*.jar")
          jda_server_jar = vim.fn.glob(jda_path .. "/share/vscode/extensions/vscjava.vscode-java-debug/server/com.microsoft.java.debug.plugin-*.jar")
        end
      end
    end

    local operative_system
    if vim.fn.has("linux") then
      operative_system = "linux"
    elseif vim.fn.has("win32") then
      operative_system = "win"
    elseif vim.fn.has("macunix") then
      operative_system = "mac"
    end

    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
    local workspace_dir = vim.loop.os_homedir() .. "/.cache/jdtls/workspace/" .. project_name

    local extendedClientCapabilities = jdtls.extendedClientCapabilities
    extendedClientCapabilities.resolveAdditionalTextEditsSupport = true


    local bundles = {}
    if jt_server_jars and jda_server_jar then
      vim.list_extend(bundles, vim.split(jt_server_jars, "\n"))
      vim.list_extend(bundles, vim.split(jda_server_jar, "\n"))
    end

    -- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
    local config = {
      -- The command that starts the language server
      -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
      cmd = {
        -- 💀
        "java", -- or '/path/to/java17_or_newer/bin/java'
        -- depends on if `java` is in your $PATH env variable and if it points to the right version.

        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.protocol=true",
        "-Dlog.level=ALL",
        "-Xmx1g",
        "--add-modules=ALL-SYSTEM",
        "--add-opens",
        "java.base/java.util=ALL-UNNAMED",
        "--add-opens",
        "java.base/java.lang=ALL-UNNAMED",
        "-javaagent:" .. jdtls_path .. "/lombok.jar",

        -- 💀
        "-jar",
        vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar"),
        --          ^^^^^^^^^^                                           ^
        --          Must point to the                                    Change this to
        --          eclipse.jdt.ls                                       the actual version,
        --          installation                                         with vim.fn.glob() is not necessary

        -- 💀
        "-configuration",
        jdtls_path .. "/config_" .. operative_system,
        -- ^^^^^^^                  ^^^^^^^^^^^^^^^^
        -- Must point to the        Change to one of `linux`, `win` or `mac`
        -- eclipse.jdt.ls           Depending on your system.
        -- installation

        -- 💀
        -- See `data directory configuration` section in the README
        "-data",
        workspace_dir,
      },

      capabilities = require('birdee.LSPs').get_capabilities(),

      -- 💀
      -- This is the default if not provided, you can remove it. Or adjust as needed.
      -- One dedicated LSP server & client will be started per unique root_dir
      root_dir = require("jdtls.setup").find_root({
        "build.xml",
        "pom.xml",
        "settings.gradle",
        "settings.gradle.kts",
      }),

      -- Here you can configure eclipse.jdt.ls specific settings
      -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
      -- for a list of options
      settings = {
        java = {
          configuration = {
            updateBuildConfiguration = "interactive",
            -- runtimes = {
            --     {
            --         name = "JavaSE-11",
            --         path = "~/.sdkman/candidates/java/11.0.17-tem",
            --     },
            --     {
            --         name = "JavaSE-18",
            --         path = "~/.sdkman/candidates/java/18.0.2-sem",
            --     },
            -- },
          },
          eclipse = {
            downloadSources = true,
          },
          format = {
            enabled = true,
          },
          implementationsCodeLens = { enabled = true },
          inlayHints = {
            parameterNames = {
              enabled = "all", -- literals, all, none
            },
          },
          maven = {
            downloadSources = true,
          },
          references = {
            includeDecompiledSources = true,
          },
          referencesCodeLens = {
            enabled = true,
          },
        },
        redhat = {
          telemetry = { enabled = false },
        },
        signatureHelp = { enabled = true },
        extendedClientCapabilities = extendedClientCapabilities,
      },
      -- Language server `initializationOptions`
      -- You need to extend the `bundles` with paths to jar files
      -- if you want to use additional eclipse.jdt.ls plugins.
      --
      -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
      --
      -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
      init_options = {
        -- workspace = workspace_dir,
        bundles = bundles,
      },
    }
    -- This starts a new client & server,
    -- or attaches to an existing client & server depending on the `root_dir`.
    require('jdtls').start_or_attach(config)
  end
end
return M
