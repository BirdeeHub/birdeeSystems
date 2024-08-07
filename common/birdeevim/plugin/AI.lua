require('lz.n').load({
  "vimplugin-sg.nvim",
  enable = require('nixCatsUtils').enableForCategory('AI', false) and nixCats('nixCats_packageName') ~= "minimal",
  -- cmd = { "" },
  event = "DeferredUIEnter",
  -- ft = "",
  -- keys = "",
  -- colorscheme = "",
  load = function (name)
    require("birdee.utils").safe_packadd({
      "nvim-cmp",
      "codeium.nvim",
      "telescope.nvim",
      name,
    })
  end,
  after = function (plugin)
    if nixCats('AI') then
      local bitwardenAuth = nixCats('bitwardenItemIDs')
      if not require('nixCatsUtils').isNixCats then bitwardenAuth = false end

      -- TEMPORARY SO IT STOPS ASKING ME
      bitwardenAuth = nil

      local codeiumDir = vim.fn.stdpath('cache') .. '/' .. 'codeium'
      local codeiumAuthFile = codeiumDir .. '/' .. 'config.json'
      local session
      if bitwardenAuth then
        if (--[[ require('sg.auth').valid() == false or ]] vim.fn.filereadable(codeiumAuthFile) == 0) then
          session = require("birdee.utils").authTerminal()
        end
      end
      -- if (require('sg.auth').valid() == false) then
      if (vim.fn.expand("$SRC_ACCESS_TOKEN") == "$SRC_ACCESS_TOKEN") then
        local tokenPath = vim.fn.expand("$HOME") .. "/.secrets/codyToken"
        if (--[[ bitwardenAuth or ]] vim.fn.filereadable(tokenPath) == 1) then
          local result
          local handle
          -- if bitwardenAuth then
          --   handle = io.popen("bw get --nointeraction --session " .. session .. " " .. bitwardenAuth.cody, "r")
          -- else
            handle = io.open(tokenPath, "r")
          -- end
          if handle then
            result = handle:read("*l")
            handle:close()
          end
            -- if (string.len(result) == 61) then
              local endpoint = 'https://sourcegraph.com'
              local token = result
              require('sg.auth').set(endpoint, token)
            -- end
        end
      end
      require("sg").setup({
        enable_cody = true,
      })
      vim.keymap.set('n', '<leader>cs', require('sg.extensions.telescope').fuzzy_search_results, { noremap = true, desc = 'cody search' })
      vim.keymap.set('n', '<leader>cc', [[<cmd>CodyToggle<CR>]], { noremap = true, desc = 'CodyChat' })
      vim.keymap.set('v', '<leader>cc', [[:CodyAsk ]], { noremap = true, desc = 'CodyAsk' })

      if vim.fn.filereadable(codeiumAuthFile) == 0 then
        local keyPath = vim.fn.expand("$HOME") .. "/.secrets/codeiumToken"
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
            -- Directory does not exist, so create it
            vim.fn.mkdir(codeiumDir, 'p')
          end
          if (string.len(result) == 36) then
            -- Open the file in write mode
            local file = io.open(codeiumAuthFile, 'w')
            -- Check if the file was successfully opened
            if file then
              file:write('{"api_key": "' .. result .. '"}')
              file:close()
            end
          end
        end
      end

      vim.cmd([[command! ClearSGAuth lua print(require("birdee.utils").deleteFileIfExists(vim.fn.stdpath('data') .. '/cody.json'))]])
      vim.cmd([[command! ClearCodeiumAuth lua print(require("birdee.utils").deleteFileIfExists(vim.fn.stdpath('cache') .. '/codeium/config.json'))]])
      vim.cmd([[command! ClearBitwardenData lua print(require("birdee.utils").deleteFileIfExists(vim.fn.stdpath('config') .. '/../Bitwarden\ CLI/data.json'))]])
    end
  end,
})
