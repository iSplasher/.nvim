local utility = require('gamma.utility')
local kmap = utility.kmap

return {
  "mrjones2014/smart-splits.nvim",
  event = "VeryLazy",
  config = function()
    require('smart-splits').setup({
      ignored_filetypes = {
        'nofile',
        'quickfix',
        'qf',
        'prompt',
      },
      ignored_buftypes = { 'NvimTree' },
    })

    -- Better window navigation
    kmap('n', '<C-w>h', require('smart-splits').move_cursor_left, "Move cursor to left window")
    kmap('n', '<C-w>j', require('smart-splits').move_cursor_down, "Move cursor to window below")
    kmap('n', '<C-w>k', require('smart-splits').move_cursor_up, "Move cursor to window above")
    kmap('n', '<C-w>l', require('smart-splits').move_cursor_right, "Move cursor to right window")
    kmap('n', '<C-w>w', require('smart-splits').move_cursor_previous, "Move cursor to previous window")
    --
    -- Window resizing
    kmap('n', '<C-w><', require('smart-splits').resize_left, "Resize window to the left")
    kmap('n', '<C-w>+', require('smart-splits').resize_down, "Resize window below")
    kmap('n', '<C-w>-', require('smart-splits').resize_up, "Resize window above")
    kmap('n', '<C-w>>', require('smart-splits').resize_right, "Resize window to the right")

    -- Swap buffers between windows
    kmap('n', '<C-w>bh', require('smart-splits').swap_buf_left, "Swap buffer with left window")
    kmap('n', '<C-w>bj', require('smart-splits').swap_buf_down, "Swap buffer with window below")
    kmap('n', '<C-w>bk', require('smart-splits').swap_buf_up, "Swap buffer with window above")
    kmap('n', '<C-w>bl', require('smart-splits').swap_buf_right, "Swap buffer with right window")
  end
}
