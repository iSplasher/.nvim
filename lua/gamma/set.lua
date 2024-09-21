-- theme
vim.g.colors_name = "gruvy"

-- Set leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

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
if vim.g.vscode then
  vim.opt.hlsearch = false
else
  vim.opt.hlsearch = true
end
vim.opt.incsearch = true

-- colors
vim.opt.termguicolors = true
-- vim.opt.colorcolumn = "120"

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


-- neovide
if vim.g.neovide then
  vim.g.neovide_scale_factor                  = 1.0
  vim.g.neovide_window_blurred                = true
  vim.g.neovide_transparency                  = 0.7
  vim.g.neovide_floating_blur_amount_x        = 2.0
  vim.g.neovide_floating_blur_amount_y        = 2.0
  vim.g.neovide_remember_window_size          = true
  vim.g.neovide_hide_mouse_when_typing        = true
  vim.g.neovide_cursor_antialiasing           = true
  vim.g.neovide_cursor_animate_in_insert_mode = true
  vim.g.neovide_cursor_animate_command_line   = true
  vim.g.neovide_cursor_smooth_blink           = true
  vim.g.neovide_detach_on_quit                = 'always_quit'
end
