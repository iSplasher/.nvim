local utility = require('gamma.utility')

return {

    -- snippets
    {
        "L3MON4D3/LuaSnip",
        -- follow latest release.
        version = "2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        -- install jsregexp (optional!).
        build = "make install_jsregexp"
    },

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


    -- Classics

    -- 'machakann/vim-sandwich',
    -- 'tpope/vim-surround',
    'tpope/vim-commentary',
    {
        'unblevable/quick-scope',
        lazy = false,
        init = function()
            vim.g.qs_highlight_on_keys = { 'f', 'F', 't', 'T' }
            vim.g.qs_buftype_blacklist = { 'terminal', 'nofile' }
            vim.g.qs_filetype_blacklist = { 'help', 'terminal', 'dashboard' }

            if vim.g.vscode then
                -- set highlighting groups
                vim.cmd("highlight QuickScopePrimary guifg='#afff5f' gui=underline ctermfg=155 cterm=underline")
                vim.cmd("highlight QuickScopeSecondary guifg='#5fffff' gui=underline ctermfg=81 cterm=underline")
            end
        end
    },

    {
        'Yggdroot/LeaderF',
        build = ':LeaderfInstallCExtension',
        init = function()
            -- these break the plugin for some reason
            -- vim.g.Lf_ShortcutF = ''
            -- vim.g.Lf_ShortcutB = ''
            -- vim.g.Lf_WindowPosition = 'popup'
            -- vim.g.Lf_CommandMap = { ['<C-K>'] = '<Up>',['<C-J>'] = '<Down>' }
        end,
        config = function()
            utility.kmap('n', "<leader>f", '<nop>')
            utility.kmap('n', "<leader>b", '<nop>')

            utility.kmap('n', "<leader>ff", vim.cmd.LeaderfFile, "Find [F]ile")
            utility.kmap('n', "<leader>fb", vim.cmd.LeaderfBuffer, "Find [B]uffer")
            utility.kmap('n', "<leader>fh", vim.cmd.LeaderfHelp, "Find [H]elp")
            utility.kmap('n', "<leader>fm", vim.cmd.LeaderfMru, "Find [M]ost [R]ecently [U]sed")
            utility.kmap('n', "<leader>fs", vim.cmd.LeaderfGTagsSymbol, "Find [S]ymbol")
            utility.kmap('n', "<leader>f#", vim.cmd.LeaderfRgInteractive, "Find Interactive")
            utility.kmap('n', "<leader>fc", vim.cmd.LeaderfCommand, "Find [C]ommand")
            utility.kmap('n', "<leader>fw", vim.cmd.LeaderfWindow, "Find [W]indow")
            utility.kmap('n', "<leader>fl", vim.cmd.LeaderfLine, "Find [L]ine")
        end
    },

    {
        'folke/which-key.nvim',
        config = function()
            vim.opt.timeout = true
            vim.opt.timeoutlen = 300
            require('which-key').setup {

            }
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
                    'D:/TEMP',
                    'D:\\TEMP',
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

            utility.kmap('n', "<leader>z", vim.cmd.ZenMode, "Toggle [Z]en Mode")
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
                ext_options = { 'lua', 'js', 'py', 'cpp', 'c', 'txt', '' }
            }

            require('telescope').load_extension 'attempt'

            utility.kmap('n', "<leader>nt", attempt.new_select, "New [T]emp file (ext)")
            utility.kmap('n', "<leader>ni", attempt.new_input_ext, "New Temp file ([i]nput ext)")
            utility.kmap('n', "<leader>ft", utility.cmd('Telescope attempt'), "Find [T]emp files")
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
