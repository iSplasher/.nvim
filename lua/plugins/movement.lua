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
        event = "BufRead",
        config = function()
            local cliff = require("cliff")
            kmap({ 'n', 'v', 'o' }, '<C-j>', cliff.go_down, "Move cursor down", {})
            kmap({ 'n', 'v', 'o' }, '<C-k>', cliff.go_up, "Move cursor up", {})
        end
    },

    {
        'ggandor/leap.nvim',
        event = "BufRead",
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

            -- Greying out the search area
            vim.api.nvim_set_hl(0, 'LeapBackdrop', { link = 'Comment' })
        end
    },

    {
        'unblevable/quick-scope',
        lazy = false,
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
            highlightColor = { link = "DiagnosticSignHint" },
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
    }

}
