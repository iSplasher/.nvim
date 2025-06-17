local utility = require('gamma.utility')


-- check if we're in ssh mode, aka, remote mode
---@type boolean
vim.g.is_remote = utility.env('echo $SSH_CONNECTION') ~= ''
