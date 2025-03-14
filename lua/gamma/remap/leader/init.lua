require('compat')
local utility = require('gamma.utility')
local kmap = utility.kmap

if not vim.g.vscode then
    kmap("n", "<leader>er", utility.cmd("file"), "Rename file")

    
end
