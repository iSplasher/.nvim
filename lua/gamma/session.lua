-- choose what to save in session
vim.g.sessionoptions = 'fold,resize,tabpages,winsize,resize,terminal'

local config_group = vim.api.nvim_create_augroup('Session Settings', {}) -- A global group for all your config autocommands

-- Session load
vim.api.nvim_create_autocmd({ 'User' }, {
  pattern = "SessionLoadPost",
  group = config_group,
  callback = function()
    -- require('nvim-tree').toggle(false, true)
  end,
})

-- Save session on save buffer
vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
  group = config_group,
  callback = function()
    local session_manager = require('session_manager')
    if vim.bo.filetype ~= 'git'
        and not vim.bo.filetype ~= 'gitcommit'
    then
      session_manager.autosave_session()
    end
  end
})
