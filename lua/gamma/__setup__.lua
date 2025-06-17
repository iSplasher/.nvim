local utility = require("gamma.utility")
local vscode = require('config.context.vscode')

local M = {}

function M.setup()
    utility.require_dir("before/_init", true, true)

    utility.require_dir("gamma/settings", true, true)

    -- Plugin setup

    utility.require_dir("before/plugin", true, true)

    require("config.lazy").setup {
        editor_plugins = vscode.enabled
    }

    utility.require_dir("gamma/remap", true, true)

    utility.require_dir("gamma/commands", true, true)
    utility.require_dir("gamma/autocmd", true, true)

    -- Autocommands

    local cmd = require("gamma.autocmd.cmd")
    cmd.execute_cmds()
end

return M
