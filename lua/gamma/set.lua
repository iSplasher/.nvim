
-- line numbers
vim.opt.nu = true
vim.opt.relativenumber = true

-- indents
local indent = 4
vim.opt.tabstop = indent
vim.opt.softtabstop = indent
vim.opt.shiftwidth = indent
vim.opt.expandtab = true

vim.opt.smartindent = true
vim.opt.breakindent = true

-- undo
vim.opt.undofile = true

-- case insensitive search unless /C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- better completion experience
vim.opt.completeopt = 'menuone,noselect'

-- wrap
vim.opt.wrap = false

-- sync with system clipboard
vim.opt.clipboard = "unnamedplus"

-- search & highlighting
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- colors
vim.opt.termguicolors = true
-- vim.opt.colorcolumn = "120"

--- misc
vim.opt.scrolloff = 5
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50
vim.g.mapleader = " "
