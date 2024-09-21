require('compat')
local utility = require('gamma.utility')

local M = {}

function M.new_temp_file()
    if package.loaded.attempt then
        local attempt = require('attempt')
        attempt.new_select()
    else 
        local tmpf = vim.fn.tempname()
        vim.cmd('e ' .. tmpf)
    end
end

return M