require('compat')
local utility = require('gamma.utility')
local kmap = utility.kmap
local popup = require('gamma.popup')


-- Toggle relative line numbers
kmap('n', '<leader>tr', function()
    local is_relative = vim.opt.relativenumber
    vim.opt.relativenumber = not is_relative
    utility.print("Relative number is now " .. ((not is_relative and "on") or "off"))
end, "Toggle relative numbers")

if not vim.g.vscode and not vim.g.ide then
    -- Lazy plugin manager
    kmap("n", "<leader>L", vim.cmd.Lazy, "Lazy Plugin Manager", {})
end
