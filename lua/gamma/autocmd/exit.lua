-- On exit

local utility = require('gamma.utility')
local cmd = require('gamma.autocmd.cmd')

local M = {}


function M.setup_autocmds()
  -- Force write ShaDa file on exit, ignoring existing tmp files
  vim.api.nvim_create_autocmd("VimLeave", {
    callback = function()
      -- Force write ShaDa file on exit, ignoring existing tmp files
      vim.cmd('wshada!')
    end,
  })
end

cmd.add_cmd(M.setup_autocmds)

return M
