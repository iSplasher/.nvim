local utility = require('gamma.utility')
local kmap = utility.kmap
-- In addition to the plugins listed here,
-- all the other files in this directory
-- also list and configure plugins.


return {

    -- better format for hover
    {
        "Fildo7525/pretty_hover",
        event = "LspAttach",
        opts = {}
    },


    -- Undo
    {
        'mbbill/undotree',
        cmd = { "UndotreeToggle" },
        config = function()
            kmap('n', "<leader>wu", vim.cmd.UndotreeToggle, "Open Undo Tree")
        end
    },

    -- Buffer
    -- Zen mode
    {
        "folke/zen-mode.nvim",
        dependencies = {

            {
                "folke/twilight.nvim",
                opts = {
                    alpa = 0.10,
                    context = 20,
                    termbg = nil
                }
            },

        },
        config = function()
            vim.api.nvim_set_hl(0, "ZenBg", { ctermbg = 0 })

            require("zen-mode").setup {
                width = .85,
                backdrop = .95,
                -- Vertical padding
                window = {
                    height = function()
                        return vim.api.nvim_win_get_height(0) - 2
                    end,
                },
                plugins = {
                    neovide = {
                        enabled = vim.g.neovide or false,
                        scale = 1.15,
                        disable_animations = false
                    },
                },
                on_open = function(win)
                    vim.api.nvim_set_hl(0, "ZenBg", { ctermbg = 0 })
                end,
            }

            kmap('n', "<leader>tz", vim.cmd.ZenMode, "Toggle [Z]en Mode")
        end
    },

    {
        'shortcuts/no-neck-pain.nvim',
        version = "*",
        config = function()
            require('no-neck-pain').setup {
                width = 135,
                autocmds = {
                    enableOnVimEnter = true,
                    enableOnTabEnter = true
                },
                buffers = {
                    setNames = true,
                    scratchPad = {
                        enable = false,
                        fileName = 'Scratch Pad',
                    },
                }

            }
        end
    },

    -- Temp files/buffers
    {
        'm-demare/attempt.nvim',
        event = "VimEnter",
        dependencies = {
            { 'nvim-lua/plenary.nvim' }
        },
        config = function()
            local attempt = require('attempt')


            attempt.setup {
                autosave = true,
                list_buffers = true,
                ext_options = {
                    '',
                    'lua', 'js', 'py',
                    'cpp', 'c', 'txt',
                    'json', 'md', 'toml',
                    'yml', 'sh', 'cmd',
                    'ps1', 'bat', 'ts' }
            }

            require('telescope').load_extension 'attempt'

            kmap('n', "<leader>nt", attempt.new_select, "New [T]emp file (ext)", {})
            kmap('n', "<leader>ni", attempt.new_input_ext, "New Temp file ([i]nput ext)", {})
            kmap('n', "<leader>ft", utility.create_cmd('Telescope attempt'), "Find [T]emp files", {})
        end
    },


    -- Collab

    -- {
    --     'jbyuki/instant.nvim',
    --     event = "VeryLazy",
    --     config = function()
    --         vim.g.instant_username = "Twiddly"
    --
    --         kmap('n', "<leader>ciu", ":InstantStartServer 0.0.0.0 7899", { desc = "Set[u]p Collab Server" })
    --         kmap('n', "<leader>ciss", ":InstantStopServer", { desc = "[S]top Collab [S]erver" })
    --         kmap('n', "<leader>cijf", ":InstantStartSingle 127.0.0.1 7899",
    --             { desc = "Join Collab Single Buffer ([F]irst client)" })
    --         kmap('n', "<leader>cijc", ":InstantJoinSingle 127.0.0.1 7899",
    --             { desc = "Join Collab Single Buffer ([C]lient)" })
    --         kmap('n', "<leader>cijsf", ":InstantStartSession 127.0.0.1 7899",
    --             { desc = "Join Collab Session ([F]irst client)" })
    --         kmap('n', "<leader>cijsc", ":InstantJoinSession 127.0.0.1 7899",
    --             { desc = "Join Collab Session ([C]lient)" })
    --         kmap('n', "<leader>cis", "<nop>", { desc = "[S]top Collab" })
    --         kmap('n', "<leader>cisc", ":InstantStop", { desc = "[S]top Collab [C]lient" })
    --         kmap('n', "<leader>cif", ":InstantFollow Ignotak", { desc = "[F]ollow Collab User" })
    --         kmap('n', "<leader>cisf", ":InstantStopFollow", { desc = "[S]top [F]ollowing Collab User" })
    --     end
    -- },
    --
}
