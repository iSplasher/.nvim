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
    "oil",
    "termianl",
    "mason",
    "TelescopePrompt",
    "TelescopeResults",
}

return {

    {
        "Rentib/cliff.nvim",
        event = "BufRead",
        config = function() 
            local cliff = require("cliff")
            kmap({'n', 'v', 'o'}, '<C-j>', cliff.go_down, "Move cursor down", {remap = true})
            kmap({'n', 'v', 'o'}, '<C-k>', cliff.go_up, "Move cursor up", {remap = true})
        end
    },

    {
        'andymass/vim-matchup',
        event = 'CursorMoved',
        config = function()
            vim.g.matchup_matchparen_offscreen = { method = 'popup' }

            if package.loaded['nvim-treesitter'] then
                require('nvim-treesitter.configs').setup {
                    matchup = {
                        enable = true,
                    }
                }
            end
        end

    },

    {
        "m4xshen/hardtime.nvim",
        event = "VeryLazy",
        dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
        opts = {
            max_count = 5,
            disable_mouse = false,
            disabled_filetypes = {  table.unpack(disabled_filetypes)},
            -- Remove <Up> keys and append <Space> to the disabled_keys
            disabled_keys = {
                -- ["<Up>"] = {},
                -- ["<Space>"] = { "n", "x" },
            },
        }
     },

    {
        "tris203/precognition.nvim",
        event = "VeryLazy",
        branch = "release-please--branches--main--components--precognition.nvim",
        opts = {
            startVisible = true,
            -- showBlankVirtLine = true,
            -- highlightColor = { link = "Comment" },
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
            disabled_fts = {  table.unpack(disabled_filetypes)},
        },
    }
    
}
