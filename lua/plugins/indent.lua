local exclude = {
  "help",
  "man",
  "alpha",
  "dashboard",
  "neo-tree",
  "Trouble",
  "lspinfo",
  "checkhealth",
  "lazy",
  "lsp-installer",
  "termianl",
  "NvimTree",
  "mason",
  "notify",
  "toggleterm",
  "lazyterm",
  "TelescopePrompt",
  "TelescopeResults",
  "gitcommit"
}

return {
  -- Add indentation guides even on blank lines
  {
    'lukas-reineke/indent-blankline.nvim',
    main = "ibl",
    -- See `:help indent_blankline.txt`
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local ok, indent_blankline = pcall(require, "ibl")
      if not ok then
        print("Failed to load indent_blankline plugin: " .. indent_blankline)
        return
      end
      indent_blankline.setup {
        indent = { char = '│' },
        whitespace = {
          remove_blankline_trail = true
        },
        exclude = {
          filetypes = exclude,
        }
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
