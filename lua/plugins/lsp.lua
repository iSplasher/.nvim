local utility = require('gamma.utility')

local ensure_installed = {
    'eslint',
    'diagnosticls',
    'marksman',
    'jsonls'
}

return {
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        version = false,
        dependencies = {
            -- LSP Support
            {
                'neovim/nvim-lspconfig',
                version = false,
            }, -- Required
            {
                'folke/neodev.nvim',
                config = function()
                    require('neodev').setup()
                end
            },
            {
                -- Optional
                'williamboman/mason.nvim',
                version = false,
                build = function()
                    pcall(vim.cmd, 'MasonUpdate')
                end
            },
            {
                'williamboman/mason-lspconfig.nvim',
                version = false,
            }, -- Optional

            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },     -- Required
            { 'hrsh7th/cmp-nvim-lsp' }, -- Required
            { 'L3MON4D3/LuaSnip' },     -- Required

            { 'onsails/lspkind.nvim' }
        },
        config = function()
            local lsp = require('lsp-zero')

            lsp.set_sign_icons({
                Error = '',
                Warning = '',
                Hint = '',
                Information = '',
            })

            require('mason').setup({})
            require('mason-lspconfig').setup({
                ensure_installed = ensure_installed,
                handlers = {
                    lsp.default_setup,
                    lua_ls = function()
                        local lua_opts = lsp.nvim_lua_ls()
                        require('lspconfig').lua_ls.setup(lua_opts)
                    end,
                }
            })

            -- setup autocompletion
            local cmp = require('cmp')
            local cmp_format = lsp.cmp_format()
            local lspkind = require('lspkind')
            local lsp_cmp_format = lspkind.cmp_format({
                menu = nil,
                before = cmp_format.format,
                symbol_map = {
                    Copilot = "",
                }
            })

            cmp.setup {
                formatting = utility.merge_table(cmp_format, {
                    format = lsp_cmp_format
                }),
                mapping = cmp.mapping.preset.insert({
                    -- scroll up and down the documentation window
                    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-d>'] = cmp.mapping.scroll_docs(4),
                }),
            }

            lsp.on_attach(function(client, bufnr)
                -- NOTE: Remember that lua is a real programming language, and as such it is possible
                -- to define small helper and utility functions so you don't have to repeat yourself
                -- many times.
                --
                -- In this case, we create a function that lets us more easily define mappings specific
                -- for LSP related items. It sets the mode, buffer and description for us each time.
                local nmap = function(keys, func, desc)
                    if desc then
                        desc = 'LSP: ' .. desc
                    end

                    vim.keymap.set('n', keys, func, { buffer = bufnr, remap = false, desc = desc })
                end

                nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
                nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

                nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
                nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
                nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
                nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
                nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
                nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

                -- See `:help K` for why this keymap
                nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
                nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

                -- Lesser used LSP functionality
                nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
                nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
                nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
                nmap('<leader>wl', function()
                    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                end, '[W]orkspace [L]ist Folders')

                -- Create a command `:Format` local to the LSP buffer
                vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
                    vim.lsp.buf.format()
                end, { desc = 'Format current buffer with LSP' })

                -- default mappings (won't override the ones we already set above)
                lsp.default_keymaps({ buffer = bufnr, preserve_mappings = true })
            end)

            lsp.setup()
        end
    }
}
