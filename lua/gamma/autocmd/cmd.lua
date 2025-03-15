local utility = require('gamma.utility')

local M = {}

local cmds = {}

---Add a command to the list of commands to be executed.
---@param cmd function @The command to add.
function M.add_cmd(cmd)
  table.insert(cmds, cmd)
end

---Execute all commands in the list.
function M.execute_cmds()
  if vim.g.vscode then
    return
  end

  for _, cmd in ipairs(cmds) do
    cmd()
  end
end

return M
