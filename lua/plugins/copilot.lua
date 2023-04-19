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

      -- status indicator
      local indicator = function()
        local M = { init = false }

        local status = ''
        local setup = function()
          local api = require('copilot.api')
          local spinners = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" }
          api.register_status_notification_handler(function(data)
            local ms = vim.loop.hrtime() / 1000000
            local frame = math.floor(ms / 120) % #spinners

            if data.status == 'Normal' then
              status = ''
            elseif data.status == 'InProgress' then
              status = ''
              status = status .. spinners[frame + 1]
            else
              status = ''
            end
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

      local copilot_status = indicator().get_status

      -- add to lualine
      local lualine_require = require("lualine_require")
      local modules = lualine_require.lazy_require({ config_module = "lualine.config" })

      local current_config = modules.config_module.get_config()
      -- Edit here"
      current_config.sections.lualine_x = { copilot_status, table.unpack(current_config.sections.lualine_x) }
      require("lualine").setup(current_config)
    end
  },
}
