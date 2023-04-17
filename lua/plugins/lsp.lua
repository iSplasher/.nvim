return {
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        dependencies = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' }, -- Required
            {
                'folke/neodev.nvim',
                config = function()
                    require('neodev').setup()
                end
            },
            {
                -- Optional
                'williamboman/mason.nvim',
                build = function()
                    pcall(vim.cmd, 'MasonUpdate')
                end
            },
            { 'williamboman/mason-lspconfig.nvim' }, -- Optional

            -- Autocompletion
            {
                'hrsh7th/nvim-cmp',
                config = function()
                    local cmp = require("cmp")
                    cmp.setup({
                        mapping = {
                            -- If nothing is selected (including preselections) add a newline as usual.
                            -- If something has explicitly been selected by the user, select it.
                            ["<Enter>"] = function(fallback)
                                -- Don't block <CR> if signature help is active
                                -- https://github.com/hrsh7th/cmp-nvim-lsp-signature-help/issues/13
                                if not cmp.visible() or not cmp.get_selected_entry() or cmp.get_selected_entry().source.name == 'nvim_lsp_signature_help' then
                                    fallback()
                                else
                                    cmp.confirm({
                                        -- Replace word if completing in the middle of a word
                                        -- https://github.com/hrsh7th/nvim-cmp/issues/664
                                        behavior = cmp.ConfirmBehavior.Replace,
                                        -- Don't select first item on CR if nothing was selected
                                        select = false,
                                    })
                                end
                            end,
                            ["<Tab>"] = cmp.mapping(function(fallback)
                                -- This little snippet will confirm with tab, and if no entry is selected, will confirm the first item
                                if cmp.visible() then
                                    local entry = cmp.get_selected_entry()
                                    if not entry then
                                        cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                                    else
                                        cmp.confirm()
                                    end
                                else
                                    fallback()
                                end
                            end, { "i", "s", "c", }),
                        }
                    })
                end
            },                          -- Required

            { 'hrsh7th/cmp-nvim-lsp' }, -- Required
            { 'L3MON4D3/LuaSnip' },     -- Required
        },
        config = function()
            local lsp = require('lsp-zero').preset({})

            lsp.ensure_installed({
                'tsserver',
                'eslint'
            })

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
            end)

            -- (Optional) Configure lua language server for neovim
            require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

            lsp.setup()
        end
    }
}
