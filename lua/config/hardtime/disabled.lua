local M = {
    disabled_keys = {
        ["<Up>"] = { "n", "v" },
        ["<Down>"] = { "n", "v" },
        ["<Left>"] = { "n", "v" },
        ["<Right>"] = { "n", "v" },
        ["<Del>"] = { "n", "v" },
        ["<C-c>"] = { "n", "v" },
    },
    disabled_message = function(key)
        local mode = vim.api.nvim_get_mode().mode
        local base_message = "🚫 "

        if key == "<Up>" then
            return base_message .. "Arrow keys disabled! Use k, Ctrl-U, or {/} to move up efficiently."
        elseif key == "<Down>" then
            return base_message .. "Arrow keys disabled! Use j, Ctrl-D, or {/} to move down efficiently."
        elseif key == "<Left>" then
            return base_message .. "Arrow keys disabled! Use h, b/B/ge/gE/F/T/0/^ for leftward movement."
        elseif key == "<Right>" then
            return base_message .. "Arrow keys disabled! Use l, w/W/e/E/f/t/$/A for rightward movement."
        elseif key == "<C-c>" then
            return base_message .. "<C-c> disabled! Use y for copying instead."
        end
        return base_message .. "The " .. key .. " key is disabled!"
    end
}

return M
