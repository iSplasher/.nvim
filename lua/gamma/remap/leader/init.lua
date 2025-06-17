require('compat')
local utility = require('gamma.utility')
local kmap = utility.kmap
local popup = require('gamma.popup')

if not vim.g.vscode and not vim.g.ide then
    -- Lazy plugin manager
    kmap("n", "<leader>L", vim.cmd.Lazy, "Lazy Plugin Manager", {})
    -- Show guide
    local guide_path = utility.config_path() .. "/help.md"
    kmap("n", "<leader>?g", function()
        popup.floating_content({
            title = "Guide",
            path = guide_path,
        })
    end, "Show guide")

    kmap("n", "<leader>fe", utility.create_cmd("file"), "Rename file")

    -- format
    kmap("n", "<leader>=", function()
        vim.lsp.buf.format()
    end, "[F]ormat current buffer")
end

-- Toggle word wrapping
kmap('n', '<leader>tw', function()
    vim.opt.wrap = not vim.opt.wrap
    utility.print("Wrap is now " .. ((vim.opt.wrap and "on") or "off"))
end, "Toggle word wrap")

-- Toggle relative line numbers
kmap('n', '<leader>tr', function()
    local is_relative = vim.opt.relativenumber
    vim.opt.relativenumber = not is_relative
    utility.print("Relative number is now " .. ((not is_relative and "on") or "off"))
end, "Toggle relative numbers")
