local M = {
    restricted_keys = {
        ["<A-h>"] = { "i" },
        ["<A-l>"] = { "i" },
        ["<A-j>"] = { "i" },
        ["<A-k>"] = { "i" },
        ["<Up>"] = { "i" },
        ["<Down>"] = { "i" },
        ["<Left>"] = { "i" },
        ["<Right>"] = { "i" },
        ["<Del>"] = { "i" },
        ["x"] = { "n" },
        ["d"] = { "n" },
        ["h"] = { "n", "x" },
        ["j"] = { "n", "x" },
        ["k"] = { "n", "x" },
        ["l"] = { "n", "x" },
        ["+"] = { "n", "x" },
        ["gj"] = { "n", "x" },
        ["gk"] = { "n", "x" },
        ["<C-M>"] = { "n", "x" },
        ["<C-N>"] = { "n", "x" },
        ["<C-P>"] = { "n", "x" },
        ["y"] = { "n" },
        ["p"] = { "n" },
        ["P"] = { "n" },
        ["X"] = { "n" },
        [">"] = { "n", "v" },
        ["<"] = { "n", "v" },
    },
    message = function(key, key_count)
        local mode = vim.api.nvim_get_mode().mode

        local base_message = " " .. key .. " pressed too frequently!"

        if key == "k" then
            return base_message .. " Try " .. key_count .. "k, Ctrl-U, or 'S' (leap) to scroll up efficiently."
        elseif key == "j" then
            return base_message .. " Try " .. key_count .. "j, Ctrl-D, or 's' (leap) to scroll down efficiently."
        elseif key == "h" then
            return base_message .. " Consider: b/B/ge/gE/F/T/0/^, or 'S' (leap) for leftward movement."
        elseif key == "l" then
            return base_message .. " Consider: w/W/e/E/f/t/$/A, or 's' (leap) for rightward movement."
        elseif key == "x" then
            return base_message .. " Consider: dw/de/db for more efficient deletion."
        elseif key == "X" then
            return base_message .. " Consider: d0/d^ for deleting to line start."
        elseif key == "y" then
            return base_message .. " Consider: yw/ye/yb or visual selection for copying."
        elseif key == "Y" then
            return base_message .. " Y copies the whole line - use it wisely!"
        elseif key == "J" then
            return base_message .. " J joins lines - consider if multiple joins are needed."
        elseif key == "d" then
            return base_message .. " Consider: dw/de/dd/d$/d0 for targeted deletion."
        elseif key == "c" then
            return base_message .. " Consider: cw/ce/cc/c$/c0 for efficient editing."
        elseif key == "p" then
            return base_message .. " Multiple pastes? Consider visual mode or counts."
        elseif key == "P" then
            return base_message .. " Pasting before cursor - use thoughtfully."
        elseif key == "<Del>" then
            return base_message .. " Use dw/de/db/dl or x for targeted deletion instead."
        elseif key == "gj" then
            return base_message .. " Use " .. key_count .. "gj or visual line mode for wrapped lines."
        elseif key == "gk" then
            return base_message .. " Use " .. key_count .. "gk or visual line mode for wrapped lines."
        elseif key == "+" then
            return base_message .. " Use " .. key_count .. "+ or G/gg with line numbers for navigation."
        elseif key == "<C-M>" then
            return base_message .. " Use Enter/Return or + for next line movement."
        elseif key == "<C-N>" then
            return base_message .. " Use j or counts for consistent downward movement."
        elseif key == "<C-P>" then
            return base_message .. " Use k or counts for consistent upward movement."
        elseif key == "<A-j>" or key == "<Down>" then
            return base_message ..
                " For larger movements: <Esc>" ..
                key_count .. "j<a> or Ctrl-O+S (leap)" .. key_count .. "j to avoid character-by-character movement."
        elseif key == "<A-k>" or key == "<Up>" then
            return base_message ..
                " For larger movements: <Esc>" ..
                key_count .. "k<a> or Ctrl-O+s (leap)" .. key_count .. "k to avoid character-by-character movement."
        elseif key == "<A-h>" or key == "<Left>" then
            return base_message ..
                " For larger movements: use Ctrl-W (delete word back), Ctrl-O+b/B/F/T, or Ctrl-O+S (leap), or exit insert mode."
        elseif key == "<A-l>" or key == "<Right>" then
            return base_message ..
                " For larger movements: Ctrl-O+w/W/e/E/f/t, Ctrl-O+s (leap), or exit insert mode."
        elseif key == "c" then
        elseif key == "X" then
            return base_message .. " X cuts whole line - use " .. key_count .. "dd or counts for multiple lines."
        elseif key == ">" then
            return base_message .. " For moving text: use <C-S-hjkl> (mini.move) for visual selections and lines."
        elseif key == "<" then
            return base_message .. " For moving text: use <C-S-hjkl> (mini.move) for visual selections and lines."
        else
            return base_message .. " Consider more efficient alternatives."
        end
    end

}


return M
