-- Set LF line endings

local utility = require('gamma.utility')
local cmd = require('gamma.autocmd.cmd')

local exts = {
  "*"
  -- "*.c",
  -- "*.cpp",
  -- "*.py",
  -- "*.js",
  -- "*.ts",
  -- "*.lua",
  -- "*.sh",
  -- "*.md",
  -- "*.txt",
  -- "*json",
  -- "*.yml",
  -- "*.yaml",
  -- "*.toml",
}

local M = {}

function M.auto_lf()
  -- Force LF line endings for specific file extensions
  vim.bo.fileformat = "unix"
end

function M.setup_autocmds()
  vim.api.nvim_create_augroup("AutoLFLineEndings", { clear = true })
  vim.api.nvim_create_autocmd(
    { "BufWritePre" },
    {
      pattern = exts,
      callback = function()
        M.auto_lf()
      end,
      group = "AutoLFLineEndings"
    }
  )
end

cmd.add_cmd(M.setup_autocmds)

return M
