local utility = require('gamma.utility')
local kmap = utility.kmap
local cfg = require('config.lsp')

local M = {
    {
        "bassamsdata/namu.nvim",
        config = function()
            require("namu").setup({
                -- Enable the modules you want
                namu_symbols = {
                    enable = true,
                    options = {}, -- here you can configure namu
                },
                -- Optional: Enable other modules if needed
                ui_select = { enable = false }, -- vim.ui.select() wrapper
            })
            kmap("n", "<leader>b#", ":Namu symbols<cr>", {
                desc = "Jump to [L]SP [s]ymbol",
                silent = true,
            })
            kmap("n", "<leader>p#", ":Namu workspace<cr>", {
                desc = "[L]SP Symbols - [W]orkspace",
                silent = true,
            })
        end,
    },
    {
        -- Autocompletion
        'saghen/blink.cmp',
        lazy = true,
        event = 'InsertEnter',
        -- use a release tag to download pre-built binaries
        version = '*',
        opts = cfg.blink_opts,
        opts_extend = { "sources.default" },
        dependencies = {
            'rafamadriz/friendly-snippets',
            "L3MON4D3/LuaSnip",
            "xzbdmw/colorful-menu.nvim",
            'windwp/nvim-autopairs',
            'onsails/lspkind.nvim'

        },
    },

    {
        "L3MON4D3/LuaSnip",
        lazy = true,
        event = "VeryLazy",
        -- follow latest release.
        version = "2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        -- install jsregexp (optional!).
        build = function()
            if not utility.is_windows() then
                vim.system({ "make", "install_jsregexp" }, { text = true }).wait(10000)
            end
        end,
    },
    {
        'windwp/nvim-autopairs',
        lazy = true,
        event = "InsertEnter",
        config = true,
        opts = {
            disable_filetype = { "TelescopePrompt", "spectre_panel" },
            map_cr = false,
            map_bs = false,
        }
    },
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        lazy = true,
        cmd = "Trouble",
        config = function()
            require("trouble").setup {
                auto_close = true, -- close when there are no items
                auto_open = true,  -- open when there are items
                position = "bottom",
                height = 10,
                width = 50,
                icons = true,
                mode = "workspace_diagnostics",
                fold_open = "",
                fold_closed = "",
                group = true,
                padding = true,
                action_keys = {
                    close = "q",
                    cancel = "<esc>",
                    refresh = "r",
                    jump = { "<cr>", "<tab>" },
                    open_split = { "<c-x>" },
                    open_vsplit = { "<c-v>" },
                    open_tab = { "<c-t>" },
                    jump_close = { "o" },
                    toggle_mode = "m",
                    toggle_preview = "P",
                    hover = "K",
                    preview = "p",
                    close_folds = { "zM", "zm" },
                    open_folds = { "zR", "zr" },
                    toggle_fold = { "zA", "za" },
                    previous = "k",
                    next = "j"
                },
            }

            kmap("n", "<leader>lx", "<cmd>Trouble<cr>", { desc = "Toggle Trouble" })
            kmap("n", "<leader>lw", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Workspace Diagnostics" })
            kmap("n", "<leader>ld", "<cmd>Trouble diagnostics toggle focus=false filter.buf=0<cr>",
                { desc = "Buffer Diagnostics" })
            kmap("n", "<leader>xl", "<cmd>Trouble loclist toggle<cr>", { desc = "Location List" })
            kmap("n", "<leader>xq", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List" })
        end
    }
}

-- lspconfig Specific --

table.insert(M, {
    {
        --  Plugin that properly configures LuaLS for editing your Neovim config by lazily updating your workspace libraries
        "folke/lazydev.nvim",
        version = '*',
        ft = "lua", -- only load on lua files
        opts = {
            library = {
                -- See the configuration section for more details
                -- Only load the lazyvim library when the `LazyVim` global is found
                { path = "LazyVim",       words = { "LazyVim" } },
                -- Load the wezterm types when the `wezterm` module is required
                -- Needs `justinsgithub/wezterm-types` to be installed
                { path = "wezterm-types", mods = { "wezterm" } },
            },
        },
    },
    {
        -- Optional
        'williamboman/mason.nvim',
        lazy = true,
        event = "VeryLazy",
        config = true,
        opts = {},
        build = function()
            pcall(vim.cmd, 'MasonUpdate')
        end
    },
    {
        'williamboman/mason-lspconfig.nvim',
        lazy = true,
        event = "VeryLazy",
        dependences = {
            'williamboman/mason.nvim',
        }
    },
    {

        'neovim/nvim-lspconfig',
        version = '*',
        cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
        lazy = true,
        event = { 'BufReadPre', 'BufNewFile' },
        opts = cfg.lspconfig_opts,
        init = function()
            -- Reserve a space in the gutter
            -- This will avoid an annoying layout shift in the screen
            vim.opt.signcolumn = 'yes'
        end,
        config = cfg.lspconfig_config, -- The majority of the configuration is in the config.lsp module
        dependencies = {
            'saghen/blink.cmp',
            'williamboman/mason-lspconfig.nvim',
            "folke/lazydev.nvim",
            -- Schema
            { "b0o/schemastore.nvim" },
        },

    },
})


return M
