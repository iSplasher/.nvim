local exclude = {
  "help",
  "alpha",
  "dashboard",
  "neo-tree",
  "Trouble",
  "lazy",
  "lsp-installer",
  "termianl",
  "NvimTree",
  "mason",
  "notify",
  "toggleterm",
  "lazyterm",
}

return {
  -- Add indentation guides even on blank lines
  {
    'lukas-reineke/indent-blankline.nvim',
    -- See `:help indent_blankline.txt`
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local indent_blankline = require("indent_blankline")
      indent_blankline.setup {
        char = '│',
        show_trailing_blankline_indent = false,
        use_treesitter = true,
        filetype_exclude = exclude,
      }
    end
  },

  -- Active indent guide and indent text objects. When you're browsing
  -- code, this highlights the current level of indentation, and animates
  -- the highlighting.
  {
    "echasnovski/mini.indentscope",
    lazy = true,
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      symbol = "╎",
      options = { try_as_border = true },
      mappings = {
        -- Textobjects
        object_scope = '',
        object_scope_with_border = '',
        -- Motions (jump to respective border line; if not present - body line)
        goto_top = '',
        goto_bottom = '',
      }
    },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = exclude,
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
  },
}
