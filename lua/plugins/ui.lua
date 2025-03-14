local utility = require('gamma.utility')
local kmap = utility.kmap

return {
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    dependencies = {
      'nvim-telescope/telescope.nvim',
    },
    opts = {
      background_colour = "#000000",
      top_down = false,
      -- don't treat notifications as a buffer
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { focusable = false })
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
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
        },
      },
      views = {
        popupmenu = {
          size = {
            max_width = "80%",
          }
        },
      },
      routes = {

        -- Show @recording messages
        {
          view = "notify",
          filter = { event = "msg_showmode" },
        },
        -- Hide Search Virtual Text
        {
          filter = {
            event = "msg_show",
            kind = "search_count",
          },
          opts = { skip = true },
        },
        -- Hide written messages
        -- {
        --   filter = {
        --     event = "msg_show",
        --     kind = "",
        --     find = "written",
        --   },
        --   opts = { skip = true },
        -- },
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
    end,
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      "nvim-telescope/telescope.nvim",
      "rcarriga/nvim-notify",
    }
  },
}
