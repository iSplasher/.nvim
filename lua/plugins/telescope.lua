local utility = require('gamma.utility')

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

            utility.kmap('n', '<leader>/', function()
                -- You can pass additional configuration to telescope to change theme, layout, etc.
                builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                    winblend = 10,
                    previewer = false,
                })
            end, '[/] Fuzzily search in current buffer')


            utility.kmap('n', '<leader>pf', builtin.find_files, '[P]ick [F]ile')
            utility.kmap('n', '<leader>gf', builtin.git_files, '[G]it [F]iles')

            local grep_search = function()
                builtin.grep_string({ search = vim.fn.input("Grep > ") });
            end
            utility.kmap('n', '<leader>ps', grep_search, '[G]rep in Files')
            utility.kmap('n', '<leader>sg', grep_search, '[G]rep in Files', { remap = true })

            utility.kmap('n', '<leader>bf', builtin.buffers, '[F]ind [B]uffer', { remap = true })
            utility.kmap('n', '<leader>fb', builtin.buffers, '[F]ind [B]uffer', { remap = true })
        end
    },
}
