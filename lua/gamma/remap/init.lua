require('compat')
local utility = require('gamma.utility')

-- Load all remaps
utility.require_dir("gamma/remap/leader", true)

local kmap = utility.kmap

vim.g.mapleader = " "
vim.g.maplocalleader = " "

if not vim.g.vscode then
  kmap("n", "<leader>h", vim.cmd.Dashboard, "Dashboard")
end

if not vim.g.vscode then
  kmap("n", "<leader>er", utility.cmd("file"), "Rename file")
end


local function open_project_tree()
  -- Set to cwd
  local api = require("nvim-tree.api")
  local global_cwd = vim.fn.getcwd(-1, -1)
  api.tree.change_root(global_cwd)

  vim.cmd.NvimTreeToggle()
end

if not vim.g.vscode then
  kmap("n", "<leader>pt", open_project_tree, "Project Tree")
  kmap("n", "<leader>l", vim.cmd.Lazy, "Lazy Plugin Manager")
end

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

-- Delete into void instead of overwriting previous paste
vim.keymap.set("n", "d", "\"_d")
vim.keymap.set("v", "d", "\"_d")

-- X to cut the current line
vim.keymap.set('n', 'X', 'dd', { noremap = true })

-- disable Q
vim.keymap.set("n", "Q", "<nop>")

-- format
if not vim.g.vscode then
  kmap("n", "<leader>=", function()
    vim.lsp.buf.format()
  end, "[F]ormat current buffer")
end

-- refresh/reload buffers
kmap("n", "<F5>", function()
  vim.cmd("checktime")
  vim.cmd("edit")
end, "[R]eload current buffer")

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

-- U to redo
vim.keymap.set('n', 'U', '<C-r>', { noremap = true })

-- buffers
kmap("n", "<leader>bb", vim.cmd.buffers, "[B]uffers")
kmap("n", "<leader>bd", vim.cmd.bdelete, "[B]uffer [D]elete")
kmap("n", "<leader>bn", vim.cmd.bnext, "[B]uffer [N]ext")
kmap("n", "<leader>bp", vim.cmd.bprevious, "[B]uffer [P]revious")
kmap("n", "<leader>bl", vim.cmd.blast, "[B]uffer [L]ast")
kmap("n", "<leader>bs", vim.cmd.bstart, "[B]uffer [S]tart")
kmap("n", "<leader>bw", vim.cmd.bwipeout, "[B]uffer [W]ipeout")
