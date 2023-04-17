return {
    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        -- or                            , branch = '0.1.x',
        dependencies = {
            { 'nvim-lua/plenary.nvim' },
            'nvim-telescope/telescope-ui-select.nvim',
        },
        config = function()
            require('telescope').setup {}

            -- Enable telescope fzf native, if installed
            pcall(require('telescope').load_extension, 'fzf')

            require('telescope').load_extension('ui-select')

            local builtin = require('telescope.builtin')

            vim.keymap.set('n', '<leader>/', function()
                -- You can pass additional configuration to telescope to change theme, layout, etc.
                builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                    winblend = 10,
                    previewer = false,
                })
            end, { desc = '[/] Fuzzily search in current buffer' })


            vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
            vim.keymap.set('n', '<leader>gf', builtin.git_files, {})
            vim.keymap.set('n', '<leader>ps', function()
                builtin.grep_string({ search = vim.fn.input("Grep > ") });
            end)
        end
    },
}
