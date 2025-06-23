local utility = require('gamma.utility')
local kmap = utility.kmap
local noice_cfg = require('config.noice')

return {
  -- to be able to change font size on the fly
  {
    "tenxsoydev/size-matters.nvim",
    event = "VeryLazy",
    cond = function()
      return vim.g.neovide or vim.g.goneovim or vim.g.nvui or vim.g.gnvim
    end,
    opts = {
      default_mappings = false,
    },
    config = function(_, opts)
      require('size-matters').setup(opts)
      if not vim.g.neovide then
        kmap('n', '<C-ScrollWheelUp>', function()
          require('size-matters').update_font "grow"
        end, "Increase font size", { silent = true })

        kmap('n', '<C-ScrollWheelDown>', function()
          require('size-matters').update_font "shrink"
        end, "Decrease font size", { silent = true })
      end

      kmap('n', '<C-0>', function()
        require('size-matters').reset_font()
      end, "Reset font size", { silent = true })
    end
  },

  -- Smooth scroll
  {
    'karb94/neoscroll.nvim',
    event = "VeryLazy",
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
    lazy = false,
    opts = {
      background_colour = "#000000",
      render = "wrapped-compact",
      top_down = false,
      max_width = function()
        -- always use 35% or 40 columns, whichever is greater
        return math.max(math.floor(vim.o.columns * 0.35), 40)
      end,
      max_height = function()
        -- always use 35% or 30 lines, whichever is greater
        return math.max(math.floor(vim.o.lines * 0.35), 30)
      end,
      on_open = function(win)
        -- don't treat notifications as a buffer
        vim.api.nvim_win_set_config(win, { focusable = false, mouse = true })
        

        -- make windows transparent
        vim.api.nvim_set_option_value("winblend", 30, { win = win })
        -- wrap text
        vim.api.nvim_set_option_value("wrap", true, { win = win })

        -- allows synax highlighting
        local buf = vim.api.nvim_win_get_buf(win)
        vim.bo[buf].filetype = "markdown"
        vim.bo[buf].syntax = "markdown"
        vim.wo[win].spell = false
        vim.wo[win].foldenable = false
        vim.wo[win].number = false
        vim.wo[win].relativenumber = false
        vim.wo[win].conceallevel = 0
      end,
    },
    config = function(_, opts)
      require("notify").setup(opts)
    end,
  },
  {
    "folke/noice.nvim",
    lazy = false,
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    -- enabled = false,
    opts = noice_cfg.opts,
    config = noice_cfg.config,
  },
}
