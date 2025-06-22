-- Change current working directory in a smart way.
local utility = require('gamma.utility')
local cmd = require('gamma.autocmd.cmd')

local M = {}

-- Handle swap file conflicts - default to recover
function M.swap_exists()
  -- Get swap file info
  local swap_name = vim.fn.expand("<afile>:p")
  local swap_choice = vim.fn.confirm(
    "Swap file found for " .. swap_name .. "\n" ..
    "Another instance may be editing this file.",
    "&Open Read-Only\n&Edit Anyway\n&Recover\n&Delete Swap\n&Quit", 3 -- Default to option 3 (Recover)
  )

  if swap_choice == 1 then
    vim.v.swapchoice = 'o' -- Open read-only
  elseif swap_choice == 2 then
    vim.v.swapchoice = 'e' -- Edit anyway
  elseif swap_choice == 3 then
    vim.v.swapchoice = 'r' -- Recover
  elseif swap_choice == 4 then
    vim.v.swapchoice = 'd' -- Delete swap file
  else
    vim.v.swapchoice = 'q' -- Quit
  end
end

function M.setup_autocmds()
  if vim.g.vscode then
    return
  end
  local g = vim.api.nvim_create_augroup("Swap", { clear = true })
  vim.api.nvim_create_autocmd(
    { "SwapExists" },
    {
      callback = M.swap_exists,
      group = g,
      desc = "Handle swap file conflicts with recover as default"
    }
  )
end

cmd.add_cmd(M.setup_autocmds)

return M
