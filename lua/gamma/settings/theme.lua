local utility = require('gamma.utility')
local kmap = utility.kmap

vim.opt.background = "dark"
vim.g.colors_name = "gruvbox-material"

if vim.g.neovide then
  vim.o.guifont                               =
  "TX02_Nerd_Font_Mono,FiraCode_NFM_Retina,FiraCode_Nerd_Font_Mono,Fira_Code,Consolas:h12:e-subpixelantialias"

  vim.g.neovide_padding_top                   = 0
  vim.g.neovide_padding_bottom                = 0
  vim.g.neovide_padding_right                 = 0
  vim.g.neovide_padding_left                  = 0

  vim.g.neovide_floating_corner_radius        = 0.2
  -- neovide
  vim.g.neovide_scale_factor                  = 1.0
  vim.g.neovide_window_blurred                = true
  vim.g.neovide_opacity                       = 0.7
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
