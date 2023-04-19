table.unpack = table.unpack or unpack -- Lua 5.1 compatibility

local kmap = function(mode, keys, func, desc, opts)
  opts = opts or {}
  if desc then
    desc = '>: ' .. desc
  end

  vim.keymap.set(mode, keys, func, { desc = desc, table.unpack(opts) })
end


vim.g.mapleader = " "
vim.g.maplocalleader = " "

kmap("n", "<leader>h", vim.cmd.Dashboard, "Dashboard")

local function open_project_tree()
  -- Set to cwd
  local api = require("nvim-tree.api")
  local global_cwd = vim.fn.getcwd(-1, -1)
  api.tree.change_root(global_cwd)

  vim.cmd.NvimTreeToggle()
end

kmap("n", "<leader>pt", open_project_tree, "Project Tree")

kmap("n", "<leader>l", vim.cmd.Lazy, "Lazy Plugin Manager")

-- Makes cursor remain in the same place when joining lines
-- vim.keymap.set("n", "J", "mzJ`z")

-- Keep cursor in the middle when jumping to search terms
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Copy-paste fixes (the mc and `c are to preserve cursor position)
vim.keymap.set("x", "p", "\"_dP")

vim.keymap.set("n", "y", "mc\"+y`c")
vim.keymap.set("v", "y", "mc\"+y`c")
vim.keymap.set("n", "Y", "mc\"+Y`c")

-- delete into void instead of overwriting previous paste
vim.keymap.set("n", "d", "\"_d")
vim.keymap.set("v", "d", "\"_d")

-- disable Q
vim.keymap.set("n", "Q", "<nop>")

-- format
kmap("n", "<leader>=", function()
  vim.lsp.buf.format()
end, "[F]ormat current buffer")

-- remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- provide hjkl movements in Insert mode and Command-line mode via the <Alt> modifier key
vim.keymap.set('i', '<A-h>', '<Left>', { noremap = true })
vim.keymap.set('i', '<A-j>', '<Down>', { noremap = true })
vim.keymap.set('i', '<A-k>', '<Up>', { noremap = true })
vim.keymap.set('i', '<A-l>', '<Right>', { noremap = true })

-- word motion in insert mode
vim.keymap.set('i', '<A-b>', '<C-o>b', { noremap = true })
vim.keymap.set('i', '<A-w>', '<C-o>w', { noremap = true })
vim.keymap.set('i', '<A-e>', '<C-o>e', { noremap = true })

-- H and L to move to the beginning and end of the line
vim.keymap.set('n', 'H', '^', { noremap = true })
vim.keymap.set('v', 'H', '^', { noremap = true })
vim.keymap.set('n', 'L', '$', { noremap = true })
vim.keymap.set('v', 'L', '$', { noremap = true })
