local utility = require('gamma.utility')
local kmap = utility.kmap

local disabled_filetypes = {
    "startify",
    "dashboard",
    "neo-tree",
    "qf",
    "netrw",
    "NvimTree",
    "lazy",
    "mason",
    "terminal",
    "mason",
    "TelescopePrompt",
    "noice",
    "TelescopeResults",
}

local equivalence_classes = {
    ' \t\r\n',
    '([{<',
    ')]}>',
    '\'"`',
}

return {

    {
        "Rentib/cliff.nvim",
        event = "BufReadPost",
        config = function()
            local cliff = require("cliff")
            kmap({ 'n', 'v', 'o' }, '<C-j>', cliff.go_down, "Move cursor down", {})
            kmap({ 'n', 'v', 'o' }, '<C-k>', cliff.go_up, "Move cursor up", {})
        end
    },

    {
        'ggandor/leap.nvim',
        event = "BufReadPost",
        dependencies = { "tpope/vim-repeat" },
        config = function()
            kmap({ 'n', 'x', 'o' }, 's', '<Plug>(leap-forward)', "Leap forward", {})
            kmap({ 'n', 'x', 'o' }, 'S', '<Plug>(leap-backward)', "Leap backward", {})
            kmap({ 'n', 'x', 'o' }, 'gs', '<Plug>(leap-from-window)', "Leap from window", {})

            -- Define equivalence classes for brackets and quotes, in addition to
            -- the default whitespace group.
            require('leap').opts.equivalence_classes = equivalence_classes

            -- Use the traversal keys to repeat the previous motion without explicitly
            -- invoking Leap.
            require('leap.user').set_repeat_keys('<enter>', '<backspace>')

            -- Force default highlighting groups so we can override them
            require('leap').init_highlight(true)

            -- Greying out the search area
            vim.api.nvim_set_hl(0, 'LeapBackdrop', { link = 'Comment' })
        end
    },

    {
        'unblevable/quick-scope',
        event = "BufReadPost",
        init = function()
            vim.g.qs_highlight_on_keys = { 'f', 'F', 't', 'T' }
            vim.g.qs_buftype_blacklist = { 'terminal', 'nofile' }
            vim.g.qs_filetype_blacklist = { 'help', 'terminal', 'dashboard' }

            if not vim.g.vscode then
                -- set highlighting groups
                vim.cmd("highlight QuickScopePrimary guifg='#afff5f' gui=underline ctermfg=155 cterm=underline")
                vim.cmd("highlight QuickScopeSecondary guifg='#5fffff' gui=underline ctermfg=81 cterm=underline")
            end
        end
    },

    {
        'andymass/vim-matchup',
        event = 'CursorMoved',
        config = function()
            vim.g.matchup_matchparen_offscreen = { method = 'popup' }
        end
    },

    {
        "m4xshen/hardtime.nvim",
        event = "VeryLazy",
        dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
        opts = {
            max_count = 5,
            disable_mouse = false,
            disabled_filetypes = { table.unpack(disabled_filetypes) },
            -- Remove <Up> keys and append <Space> to the disabled_keys
            disabled_keys = {
                ["<Up>"] = { "n", "v" },
                ["<Down>"] = { "n", "v" },
                ["<Left>"] = { "n", "v" },
                ["<Right>"] = { "n", "v" },
            },
        }
    },

    {
        "tris203/precognition.nvim",
        event = "VeryLazy",
        branch = "release-please--branches--main--components--precognition.nvim",
        opts = {
            startVisible = true,
            showBlankVirtLine = false,
            highlightColor = { link = "CharacterHint" },
            -- hints = {
            --      Caret = { text = "^", prio = 2 },
            --      Dollar = { text = "$", prio = 1 },
            --      MatchingPair = { text = "%", prio = 5 },
            --      Zero = { text = "0", prio = 1 },
            --      w = { text = "w", prio = 10 },
            --      b = { text = "b", prio = 9 },
            --      e = { text = "e", prio = 8 },
            --      W = { text = "W", prio = 7 },
            --      B = { text = "B", prio = 6 },
            --      E = { text = "E", prio = 5 },
            -- },
            -- gutterHints = {
            --     G = { text = "G", prio = 10 },
            --     gg = { text = "gg", prio = 9 },
            --     PrevParagraph = { text = "{", prio = 8 },
            --     NextParagraph = { text = "}", prio = 8 },
            -- },
            disabled_fts = { table.unpack(disabled_filetypes) },
        },
    },

    {
        "jake-stewart/multicursor.nvim",
        config = function()
            local mc = require("multicursor-nvim")
            mc.setup()

            local set = kmap

            -- Operator
            set({ "n", "x" }, "gm", mc.operator, "Add cursors to operator motion", { noremap = true })

            -- Add or skip cursor above/below the main cursor.
            set({ "n", "x", "v" }, "<C-up>", function() mc.lineAddCursor(-1) end, "Add cursor above", {})
            set({ "n", "x", "v" }, "<C-down>", function() mc.lineAddCursor(1) end, "Add cursor below", {})
            set({ "n", "x", "v" }, "<leader><up>", function() mc.lineSkipCursor(-1) end, "Skip cursor above", {})
            set({ "n", "x", "v" }, "<leader><down>", function() mc.lineSkipCursor(1) end, "Skip cursor below", {})

            -- Add or skip adding a new cursor by matching word/selection
            -- set({ "n", "x" }, "<leader>n", function() mc.matchAddCursor(1) end)
            -- set({ "n", "x" }, "<leader>s", function() mc.matchSkipCursor(1) end)
            -- set({ "n", "x" }, "<leader>N", function() mc.matchAddCursor(-1) end)
            -- set({ "n", "x" }, "<leader>S", function() mc.matchSkipCursor(-1) end)

            -- Add and remove cursors with control + left click.
            set({ "n", "v" }, "<c-leftmouse>", mc.handleMouse, "Add cursor with mouse", { silent = true })
            set({ "n", "v" }, "<c-leftdrag>", mc.handleMouseDrag, "Add cursor with mouse drag", { silent = true })
            set({ "n", "v" }, "<c-leftrelease>", mc.handleMouseRelease, "Add cursor with mouse release",
                { silent = true })

            -- Disable and enable cursors.
            set({ "n", "x", "v" }, "<C-Q>", mc.toggleCursor, "Toggle multi-cursors", {})


            -- Search word under cursor, or take selection and add cursors to all occurrences.
            set({ "n", "x", "v" }, "<C-L>", function()
                -- if vim.fn.visualmode() == "v" then
                --     mc.addCursorsToSelection()
                -- else
                --     mc.addCursorsToWord()
                -- end
                mc.matchAllAddCursors()
            end, "Add cursor to all occurrences of word/selection under cursor", { remap = true })


            -- Mappings defined in a keymap layer only apply when there are
            -- multiple cursors. This lets you have overlapping mappings.
            mc.addKeymapLayer(function(layerSet)
                -- Select a different cursor as the main one.
                layerSet({ "n", "x" }, "<left>", mc.prevCursor, { desc = "Select previous cursor" })
                layerSet({ "n", "x" }, "<right>", mc.nextCursor, { desc = "Select next cursor" })

                -- Delete the main cursor.
                layerSet({ "n", "x" }, "<C-x>", mc.deleteCursor, { desc = "Delete main cursor" })

                -- Enable and clear cursors using escape.
                layerSet("n", "<esc>", function()
                    if not mc.cursorsEnabled() then
                        mc.enableCursors()
                    else
                        mc.clearCursors()
                    end
                end, { desc = "Enable or clear cursors" })
            end)

            -- Customize how cursors look.
            local hl = vim.api.nvim_set_hl
            hl(0, "MultiCursorCursor", { link = "DiagnosticSignInfo" })
            hl(0, "MultiCursorVisual", { link = "DiagnosticSignInfo" })
            hl(0, "MultiCursorSign", { link = "SignColumn" })
            hl(0, "MultiCursorMatchPreview", { link = "Search" })
            hl(0, "MultiCursorDisabledCursor", { link = "Visual" })
            hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
            hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
        end
    }

}
