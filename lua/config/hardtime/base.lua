local cfg         = require('config')
local M           = {}
local notify_data = {
    notify_id = nil,
}
M.opts            = {
    enabled = true,
    timeout = 3000,
    max_count = 5,
    disable_mouse = false,
    restriction_mode = "block", -- block or hint

    disabled_filetypes = cfg.auxiliary_buftypes,
    callback = function(text)
        local notify_opts = {
            title = "Hardtime",
            hide_from_history = true,
            timeout = M.opts.timeout,
            icon = "⚡",
            replace = notify_data.notify_id,
            background_colour = "#1b1b1b",
            stages = "static",
            minimum_width = 70,
            top_down = true,
            on_close = function()
                notify_data.notify_id = nil
            end,
        }
        -- Use nvim-notify directly if available
        local notify = vim.notify
        local ok, nvim_notify = pcall(require, "notify")
        if ok and nvim_notify then
            notify = nvim_notify
        end

        notify_data.notify_id = notify(text, vim.log.levels.ERROR, notify_opts)
    end,

    resetting_keys = {
        ["1"] = { "n", "x" },
        ["2"] = { "n", "x" },
        ["3"] = { "n", "x" },
        ["4"] = { "n", "x" },
        ["5"] = { "n", "x" },
        ["6"] = { "n", "x" },
        ["7"] = { "n", "x" },
        ["8"] = { "n", "x" },
        ["9"] = { "n", "x" },
        ["c"] = { "n" },
        ["C"] = { "n" },
        ["d"] = { "n" },
        ["x"] = { "n" },
        ["X"] = { "n" },
        ["y"] = { "n" },
        ["Y"] = { "n" },
        ["p"] = { "n" },
        ["P"] = { "n" },
        ["gp"] = { "n" },
        ["gP"] = { "n" },
        ["."] = { "n" },
        ["="] = { "n" },
        ["<"] = { "n" },
        [">"] = { "n" },
        ["J"] = { "n" },
        ["gJ"] = { "n" },
        ["~"] = { "n" },
        ["g~"] = { "n" },
        ["gu"] = { "n" },
        ["gU"] = { "n" },
        ["gq"] = { "n" },
        ["gw"] = { "n" },
        ["g?"] = { "n" },
    },
    hint = true,
    notification = true,
    allow_different_key = true,
}


return M
