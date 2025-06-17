local ensure_installed = {
    "javascript",
    "tsx",
    "python",
    "typescript",
    "lua",
    "vim",
    "vimdoc",
    "query",
    'json',
    'yaml',
    'bash'
}
return {
    -- Highlight, edit, and navigate code
    {
        'nvim-treesitter/nvim-treesitter',
        event = { 'BufReadPost', 'BufNewFile' },
        build = ':TSUpdate',
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects',
            'andymass/vim-matchup',
        },
        config = function()
            require 'nvim-treesitter.configs'.setup {
                -- A list of parser names, or "all" (the five listed parsers should always be installed)
                ensure_installed = ensure_installed,

                -- Install parsers synchronously (only applied to `ensure_installed`)
                sync_install = false,

                -- Automatically install missing parsers when entering buffer
                -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
                auto_install = true,

                -- List of parsers to ignore installing (for "all")
                -- ignore_install = { "javascript" },

                ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
                -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

                highlight = {
                    enable = true,
                    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
                    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
                    -- the name of the parser)
                    -- list of language that will be disabled
                    -- disable = { "c", "rust" },
                    -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
                    -- disable = function(lang, buf)
                    --    local max_filesize = 100 * 1024 -- 100 KB
                    --    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                    --    if ok and stats and stats.size > max_filesize then
                    --        return true
                    --    end
                    -- end,

                    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
                    -- Using this option may slow down your editor, and you may see some duplicate highlights.
                    -- Instead of true it can also be a list of languages
                    additional_vim_regex_highlighting = false,
                },

                -- doesnt work.. ?
                -- matchup = {
                --     enable = true,
                -- },

                textobjects = {
                    lsp_interop = {
                        enable = true,
                        border = 'none',
                        floating_preview_opts = {},
                        peek_definition_code = {
                            ["<leader>df"] = { query = "@function.outer", desc = "Peek function definition" },
                            ["<leader>dc"] = { query = "@class.outer", desc = "Peek class definition" },
                        },
                    },
                    select = {
                        enable = true,
                        -- Automatically jump forward to textobj, similar to targets.vim
                        lookahead = true,
                        keymaps = {
                            -- You can use the capture groups defined in textobjects.scm
                            ["ac"] = { query = "@class.outer", desc = "Select class (outer)" },
                            ["ic"] = { query = "@class.inner", desc = "Select class (inner)" },
                            ["af"] = { query = "@function.outer", desc = "Select function (outer)" },
                            ["if"] = { query = "@function.inner", desc = "Select function (inner)" },
                            ["al"] = { query = "@loop.outer", desc = "Select loop (outer)" },
                            ["il"] = { query = "@loop.inner", desc = "Select loop (inner)" },
                            ["ab"] = { query = "@block.outer", desc = "Select block (outer)" },
                            ["ib"] = { query = "@block.inner", desc = "Select block (inner)" },
                            ["aa"] = { query = "@parameter.outer", desc = "Select argument (outer)" },
                            ["ia"] = { query = "@parameter.inner", desc = "Select argument (inner)" },
                            -- You can also use captures from other query groups like `locals.scm`
                            ["as"] = { query = "@local.scope", query_group = "locals", desc = "Select language scope" },
                        },
                        -- Mapping query_strings to modes.
                        selection_modes = {
                            ['@parameter.outer'] = 'v', -- charwise
                            ['@function.outer'] = 'V',  -- linewise
                            ['@class.outer'] = '<c-v>', -- blockwise
                        },
                    },
                    move = {
                        enable = true,
                        set_jumps = true,
                        goto_next_start = {
                            ["]f"] = { query = "@function.outer", desc = "Next function" },
                            ["]c"] = { query = "@class.outer", desc = "Next class" },
                            ["]["] = { query = "@block.outer", desc = "Next block" },
                            ["]s"] = { query = "@local.scope", query_group = "locals", desc = "Next scope" },
                        },
                        goto_next_end = {
                            ["]F"] = { query = "@function.outer", desc = "Next function (end)" },
                            ["]C"] = { query = "@class.outer", desc = "Next class (end)" },
                            ["]]"] = { query = "@block.outer", desc = "Next block (end)" },
                            ["]S"] = { query = "@local.scope", query_group = "locals", desc = "Next scope (end)" },
                        },
                        goto_previous_start = {
                            ["[f"] = { query = "@function.outer", desc = "Previous function" },
                            ["[c"] = { query = "@class.outer", desc = "Previous class" },
                            ["[["] = { query = "@block.outer", desc = "Previous block" },
                            ["[s"] = { query = "@local.scope", query_group = "locals", desc = "Previous scope" },
                        },
                        goto_previous_end = {
                            ["[F"] = { query = "@function.outer", desc = "Previous function (end)" },
                            ["[C"] = { query = "@class.outer", desc = "Previous class (end)" },
                            ["[]"] = { query = "@block.outer", desc = "Previous block (end)" },
                            ["[S"] = { query = "@local.scope", query_group = "locals", desc = "Previous scope (end)" },
                        },
                    },
                }
            }
        end
    },
}
