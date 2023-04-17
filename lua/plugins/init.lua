return {

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

    -- Add indentation guides even on blank lines
    {
        'lukas-reineke/indent-blankline.nvim',
        -- Enable `lukas-reineke/indent-blankline.nvim`
        -- See `:help indent_blankline.txt`
        opts = {
            char = '|',
            show_trailing_blankline_indent = false,
        },
    },

    -- Writing
    'preservim/vim-pencil',

    -- Search & Hoghlight
    {
        'kevinhwang91/nvim-hlslens',
        config = function()
            require('hlslens').setup()

            local kopts = { noremap = true, silent = true }

            vim.api.nvim_set_keymap('n', 'n',
                [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
                kopts)
            vim.api.nvim_set_keymap('n', 'N',
                [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
                kopts)
            vim.api.nvim_set_keymap('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
            vim.api.nvim_set_keymap('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
            vim.api.nvim_set_keymap('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
            vim.api.nvim_set_keymap('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)
        end
    },

    -- Git related
    'tpope/vim-fugitive',
    'tpope/vim-rhubarb',

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

    {
        "zbirenbaum/copilot.lua",
        lazy = true,
        cmd = 'Copilot',
        event = 'InsertEnter',
        config = function()
            require('copilot').setup {
                suggestion = {
                    auto_trigger = true
                },
                panel = {
                    auto_refresh = true,
                },
                filetypes = {
                    yaml = true,
                    markdown = true,
                    ["."] = true
                },
            }


            local cmp = require("cmp")

            cmp.event:on("menu_opened", function()
                vim.b.copilot_suggestion_hidden = true
            end)

            cmp.event:on("menu_closed", function()
                vim.b.copilot_suggestion_hidden = false
            end)
        end
    },

    {
        'Yggdroot/LeaderF',
        build = ':LeaderfInstallCExtension'
    },

    {
        'folke/which-key.nvim',
        config = function()
            vim.opt.timeout = true
            vim.opt.timeoutlen = 300
            require('which-key').setup({

            })
        end
    },

    -- Session
    {
        'Shatur/neovim-session-manager',
        dependencies = {
            'nvim-lua/plenary.nvim'
        },
        config = function()
            require('session_manager').setup {}
        end
    },

    -- Buffer
    'jeetsukumaran/vim-buffergator',

    -- Zen mode
    {
        'junegunn/goyo.vim',
        config = function()
            vim.keymap.set('n', "<leader>z", vim.cmd.Goyo, { desc = "Toggle [Z]en Mode" })
            vim.g.goyo_width = "80%"
            vim.g.goyo_height = "95%"
        end
    },

    {
        "folke/zen-mode.nvim",
        config = function()
            require("zen-mode").setup {
                width = .85
            }
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
