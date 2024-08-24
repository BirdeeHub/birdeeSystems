local catUtils = require('nixCatsUtils')
require('lze').load {
  "codeium.nvim",
  enable = catUtils.enableForCategory('AI', false),
  cmd = { "CodyToggle", "CodyAsk", },
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

    require("sg").setup({
      enable_cody = true,
    })

    require("codeium").setup()

    vim.cmd([[command! ClearSGAuth lua print(require("birdee.utils").deleteFileIfExists(vim.fn.stdpath('data') .. '/cody.json'))]])
    vim.cmd([[command! ClearCodeiumAuth lua print(require("birdee.utils").deleteFileIfExists(vim.fn.stdpath('cache') .. '/codeium/config.json'))]])
    vim.cmd([[command! ClearBitwardenData lua print(require("birdee.utils").deleteFileIfExists(vim.fn.stdpath('config') .. '/../Bitwarden\ CLI/data.json'))]])
  end,
}
