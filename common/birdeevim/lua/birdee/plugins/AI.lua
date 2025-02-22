local catUtils = require('nixCatsUtils')
return {
  {
    "codeium.nvim",
    for_cat = { cat = 'AI', default = false },
    cmd = { "Codeium" },
    event = "InsertEnter",
    keys = {
      {
        "<leader>cc",
        [[<cmd>Codeium Chat<CR>]],
        mode = {"n","v"},
        noremap = true,
        desc = "[c]odeium [c]hat",
      },
    },
    after = function (_)
      local bitwardenAuth = nixCats.extra('AIextras.codeium_bitwarden_uuid')
      if not catUtils.isNixCats then bitwardenAuth = false end

      local codeiumDir = vim.fn.stdpath('cache') .. '/' .. 'codeium'
      local codeiumAuthFile = codeiumDir .. '/' .. 'config.json'

      local localKeyPath = vim.fn.expand("$HOME") .. "/.secrets/codeium"
      local havelocalkey = vim.fn.filereadable(localKeyPath) == 1

      local codeiumAuthInvalid = vim.fn.filereadable(codeiumAuthFile) == 0

      local session
      local ok
      if bitwardenAuth then
        if codeiumAuthInvalid and not havelocalkey then
          local bw_secret = vim.fn.expand("$HOME") .. "/.secrets/bw"
          local result = nil
          if vim.fn.filereadable(bw_secret) == 1 then
            local handle = io.open(bw_secret, "r")
            if handle then
              result = handle:read("*l")
              handle:close()
            end
          end
          session, ok = require("birdee.utils").authTerminal(result)
          if not ok then
            bitwardenAuth = false
          end
        end
      end
      if codeiumAuthInvalid then
        if (bitwardenAuth or havelocalkey) then
          local result
          local handle
          if havelocalkey then
            handle = io.open(localKeyPath, "r")
          elseif bitwardenAuth then
            handle = io.popen("bw get --nointeraction --session " .. session .. " " .. bitwardenAuth, "r")
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

      local codeium_settings = {
        enable_chat = true,
      }

      if nixCats.extra('AIextras.codeium') then
        require("codeium").setup(vim.tbl_deep_extend(
          "force",
          codeium_settings,
          nixCats.extra('AIextras.codeium')
        ))
      else
        require("codeium").setup(codeium_settings)
      end

      vim.api.nvim_create_user_command("ClearCodeiumAuth", function (opts)
        print(require("birdee.utils").deleteFileIfExists(codeiumAuthFile))
      end, {})
      vim.api.nvim_create_user_command("ClearBitwardenData", function (opts)
        print(require("birdee.utils").deleteFileIfExists(vim.fn.stdpath('config') .. [[/../Bitwarden\ CLI/data.json]]))
      end, {})
    end,
  },
}
