require('compat')
local utility = require('gamma.utility')
local kmap = utility.kmap

if not vim.g.vscode then
    kmap("n", "<leader>h", vim.cmd.Dashboard, "Dashboard")

    kmap("n", "<leader>er", utility.cmd("file"), "Rename file")

    
    local function open_project_tree()
        -- Set to cwd
        local api = require("nvim-tree.api")
        local global_cwd = vim.fn.getcwd(-1, -1)
        api.tree.change_root(global_cwd)
    
        vim.cmd.NvimTreeToggle()
    end
    
    kmap("n", "<leader>pt", open_project_tree, "Project Tree")
    kmap("n", "<leader>l", vim.cmd.Lazy, "Lazy Plugin Manager", {remap = true})
end
