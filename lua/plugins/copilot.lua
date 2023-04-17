return {
  {
    "zbirenbaum/copilot.lua",
    lazy = true,
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
      require('copilot').setup {
        suggestion = {
          auto_trigger = true,
          keymap = {
            accept = '<Tab>',
          }
        },
        panel = {
          auto_refresh = true,
        },
        filetypes = {
          yaml = true,
          markdown = true,
          ["."] = true
        },
      }

      -- don't show copilot suggestions when cmp menu is open
      local cmp = require("cmp")

      cmp.event:on("menu_opened", function()
        vim.b.copilot_suggestion_hidden = true
      end)

      cmp.event:on("menu_closed", function()
        vim.b.copilot_suggestion_hidden = false
      end)

      -- status line
      local statusline = function()
        local M = { init = false }

        local status = ''
        local setup = function()
          local api = require('copilot.api')
          api.register_status_notification_handler(function(data)
            -- customize your message however you want
            if data.status == 'Normal' then
              status = 'Ready'
            elseif data.status == 'InProgress' then
              status = 'Pending'
            else
              status = data.status or 'Offline' -- might never actually be nil but just in case
            end
            status = 'Copilot: ' .. status
          end)
        end

        M.get_status = function()
          if not M.init then
            setup()
            M.init = true
          end
          return status
        end
        return M
      end

      local tabline = require('lualine').get_config

    end
  },
}
