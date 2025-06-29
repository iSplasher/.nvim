local utility = require('gamma.utility')

local kmap = utility.kmap

-- Close current window/buffer
kmap({ "n", "i", "v" }, "<C-q>", function()
    -- if there's only one window, close the buffer instead
    if #vim.api.nvim_list_wins() == 1 then
        local bufnr = vim.api.nvim_get_current_buf()
        -- if there's only one buffer, close buffer and go to dashboard
        local bufs = vim.api.nvim_list_bufs()
        local except_types = { "Dashboard", "prompt" }
        local buftype = vim.bo[bufnr].buftype

        if vim.tbl_contains(except_types, buftype) then
            return
        end

        vim.cmd("bdelete " .. bufnr)
        if #bufs == 1 then
            vim.cmd("Dashboard")
        end
    else
        vim.cmd("close")
    end
end, "Close current window/buffer", {})
