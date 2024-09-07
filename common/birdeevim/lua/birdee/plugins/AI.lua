local catUtils = require('nixCatsUtils')
return {
  {
    "codeium.nvim",
    enable = catUtils.enableForCategory('AI', false),
    cmd = { "CodyToggle", "CodyAsk", "Codeium" },
    event = "InsertEnter",
    keys = {
      {
        "<leader>cs",
        function() require('sg.extensions.telescope').fuzzy_search_results() end,
        mode = {"n"},
        noremap = true,
        desc = "cody search",
      },
      {
        "<leader>cc",
        [[<cmd>CodyToggle<CR>]],
        mode = {"n"},
        noremap = true,
        desc = "CodyChat",
      },
      {
        "<leader>cc",
        [[:CodyAsk ]],
        mode = {"v"},
        noremap = true,
        desc = "CodyAsk",
      },
      {
        "<leader>cb",
        [[<cmd>Codeium Chat<CR>]],
        mode = {"n"},
        noremap = true,
        desc = "codeium chat ([b]rowser)",
      },
    },
    -- colorscheme = "",
    load = function (name)
      require("birdee.utils").safe_packadd({
        name,
        "vimplugin-sg.nvim",
      })
    end,
    after = function (plugin)
      local bitwardenAuth = nixCats('bitwardenItemIDs')
      if not catUtils.isNixCats then bitwardenAuth = false end

      -- TEMPORARY SO IT STOPS ASKING ME
      -- I always forget to keep it up to date in my password manager apparently
      bitwardenAuth = nil

      local codeiumDir = vim.fn.stdpath('cache') .. '/' .. 'codeium'
      local codeiumAuthFile = codeiumDir .. '/' .. 'config.json'

      local codyAuthInvalid = vim.fn.expand("$SRC_ACCESS_TOKEN") == "$SRC_ACCESS_TOKEN"
      local codeiumAuthInvalid = vim.fn.filereadable(codeiumAuthFile) == 0

      local session
      if bitwardenAuth then
        if codyAuthInvalid or codeiumAuthInvalid then
          session = require("birdee.utils").authTerminal()
        end
      end
      if codyAuthInvalid then
        local tokenPath = vim.fn.expand("$HOME") .. "/.secrets/codyToken"
        if (bitwardenAuth or vim.fn.filereadable(tokenPath) == 1) then
          local result
          local handle
          if bitwardenAuth then
            handle = io.popen("bw get --nointeraction --session " .. session .. " " .. bitwardenAuth.cody, "r")
          else
            handle = io.open(tokenPath, "r")
          end
          if handle then
            result = handle:read("*l")
            handle:close()
          end
            if (string.len(result) > 10) then
              local endpoint = 'https://sourcegraph.com'
              local token = result
              require('sg.auth').set(endpoint, token)
            end
        end
      end

      if codeiumAuthInvalid then
        local keyPath = vim.fn.expand("$HOME") .. "/.secrets/codeium"
        if (bitwardenAuth or vim.fn.filereadable(keyPath) == 1) then
          local result
          local handle
          if bitwardenAuth then
            handle = io.popen("bw get --nointeraction --session " .. session .. " " .. bitwardenAuth.codeium, "r")
          else
            handle = io.open(keyPath, "r")
          end
          if handle then
            result = handle:read("*l")
            handle:close()
          end
          if vim.fn.isdirectory(codeiumDir) == 0 then
            vim.fn.mkdir(codeiumDir, 'p')
          end
          if (string.len(result) > 10) then
            local file = io.open(codeiumAuthFile, 'w')
            if file then
              file:write('{"api_key": "' .. result .. '"}')
              file:close()
              vim.loop.fs_chmod(codeiumAuthFile, 384, function(err, success)
                if err then
                  print("Failed to set file permissions: " .. err)
                end
              end)
            end
          end
        end
      end

      require("sg").setup({
        enable_cody = true,
      })

      local codeium_settings = {
        enable_chat = true,
      }

      if nixCats('AIextras') then
        require("codeium").setup(vim.tbl_deep_extend(
          "force",
          codeium_settings,
          nixCats('AIextras.codeium')
        ))
      else
        require("codeium").setup(codeium_settings)
      end

      vim.api.nvim_create_user_command("ClearSGAuth", function (opts)
        print(require("birdee.utils").deleteFileIfExists(vim.fn.stdpath('data') .. '/cody.json'))
      end, {})
      vim.api.nvim_create_user_command("ClearCodeiumAuth", function (opts)
        print(require("birdee.utils").deleteFileIfExists(codeiumAuthFile))
      end, {})
      vim.api.nvim_create_user_command("ClearBitwardenData", function (opts)
        print(require("birdee.utils").deleteFileIfExists(vim.fn.stdpath('config') .. [[/../Bitwarden\ CLI/data.json]]))
      end, {})
    end,
  },
}
