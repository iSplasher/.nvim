---@diagnostic disable-next-line: param-type-mismatch
local _cmd_ok, _ = pcall(vim.cmd, "language en_US.UTF-8")
if not _cmd_ok then
  ---@diagnostic disable-next-line: param-type-mismatch
  _cmd_ok, _ = pcall(vim.cmd, "language en_US")
  if _cmd_ok then
    vim.cmd("set nospell")
  else
    print("Failed to set language to en_US.UTF-8 or en_US")
  end
end

vim.g.backupdir = vim.fn.stdpath('data') .. '/backup'
-- create the directories if they don't exist
vim.fn.system('mkdir -p "' .. vim.g.backupdir .. '"')
vim.g.backupdir = vim.g.backupdir .. '//,.' -- fallback

-- Set leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.encoding = "utf-8"
vim.opt.ffs = "unix,dos,mac" -- fileformats
-- line numbers
vim.opt.nu = true
vim.opt.relativenumber = true

-- disable spell checking by default
vim.opt.spell = false
-- indents
local indent = 4
vim.opt.tabstop = indent
vim.opt.softtabstop = indent
vim.opt.shiftwidth = indent
vim.opt.expandtab = true
vim.opt.smarttab = true

vim.opt.autoindent = true
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
vim.opt.wrapmargin = 2

-- sync with system clipboard
vim.opt.clipboard = "unnamedplus"

-- search & highlighting
if vim.g.vscode then
  vim.opt.hlsearch = false
else
  vim.opt.hlsearch = true
end
vim.opt.incsearch = true

-- colors
-- check if termguicolors is supported
if vim.fn.has("termguicolors") == 1 then
  vim.opt.termguicolors = true
else
  vim.opt.termguicolors = false
end
vim.opt.colorcolumn = "120"

-- Show a few lines of context around the cursor. Note that this makes the
-- text scroll if you mouse-click near the start or end of the window.
vim.opt.scrolloff = 8

-- Show special characters like newlines, tabs, etc.
vim.opt.list = true
vim.opt.showbreak = "↪ "
vim.opt.listchars = {
  tab = "» ",
  trail = "·",
  extends = "⟩",
  precedes = "⟨",
  nbsp = "␣",
  eol = "↲"
}

-- Auto reload file if changed outside of vim
vim.opt.autoread = true

--- misc
vim.opt.signcolumn = "yes"

--
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50
