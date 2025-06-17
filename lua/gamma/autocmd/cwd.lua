-- Change current working directory in a smart way.
local utility = require('gamma.utility')
local cmd = require('gamma.autocmd.cmd')

local M = {}

function M.auto_cwd()
  -- if there's only one file open, set cwd to its directory
  local open_files = vim.fn.len(vim.fn.getbufinfo({ buflisted = 1 }))
  if open_files == 1 then
    local bufname = vim.fn.bufname(vim.fn.bufnr('%'))
    local bufdir = vim.fn.fnamemodify(bufname, ':h')

    utility.print_debug("Automatically setting cwd to " .. bufdir)

    vim.api.nvim_command('cd ' .. bufdir)
  end
end

function M.setup_autocmds()
  if vim.g.vscode then
    return
  end
  vim.api.nvim_create_augroup("AutoWorkingDirectory", { clear = true })
  vim.api.nvim_create_autocmd(
    { "VimEnter" },
    {
      pattern = "*",
      callback = function()
        M.auto_cwd()
      end,
      group = "AutoWorkingDirectory"
    }
  )
end

cmd.add_cmd(M.setup_autocmds)

return M
