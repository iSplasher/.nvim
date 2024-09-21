require('compat')
local utility = require('gamma.utility')
local temp = require('gamma.commands.temp')

local kmap = utility.kmap

if package.loaded.attempt then
    local attempt = require('attempt')
    kmap('n', "<leader>nt", temp.new_temp_file, "New [T]emp file (ext)", {remap = true})
    kmap('n', "<leader>ni", attempt.new_input_ext, "New Temp file ([i]nput ext)", {remap = true})
    kmap('n', "<leader>ft", utility.cmd('Telescope attempt'), "Find [T]emp files", {remap = true})
end