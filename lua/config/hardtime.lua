local cfg = require('config')


local M = {
    opts = {
        enabled = true,
        timeout = 1000,
        max_count = 5,
        disable_mouse = false,
        restriction_mode = "block", -- block or hint

        disabled_filetypes = cfg.auxiliary_filetypes,
        disabled_keys = {
            ["<Up>"] = { "n", "v" },
            ["<Down>"] = { "n", "v" },
            ["<Left>"] = { "n", "v" },
            ["<Right>"] = { "n", "v" },
            ["<Del>"] = { "n", "v" },
        },
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
        disabled_message = function(key)
            if key == "<Up>" then
                return "🚫 Arrow keys disabled! Use k, Ctrl-U, or {/} to move up efficiently."
            elseif key == "<Down>" then
                return "🚫 Arrow keys disabled! Use j, Ctrl-D, or {/} to move down efficiently."
            elseif key == "<Left>" then
                return "🚫 Arrow keys disabled! Use h, b/B/ge/gE/F/T/0/^ for leftward movement."
            elseif key == "<Right>" then
                return "🚫 Arrow keys disabled! Use l, w/W/e/E/f/t/$/A for rightward movement."
            end
            return "The " .. key .. " key is disabled!"
        end,
        message = function(key, key_count)
            local mode = vim.api.nvim_get_mode().mode
            local base_message = "⚡ Hardtime: " .. key .. " pressed too frequently!"

            -- Customized messages for different keys
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
        end,
        -- key is a lua string pattern you want to match, value is a table of hint message and pattern length.
        hints = {
            ["%D1[hjkl]"] = {
                message = function(keys)
                    return "Use " .. keys:sub(3, 3) .. " instead of " .. keys:sub(2, 3)
                end,
                length = 3,
            },
            ["[kj][%^_]"] = {
                message = function(key)
                    return "Use "
                        .. (key:sub(1, 1) == "k" and "-" or "<CR> or +")
                        .. " instead of "
                        .. key
                        .. " for line movement"
                end,
                length = 2,
            },
            ["%$a"] = {
                message = function()
                    return "Use A instead of $a to append at end of line"
                end,
                length = 2,
            },
            ["d%$"] = {
                message = function()
                    return "Use D instead of d$"
                end,
                length = 2,
            },
            ["y%$"] = {
                message = function()
                    return "Use Y instead of y$"
                end,
                length = 2,
            },
            ["c%$"] = {
                message = function()
                    return "Use C instead of c$"
                end,
                length = 2,
            },
            ["%^i"] = {
                message = function()
                    return "Use I instead of ^i to insert at start of line"
                end,
                length = 2,
            },
            ["%D[j+]O"] = {
                message = function(keys)
                    return "Use o instead of " .. keys:sub(2)
                end,
                length = 3,
            },
            ["[^fFtT]li"] = {
                message = function()
                    return "Use a instead of li to append after cursor"
                end,
                length = 3,
            },
            ["2([dcy=<>])%1"] = {
                message = function(key)
                    return "Use " .. key:sub(3) .. "j instead of " .. key
                end,
                length = 3,
            },

            -- hints for f/F/t/T
            ["[^dcy=]f.h"] = {
                message = function(keys)
                    return "Use t" .. keys:sub(3, 3) .. " instead of " .. keys:sub(2)
                end,
                length = 4,
            },
            ["[^dcy=]F.l"] = {
                message = function(keys)
                    return "Use T" .. keys:sub(3, 3) .. " instead of " .. keys:sub(2)
                end,
                length = 4,
            },
            ["[^dcy=]T.h"] = {
                message = function(keys)
                    return "Use F" .. keys:sub(3, 3) .. " instead of " .. keys:sub(2)
                end,
                length = 4,
            },
            ["[^dcy=]t.l"] = {
                message = function(keys)
                    return "Use f" .. keys:sub(3, 3) .. " instead of " .. keys:sub(2)
                end,
                length = 4,
            },

            -- iquote and aquote
            ["[^dcy]F[{%[(][dcy]f[}%])]"] = {
                message = function(keys)
                    return "Use "
                        .. keys:sub(4, 4)
                        .. "a"
                        .. keys:sub(3, 3)
                        .. " instead of "
                        .. keys:sub(2)
                end,
                length = 6,
            },
            ["[^dcy]T[{%[('\"`][dcy]t[}%])'\"]"] = {
                message = function(keys)
                    return "Use "
                        .. keys:sub(4, 4)
                        .. "i"
                        .. keys:sub(3, 3)
                        .. " instead of "
                        .. keys:sub(2)
                end,
                length = 6,
            },
            ["[^dcy]f[}%])'\"`][dcy]T[{%[('\"]"] = {
                message = function(keys)
                    return "Use "
                        .. keys:sub(4, 4)
                        .. "i"
                        .. keys:sub(6, 6)
                        .. " instead of "
                        .. keys:sub(2)
                end,
                length = 6,
            },

            -- hints for delete + insert
            ["d[bBwWeE%^%$]i"] = {
                message = function(keys)
                    return "Use " .. "c" .. keys:sub(2, 2) .. " instead of " .. keys
                end,
                length = 3,
            },
            ["dg[eE]i"] = {
                message = function(keys)
                    return "Use " .. "c" .. keys:sub(2, 3) .. " instead of " .. keys
                end,
                length = 4,
            },
            ["d[tTfF].i"] = {
                message = function(keys)
                    return "Use " .. "c" .. keys:sub(2, 3) .. " instead of " .. keys
                end,
                length = 4,
            },
            ["d[ia][\"'`{}%[%]()<>bBwWspt]i"] = {
                message = function(keys)
                    return "Use " .. "c" .. keys:sub(2, 3) .. " instead of " .. keys
                end,
                length = 4,
            },

            -- hints for unnecessary visual mode
            ["Vgg[dcy=<>]"] = {
                message = function(keys)
                    return "Use " .. keys:sub(4, 4) .. "gg instead of " .. keys
                end,
                length = 4,
            },
            ['Vgg".[dy]'] = {
                message = function(keys)
                    return "Use " .. keys:sub(4, 6) .. "gg instead of " .. keys
                end,
                length = 6,
            },
            ["VG[dcy=<>]"] = {
                message = function(keys)
                    return "Use " .. keys:sub(3, 3) .. "G instead of " .. keys
                end,
                length = 3,
            },
            ['VG".[dy]'] = {
                message = function(keys)
                    return "Use " .. keys:sub(3, 5) .. "G instead of " .. keys
                end,
                length = 5,
            },
            ["V%d[kj][dcy=<>]"] = {
                message = function(keys)
                    return "Use "
                        .. keys:sub(4, 4)
                        .. keys:sub(2, 3)
                        .. " instead of "
                        .. keys
                end,
                length = 4,
            },
            ['V%d[kj]".[dy]'] = {
                message = function(keys)
                    return "Use "
                        .. keys:sub(4, 6)
                        .. keys:sub(2, 3)
                        .. " instead of "
                        .. keys
                end,
                length = 6,
            },
            ["V%d%d[kj][dcy=<>]"] = {
                message = function(keys)
                    return "Use "
                        .. keys:sub(5, 5)
                        .. keys:sub(2, 4)
                        .. " instead of "
                        .. keys
                end,
                length = 5,
            },
            ['V%d%d[kj]".[dy]'] = {
                message = function(keys)
                    return "Use "
                        .. keys:sub(5, 7)
                        .. keys:sub(2, 4)
                        .. " instead of "
                        .. keys
                end,
                length = 7,
            },
            ["[vV][eE][dcy]"] = {
                message = function(keys)
                    return "Use "
                        .. keys:sub(3, 3)
                        .. keys:sub(2, 2)
                        .. " instead of "
                        .. keys
                end,
                length = 3,
            },
            ['[vV][eE]".[dy]'] = {
                message = function(keys)
                    return "Use "
                        .. keys:sub(3, 5)
                        .. keys:sub(2, 2)
                        .. " instead of "
                        .. keys
                end,
                length = 5,
            },
            ["[vV]g[eE][dcy]"] = {
                message = function(keys)
                    return "Use "
                        .. keys:sub(4, 4)
                        .. keys:sub(2, 3)
                        .. " instead of "
                        .. keys
                end,
                length = 4,
            },
            ['[vV]g[eE]".[dy]'] = {
                message = function(keys)
                    return "Use "
                        .. keys:sub(4, 6)
                        .. keys:sub(2, 3)
                        .. " instead of "
                        .. keys
                end,
                length = 6,
            },
            ["[vV][tTfF].[dcy]"] = {
                message = function(keys)
                    return "Use "
                        .. keys:sub(4, 4)
                        .. keys:sub(2, 3)
                        .. " instead of "
                        .. keys
                end,
                length = 4,
            },
            ['[vV][tTfF].".[dy]'] = {
                message = function(keys)
                    return "Use "
                        .. keys:sub(4, 6)
                        .. keys:sub(2, 3)
                        .. " instead of "
                        .. keys
                end,
                length = 6,
            },
            ["[vV][ia][\"'`{}%[%]()<>bBwWspt][dcy=<>]"] = {
                message = function(keys)
                    return "Use "
                        .. keys:sub(4, 4)
                        .. keys:sub(2, 3)
                        .. " instead of "
                        .. keys
                end,
                length = 4,
            },
            ['[vV][ia]["\'`{}%[%]()<>bBwWspt]".[dy]'] = {
                message = function(keys)
                    return "Use "
                        .. keys:sub(4, 6)
                        .. keys:sub(2, 3)
                        .. " instead of "
                        .. keys
                end,
                length = 6,
            },

            -- Additional useful hints
            ["0i"] = {
                message = function()
                    return "Use I instead of 0i to insert at start of line"
                end,
                length = 2,
            },
            ["Ai"] = {
                message = function()
                    return "A already enters insert mode - no need for 'i'"
                end,
                length = 2,
            },
            ["Ii"] = {
                message = function()
                    return "I already enters insert mode - no need for 'i'"
                end,
                length = 2,
            },
            ["oi"] = {
                message = function()
                    return "o already enters insert mode - no need for 'i'"
                end,
                length = 2,
            },
            ["Oi"] = {
                message = function()
                    return "O already enters insert mode - no need for 'i'"
                end,
                length = 2,
            },
            ["cdd"] = {
                message = function()
                    return "Use cc instead of cdd for changing whole line"
                end,
                length = 3,
            },
            ["ydd"] = {
                message = function()
                    return "Use yy or Y instead of ydd for copying whole line"
                end,
                length = 3,
            },
            ["yy"] = {
                message = function()
                    return "Use Y instead of yy for copying whole line"
                end,
                length = 2,
            },

            -- Based on remaps
            ["[hjkl][hjkl][hjkl][hjkl]"] = {
                message = function(keys)
                    local direction = keys:sub(1, 1)
                    local suggestion = (direction == "h" or direction == "k") and "S (leap backward)" or
                        "s (leap forward)"
                    return "For long movements, use " .. suggestion .. " instead of " .. keys
                end,
                length = 4,
            },
            ["jjj"] = {
                message = function()
                    return "Use <C-j> (cliff down) for smooth scrolling instead of repeated j"
                end,
                length = 3,
            },
            ["kkk"] = {
                message = function()
                    return "Use <C-k> (cliff up) for smooth scrolling instead of repeated k"
                end,
                length = 3,
            },
            ["ggVG="] = {
                message = function()
                    return "Use <leader>= (LSP format) instead of ggVG= for whole file formatting"
                end,
                length = 5,
            },

            -- Promote mini.move usage
            ["Xp"] = {
                message = function()
                    return "Use <C-S-j> (mini.move) instead of Xp to move line down"
                end,
                length = 3,
            },
            ["ddp"] = {
                message = function()
                    return "Use <C-S-j> (mini.move) instead of ddp to move line down"
                end,
                length = 3,
            },
            ["XkP"] = {
                message = function()
                    return "Use <C-S-k> (mini.move) instead of XkP to move line up"
                end,
                length = 4,
            },
            ["ddkP"] = {
                message = function()
                    return "Use <C-S-k> (mini.move) instead of ddkP to move line up"
                end,
                length = 4,
            },
            ["Vjjj[<>]"] = {
                message = function()
                    return "Use visual selection + <C-S-j> (mini.move) instead of Vjjj< or Vjjj>"
                end,
                length = 6,
            },
            ["Vkkk[<>]"] = {
                message = function()
                    return "Use visual selection + <C-S-k> (mini.move) instead of Vkkk< or Vkkk>"
                end,
                length = 6,
            },

            -- Promote mini.ai text objects
            ["vi[\"'`]"] = {
                message = function(keys)
                    local quote = keys:sub(3, 3)
                    return "Try da" .. quote .. "/ca" .. quote .. " for outer operations"
                end,
                length = 3,
            },
            -- Detect specific whole-file operation patterns (fixed lengths)
            ["gg0VGy"] = {
                message = function()
                    return "Use yaB (mini.ai whole buffer) instead of gg0VGy for copying whole file"
                end,
                length = 6,
            },
            ["ggVGy"] = {
                message = function()
                    return "Use yaB (mini.ai whole buffer) instead of ggVGy for copying whole file"
                end,
                length = 5,
            },
            ["gg%^VGy"] = {
                message = function()
                    return "Use yaB (mini.ai whole buffer) instead of gg^VGy for copying whole file"
                end,
                length = 6,
            },
            ["gg0VGd"] = {
                message = function()
                    return "Use daB (mini.ai whole buffer) instead of gg0VGd for deleting whole file"
                end,
                length = 6,
            },
            ["ggVGd"] = {
                message = function()
                    return "Use daB (mini.ai whole buffer) instead of ggVGd for deleting whole file"
                end,
                length = 5,
            },
            ["gg0VGc"] = {
                message = function()
                    return "Use caB (mini.ai whole buffer) instead of gg0VGc for changing whole file"
                end,
                length = 6,
            },
            ["gg0=G"] = {
                message = function()
                    return "Use <leader>= (LSP format) or =aB (mini.ai) instead of gg0=G for formatting"
                end,
                length = 5,
            },


            -- Promote quick-scope f/F/t/T over repetitive h/l
            ["[hl][hl][hl]"] = {
                message = function(keys)
                    local direction = keys:sub(1, 1) == "h" and "F/T" or "f/t"
                    return "Use " .. direction .. " (quick-scope) to jump to specific characters instead of " .. keys
                end,
                length = 3,
            },

            -- Promote Comment.nvim over manual commenting
            ["I#"] = {
                message = function()
                    return "Use gcc (Comment.nvim) instead of manually adding # comments"
                end,
                length = 2,
            },
            ["I//"] = {
                message = function()
                    return "Use gcc (Comment.nvim) instead of manually adding // comments"
                end,
                length = 3,
            },

            ["gg=G"] = {
                message = function()
                    return "Use <leader>= (LSP format) or =aB (mini.ai) instead of gg=G for whole file formatting"
                end,
                length = 4,
            },

            -- Promote search efficiency (fixed length patterns)
            ["*nnn"] = {
                message = function()
                    return "Consider <C-L> (multicursor all matches) for editing all search results at once"
                end,
                length = 4,
            },
            ["#nnn"] = {
                message = function()
                    return "Consider <C-L> (multicursor all matches) for editing all search results at once"
                end,
                length = 4,
            },

            -- Promote efficient replace operations
            [":%s/"] = {
                message = function()
                    return "Good! :%s is efficient. Also try <leader>sr (ssr.nvim) for structural search & replace"
                end,
                length = 4,
            },
        },
    },

}


return M
