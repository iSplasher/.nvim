local utility = require('gamma.utility')
local python = require('config.python')

if not vim.g.is_remote then
    python.setup_env(utility.data_path())
end
