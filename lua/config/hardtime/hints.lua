local M = {}

-- This module provides hints for common mistakes, inefficiencies or suggestions

local base_message = ""


---@class hardtime.hint
---@field message fun(keys: string): string|nil keys is the keys that were pressed, if an empty string or nil is returned, no hint will be shown
---@field length number|nil length of the keys that were pressed, if nil, the length will be determined by the pattern

---@class hardtime.pattern : string
----- A lua string pattern that will be matched against the keys that were pressed.
----- The pattern is used like this: string.find(last_keys, pattern, -length)

---@type table<hardtime.pattern, hardtime.hint>
M.hints = {
    ["%D1[hjkl]"] = {
        message = function(keys)
            return base_message .. "Use " .. keys:sub(3, 3) .. " instead of " .. keys:sub(2, 3)
        end,
        length = 3,
    },
    ["[kj][%^_]"] = {
        message = function(key)
            return base_message .. "Use "
                .. (key:sub(1, 1) == "k" and "-" or "<CR> or +")
                .. " instead of "
                .. key
                .. " for line movement"
        end,
        length = 2,
    },
    ["%$a"] = {
        message = function()
            return base_message .. "Use A instead of $a to append at end of line"
        end,
        length = 2,
    },
    ["d%$"] = {
        message = function()
            return base_message .. "Use D instead of d$"
        end,
        length = 2,
    },
    ["y%$"] = {
        message = function()
            return base_message .. "Use Y instead of y$"
        end,
        length = 2,
    },
    ["c%$"] = {
        message = function()
            return base_message .. "Use C instead of c$"
        end,
        length = 2,
    },
    ["%^i"] = {
        message = function()
            return base_message .. "Use I instead of ^i to insert at start of line"
        end,
        length = 2,
    },
    ["%D[j+]O"] = {
        message = function(keys)
            return base_message .. "Use o instead of " .. keys:sub(2)
        end,
        length = 3,
    },
    ["[^fFtT]li"] = {
        message = function()
            return base_message .. "Use a instead of li to append after cursor"
        end,
        length = 3,
    },
    ["2([dcy=<>])%1"] = {
        message = function(key)
            return base_message .. "Use " .. key:sub(3) .. "j instead of " .. key
        end,
        length = 3,
    },

    -- hints for f/F/t/T
    ["[^dcy=]f.h"] = {
        message = function(keys)
            return base_message .. "Use t" .. keys:sub(3, 3) .. " instead of " .. keys:sub(2)
        end,
        length = 4,
    },
    ["[^dcy=]F.l"] = {
        message = function(keys)
            return base_message .. "Use T" .. keys:sub(3, 3) .. " instead of " .. keys:sub(2)
        end,
        length = 4,
    },
    ["[^dcy=]T.h"] = {
        message = function(keys)
            return base_message .. "Use F" .. keys:sub(3, 3) .. " instead of " .. keys:sub(2)
        end,
        length = 4,
    },
    ["[^dcy=]t.l"] = {
        message = function(keys)
            return base_message .. "Use f" .. keys:sub(3, 3) .. " instead of " .. keys:sub(2)
        end,
        length = 4,
    },

    -- iquote and aquote
    ["[^dcy]F[{%[(][dcy]f[}%])]"] = {
        message = function(keys)
            return base_message .. "Use "
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
            return base_message .. "Use "
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
            return base_message .. "Use "
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
            return base_message .. "Use " .. "c" .. keys:sub(2, 2) .. " instead of " .. keys
        end,
        length = 3,
    },
    ["dg[eE]i"] = {
        message = function(keys)
            return base_message .. "Use " .. "c" .. keys:sub(2, 3) .. " instead of " .. keys
        end,
        length = 4,
    },
    ["d[tTfF].i"] = {
        message = function(keys)
            return base_message .. "Use " .. "c" .. keys:sub(2, 3) .. " instead of " .. keys
        end,
        length = 4,
    },
    ["d[ia][\"'`{}%[%]()<>bBwWspt]i"] = {
        message = function(keys)
            return base_message .. "Use " .. "c" .. keys:sub(2, 3) .. " instead of " .. keys
        end,
        length = 4,
    },

    -- hints for unnecessary visual mode
    ["Vgg[dcy=<>]"] = {
        message = function(keys)
            return base_message .. "Use " .. keys:sub(4, 4) .. "gg instead of " .. keys
        end,
        length = 4,
    },
    ['Vgg".[dy]'] = {
        message = function(keys)
            return base_message .. "Use " .. keys:sub(4, 6) .. "gg instead of " .. keys
        end,
        length = 6,
    },
    ["VG[dcy=<>]"] = {
        message = function(keys)
            return base_message .. "Use " .. keys:sub(3, 3) .. "G instead of " .. keys
        end,
        length = 3,
    },
    ['VG".[dy]'] = {
        message = function(keys)
            return base_message .. "Use " .. keys:sub(3, 5) .. "G instead of " .. keys
        end,
        length = 5,
    },
    ["V%d[kj][dcy=<>]"] = {
        message = function(keys)
            return base_message .. "Use "
                .. keys:sub(4, 4)
                .. keys:sub(2, 3)
                .. " instead of "
                .. keys
        end,
        length = 4,
    },
    ['V%d[kj]".[dy]'] = {
        message = function(keys)
            return base_message .. "Use "
                .. keys:sub(4, 6)
                .. keys:sub(2, 3)
                .. " instead of "
                .. keys
        end,
        length = 6,
    },
    ["V%d%d[kj][dcy=<>]"] = {
        message = function(keys)
            return base_message .. "Use "
                .. keys:sub(5, 5)
                .. keys:sub(2, 4)
                .. " instead of "
                .. keys
        end,
        length = 5,
    },
    ['V%d%d[kj]".[dy]'] = {
        message = function(keys)
            return base_message .. "Use "
                .. keys:sub(5, 7)
                .. keys:sub(2, 4)
                .. " instead of "
                .. keys
        end,
        length = 7,
    },
    ["[vV][eE][dcy]"] = {
        message = function(keys)
            return base_message .. "Use "
                .. keys:sub(3, 3)
                .. keys:sub(2, 2)
                .. " instead of "
                .. keys
        end,
        length = 3,
    },
    ['[vV][eE]".[dy]'] = {
        message = function(keys)
            return base_message .. "Use "
                .. keys:sub(3, 5)
                .. keys:sub(2, 2)
                .. " instead of "
                .. keys
        end,
        length = 5,
    },
    ["[vV]g[eE][dcy]"] = {
        message = function(keys)
            return base_message .. "Use "
                .. keys:sub(4, 4)
                .. keys:sub(2, 3)
                .. " instead of "
                .. keys
        end,
        length = 4,
    },
    ['[vV]g[eE]".[dy]'] = {
        message = function(keys)
            return base_message .. "Use "
                .. keys:sub(4, 6)
                .. keys:sub(2, 3)
                .. " instead of "
                .. keys
        end,
        length = 6,
    },
    ["[vV][tTfF].[dcy]"] = {
        message = function(keys)
            return base_message .. "Use "
                .. keys:sub(4, 4)
                .. keys:sub(2, 3)
                .. " instead of "
                .. keys
        end,
        length = 4,
    },
    ['[vV][tTfF].".[dy]'] = {
        message = function(keys)
            return base_message .. "Use "
                .. keys:sub(4, 6)
                .. keys:sub(2, 3)
                .. " instead of "
                .. keys
        end,
        length = 6,
    },
    ["[vV][ia][\"'`{}%[%]()<>bBwWspt][dcy=<>]"] = {
        message = function(keys)
            return base_message .. "Use "
                .. keys:sub(4, 4)
                .. keys:sub(2, 3)
                .. " instead of "
                .. keys
        end,
        length = 4,
    },
    ['[vV][ia]["\'`{}%[%]()<>bBwWspt]".[dy]'] = {
        message = function(keys)
            return base_message .. "Use "
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
            return base_message .. "Use I instead of 0i to insert at start of line"
        end,
        length = 2,
    },
    ["Ai"] = {
        message = function()
            return base_message .. "A already enters insert mode - no need for 'i'"
        end,
        length = 2,
    },
    ["Ii"] = {
        message = function()
            return base_message .. "I already enters insert mode - no need for 'i'"
        end,
        length = 2,
    },
    ["oi"] = {
        message = function()
            return base_message .. "o already enters insert mode - no need for 'i'"
        end,
        length = 2,
    },
    ["Oi"] = {
        message = function()
            return base_message .. "O already enters insert mode - no need for 'i'"
        end,
        length = 2,
    },
    ["cdd"] = {
        message = function()
            return base_message .. "Use cc instead of cdd for changing whole line"
        end,
        length = 3,
    },
    ["ydd"] = {
        message = function()
            return base_message .. "Use yy or Y instead of ydd for copying whole line"
        end,
        length = 3,
    },
    ["yy"] = {
        message = function()
            return base_message .. "Use Y instead of yy for copying whole line"
        end,
        length = 2,
    },

    -- Based on custom remaps
    ["[hjkl][hjkl][hjkl][hjkl]"] = {
        message = function(keys)
            local direction = keys:sub(1, 1)
            local suggestion = (direction == "h" or direction == "k") and "gS (leap backward)" or
                "gs (leap forward)"
            return base_message .. "For long movements, use " .. suggestion .. " instead of " .. keys
        end,
        length = 4,
    },
    ["jjj"] = {
        message = function()
            return base_message .. "Use <C-j> (cliff down) for smooth scrolling instead of repeated j"
        end,
        length = 3,
    },
    ["kkk"] = {
        message = function()
            return base_message .. "Use <C-k> (cliff up) for smooth scrolling instead of repeated k"
        end,
        length = 3,
    },
    ["%^"] = {
        message = function()
            return base_message .. "Use H instead of ^ to move to beginning of line"
        end,
        length = 1,
    },
    ["%$"] = {
        message = function()
            return base_message .. "Use L instead of $ to move to end of line"
        end,
        length = 1,
    },
    ["dd"] = {
        message = function()
            return base_message .. "Use X instead of dd to cut current line"
        end,
        length = 2,
    },
    ["ggVG="] = {
        message = function()
            return base_message .. "Use <leader>= (LSP format) instead of ggVG= for whole file formatting"
        end,
        length = 5,
    },

    -- Promote mini.move usage
    ["Xp"] = {
        message = function()
            return base_message .. "Use <C-S-j> (mini.move) instead of Xp to move line down"
        end,
        length = 2,
    },
    ["ddp"] = {
        message = function()
            return base_message .. "Use <C-S-j> (mini.move) instead of ddp to move line down"
        end,
        length = 3,
    },
    ["XkP"] = {
        message = function()
            return base_message .. "Use <C-S-k> (mini.move) instead of XkP to move line up"
        end,
        length = 3,
    },
    ["ddkP"] = {
        message = function()
            return base_message .. "Use <C-S-k> (mini.move) instead of ddkP to move line up"
        end,
        length = 4,
    },
    ["Vjjj[<>]"] = {
        message = function()
            return base_message .. "Use visual selection + <C-S-j> (mini.move) instead of Vjjj< or Vjjj>"
        end,
        length = 5,
    },
    ["Vkkk[<>]"] = {
        message = function()
            return base_message .. "Use visual selection + <C-S-k> (mini.move) instead of Vkkk< or Vkkk>"
        end,
        length = 5,
    },

    -- Promote mini.ai text objects
    ["vi[\"'`]"] = {
        message = function(keys)
            local quote = keys:sub(3, 3)
            return base_message .. "Try da" .. quote .. "/ca" .. quote .. " for outer operations"
        end,
        length = 3,
    },

    -- Detect specific whole-file operation patterns
    ["gg0VGy"] = {
        message = function()
            return base_message .. "Use yaB (mini.ai whole buffer) instead of gg0VGy for copying whole file"
        end,
        length = 6,
    },
    ["ggVGy"] = {
        message = function()
            return base_message .. "Use yaB (mini.ai whole buffer) instead of ggVGy for copying whole file"
        end,
        length = 5,
    },
    ["gg%^VGy"] = {
        message = function()
            return base_message .. "Use yaB (mini.ai whole buffer) instead of gg^VGy for copying whole file"
        end,
        length = 6,
    },
    ["gg0VGd"] = {
        message = function()
            return base_message .. "Use daB (mini.ai whole buffer) instead of gg0VGd for deleting whole file"
        end,
        length = 6,
    },
    ["ggVGd"] = {
        message = function()
            return base_message .. "Use daB (mini.ai whole buffer) instead of ggVGd for deleting whole file"
        end,
        length = 5,
    },
    ["gg0VGc"] = {
        message = function()
            return base_message .. "Use caB (mini.ai whole buffer) instead of gg0VGc for changing whole file"
        end,
        length = 6,
    },
    ["gg0=G"] = {
        message = function()
            return base_message .. "Use <leader>= (LSP format) or =aB (mini.ai) instead of gg0=G for formatting"
        end,
        length = 5,
    },
    ["gg=G"] = {
        message = function()
            return base_message .. "Use <leader>= (LSP format) or =aB (mini.ai) instead of gg=G for formatting"
        end,
        length = 4,
    },

    -- Promote quick-scope f/F/t/T over repetitive h/l
    ["[hl][hl][hl]"] = {
        message = function(keys)
            local direction = keys:sub(1, 1) == "h" and "F/T" or "f/t"
            return base_message ..
                "Use " .. direction .. " (quick-scope) to jump to specific characters instead of " .. keys
        end,
        length = 3,
    },

    -- Promote Comment.nvim over manual commenting
    ["I#"] = {
        message = function()
            return base_message .. "Use gcc (Comment.nvim) instead of manually adding # comments"
        end,
        length = 2,
    },
    ["I//"] = {
        message = function()
            return base_message .. "Use gcc (Comment.nvim) instead of manually adding // comments"
        end,
        length = 3,
    },

    -- Promote search efficiency
    ["*nnn"] = {
        message = function()
            return base_message .. "Consider <C-L> (multicursor all matches) for editing all search results at once"
        end,
        length = 4,
    },
    ["#nnn"] = {
        message = function()
            return base_message .. "Consider <C-L> (multicursor all matches) for editing all search results at once"
        end,
        length = 4,
    },

    -- Promote efficient replace operations
    [":%s/"] = {
        message = function()
            return base_message ..
                "Good! :%s is efficient. Also try <leader>sr (ssr.nvim) for structural search & replace"
        end,
        length = 4,
    },

    -- Promote surround operations over manual editing
    ["I['\"(`{]"] = {
        message = function(keys)
            local char = keys:sub(2, 2)
            return base_message .. "Use sa/ys (surround add) instead of manually adding " .. char .. " characters"
        end,
        length = 2,
    },
    ["A['\"`)}]"] = {
        message = function(keys)
            local char = keys:sub(2, 2)
            return base_message .. "Use sa/ys (surround add) instead of manually adding " .. char .. " characters"
        end,
        length = 2,
    },
    ["f['\"`({]i.+A['\"`)}]"] = {
        message = function()
            return base_message .. "Use sr/cs (change surround) instead of manually changing surrounding characters"
        end,
        length = 6,
    },
    ["F['\"`({]x.*A['\"`)}]"] = {
        message = function()
            return base_message .. "Use sd/ds (delete surround) then sa/ys (add surround) or sr/cs (change surround)"
        end,
        length = 6,
    },

    -- Promote leap over repetitive movement
    ["[fFtT].+[hjkl]+"] = {
        message = function()
            return base_message .. "For complex navigation, try gs/gS (leap) to jump directly to target locations"
        end,
        length = 4,
    },
    ["[0%^%$][hjkl]+"] = {
        message = function()
            return base_message .. "Use gs/gS (leap) to jump to specific characters instead of multiple movements"
        end,
        length = 3,
    },
    ["/.*<CR>[nN][nN][nN]"] = {
        message = function()
            return base_message .. "Use gs/gS (leap) to jump directly to visible text instead of search + multiple n/N"
        end,
        length = 6,
    },
}

return M
