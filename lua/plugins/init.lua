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

    -- Smooth scroll
    {
        'karb94/neoscroll.nvim',
        config = function()
            require('neoscroll').setup({
                pre_hook = function()
                    vim.opt.eventignore:append({
                        'WinScrolled',
                        'CursorMoved',
                    })
                end,
                post_hook = function()
                    vim.opt.eventignore:remove({
                        'WinScrolled',
                        'CursorMoved',
                    })
                end,
            })
        end
    },

    -- Writing
    'preservim/vim-pencil',

    -- Search & Highlight

    -- 'mg979/vim-visual-multi',

    -- Git related
    'tpope/vim-fugitive',
    'tpope/vim-rhubarb',
    'lewis6991/gitsigns.nvim',

    -- Detect tabstop and shiftwidth automatically
    'tpope/vim-sleuth',

    -- Undo
    {
        'mbbill/undotree',
        config = function()
            vim.keymap.set('n', "<leader>u", vim.cmd.UndotreeToggle, { desc = "Toggle [U]ndo Tree" })
        end
    },




    -- Session
    {
        'Shatur/neovim-session-manager',
        dependencies = {
            'nvim-lua/plenary.nvim'
        },
        config = function()
            require('session_manager').setup {
                autoload_mode = require('session_manager.config').AutoloadMode.Disabled,
                autosave_ignore_dirs = {
                    "D:/TEMP",
                    "D:\\TEMP",
                    "X:\\TEMP",
                    "X:/TEMP",
                    "C:/WINDOWS",
                    "C:\\WINDOWS",
                    'C:/Program Files',
                    'C:\\Program Files'
                }
            }
        end
    },

    -- Buffer

    -- Zen mode
    {
        "folke/zen-mode.nvim",
        config = function()
            require("zen-mode").setup {
                width = .85
            }

            kmap('n', "<leader>z", vim.cmd.ZenMode, "Toggle [Z]en Mode")
        end
    },

    {
        "folke/twilight.nvim",
        config = function()
            require("twilight").setup {
                -- your configuration comes here
                -- or leave it empty to use the default settings
                -- refer to the configuration section below
            }
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
            kmap('n', "<leader>ft", utility.cmd('Telescope attempt'), "Find [T]emp files", {})
        end
    },


    -- Collab

    {
        'jbyuki/instant.nvim',
        config = function()
            vim.g.instant_username = "Twiddly"

            vim.keymap.set('n', "<leader>ciu", ":InstantStartServer 0.0.0.0 7899", { desc = "Set[u]p Collab Server" })
            vim.keymap.set('n', "<leader>ciss", ":InstantStopServer", { desc = "[S]top Collab [S]erver" })
            vim.keymap.set('n', "<leader>cijf", ":InstantStartSingle 127.0.0.1 7899",
                { desc = "Join Collab Single Buffer ([F]irst client)" })
            vim.keymap.set('n', "<leader>cijc", ":InstantJoinSingle 127.0.0.1 7899",
                { desc = "Join Collab Single Buffer ([C]lient)" })
            vim.keymap.set('n', "<leader>cijsf", ":InstantStartSession 127.0.0.1 7899",
                { desc = "Join Collab Session ([F]irst client)" })
            vim.keymap.set('n', "<leader>cijsc", ":InstantJoinSession 127.0.0.1 7899",
                { desc = "Join Collab Session ([C]lient)" })
            vim.keymap.set('n', "<leader>cis", "<nop>", { desc = "[S]top Collab" })
            vim.keymap.set('n', "<leader>cisc", ":InstantStop", { desc = "[S]top Collab [C]lient" })
            vim.keymap.set('n', "<leader>cif", ":InstantFollow Ignotak", { desc = "[F]ollow Collab User" })
            vim.keymap.set('n', "<leader>cisf", ":InstantStopFollow", { desc = "[S]top [F]ollowing Collab User" })
        end
    },

}
