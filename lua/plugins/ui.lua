local utility = require('gamma.utility')
local kmap = utility.kmap

return {
  -- to be able to change font size on the fly
  {
    "tenxsoydev/size-matters.nvim",
    cond = function()
      return vim.g.neovide or vim.g.goneovim or vim.g.nvui or vim.g.gnvim
    end,
    opts = {
      default_mappings = false,
    },
    config = function(_, opts)
      require('size-matters').setup(opts)
      kmap('n', '<C-ScrollWheelUp>', function()
        require('size-matters').update_font "grow"
      end, "Increase font size", { silent = true })

      kmap('n', '<C-ScrollWheelDown>', function()
        require('size-matters').update_font "shrink"
      end, "Decrease font size", { silent = true })

      kmap('n', '<C-0>', function()
        require('size-matters').reset_font()
      end, "Reset font size", { silent = true })
    end
  },

  -- Smooth scroll
  {
    'karb94/neoscroll.nvim',
    cond = function()
      return vim.g.neovide
    end,
    config = function()
      require('neoscroll').setup({
        pre_hook = function()
          vim.opt.eventignore:append({
            'WinScrolled',
            'CursorMoved',
          })
        end,
        post_hook = function()
          vim.opt.eventignore:remove({
            'WinScrolled',
            'CursorMoved',
          })
        end,
      })
    end
  },

  -- Notifications
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    dependencies = {
      'nvim-telescope/telescope.nvim',
    },
    opts = {
      -- background_colour = "#000000",
      top_down = false,
      max_width = function()
        -- always use 30% or 40 columns, whichever is greater
        return math.max(math.floor(vim.o.columns * 0.3), 40)
      end,
      max_height = function()
        -- always use 35% or 20 lines, whichever is greater
        return math.max(math.floor(vim.o.lines * 0.2), 10)
      end,
      on_open = function(win)
        -- don't treat notifications as a buffer
        vim.api.nvim_win_set_config(win, { focusable = false, mouse = true })

        -- make windows transparent
        vim.api.nvim_set_option_value("winblend", 40, { win = win })
        -- wrap text
        vim.api.nvim_set_option_value("wrap", true, { win = win })

        local buf = vim.api.nvim_win_get_buf(win)
      end,
    },
    config = function(_, opts)
      require("notify").setup(opts)

      local function open_history()
        require('telescope').extensions.notify.notify(opts)
      end
      kmap("n", "<leader>hn", open_history, "Show [n]otification [h]istory")
    end,
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    -- enabled = false,
    opts = {
      cmdline = {
        format = {
          conceal = false,
          filter = false,
        }
      },
      messages = {
        view = 'mini', -- default view
        view_error = 'notify',
        view_warn = 'notify',
      },
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
        },
        hover = {
          enable = false,
        },
        signature = {
          enable = false
        }
      },
      views = {
        notify = {
          merge = true,
          replace = false,
        },
      },
      routes = {
        -- Hide annoying bg color warning
        {
          filter = {
            find = "Highlight group 'NotifyBackground' has no background highlight",
          },
          opts = { skip = true },
        },
        -- Always route any messages with more than 10 lines to the split view
        {
          view = "split",
          filter = { event = "msg_show", min_height = 15 },
        },

        -- Block on error messages, require user to acknowledge
        {
          view = "notify",
          filter = { error = true, blocking = true },
        },

        -- Hide Search Virtual Text
        {
          filter = {
            event = "msg_show",
            kind = "search_count",
          },
          opts = { skip = true },
        },
        -- Route written messages to the mini view
        {
          view = 'mini',
          filter = {
            error = false,
            warning = false,
            event = "msg_show",
            find = "written",
          },
          -- opts = { skip = true },
        },

        -- Route config changed msg to the mini view
        {
          view = 'mini',
          filter = {
            find = "# Config Change Detected. Reloading",
          },
        },

        -- Show @recording messages
        {
          view = "notify",
          filter = { event = "msg_showmode", find = "recording @" },
        },

        -- Show mode change messages
        {
          view = "cmdline",
          filter = { event = "msg_showmode", }
        },
      },
      -- you can enable a preset for easier configuration
      presets = {
        bottom_search = true,         -- use a classic bottom cmdline for search
        command_palette = true,       -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false,           -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false,       -- add a border to hover docs and signature help
      },
    },
    config = function(_, opts)
      require("noice").setup(opts)
      require("telescope").load_extension("noice")
      kmap('n', '<leader>dn', function()
        vim.cmd.NoiceDismiss()
      end, "[D]ismiss all [n]otifications")
    end,
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      "nvim-telescope/telescope.nvim",
      "rcarriga/nvim-notify",
    }
  },
}
