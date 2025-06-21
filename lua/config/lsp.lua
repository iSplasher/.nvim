local utility = require('gamma.utility')
local kmap = utility.kmap

local M = {
    disabled = {
        'TelescopePrompt',
        'spectre_panel',
        'dashboard',
        "wk", "WhichKey", "TelescopePrompt",
        "TelescopeResults", "mason", "lazy",
        "alpha", "dashboard"
    },
    -- https://github.com/williamboman/mason-lspconfig.nvim?tab=readme-ov-file#available-lsp-servers
    ensure_installed = {
        'diagnosticls',
        'marksman',
        'jsonls',
        'yamlls',
        'lua_ls',
        'harper_ls'
    },

    -- opts for neovim/nvim-lspconfig
    lspconfig_opts = function(_)
        return {
            servers = {
                jsonls = {
                    settings = {
                        json = {
                            schemas = require('schemastore').json.schemas(),
                            validate = { enable = true },
                        },
                    },
                },
                yamlls = {
                    schemaStore = {
                        -- You must disable built-in schemaStore support if you want to use
                        -- this plugin and its advanced options like `ignore`.
                        enable = false,
                        -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
                        url = "",
                    },
                    schemas = require('schemastore').yaml.schemas(),
                },
            }
        }
    end
}


-- Autocompletion configuration
M.blink_opts = function(_, opts)
    local lspkind = require('lspkind')

    -- ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    -- ['<C-d>'] = cmp.mapping.scroll_docs(4),

    utility.merge_table(opts, {
        -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept, C-n/C-p for up/down)
        -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys for up/down)
        -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
        --
        -- All presets have the following mappings:
        -- C-space: Open menu or open docs if already open
        -- C-e: Hide menu
        -- C-k: Toggle signature help
        --
        -- See the full "keymap" documentation for information on defining your own keymap.
        keymap = { preset = 'enter' },
        enabled = function()
            return not vim.tbl_contains(M.disabled, vim.bo.filetype)
                and vim.bo.buftype ~= "prompt"
                and vim.b.completion ~= false
        end,
        completion = {
            trigger = {
                show_on_trigger_character = true,
                show_on_keyword = true,
                show_on_insert_on_trigger_character = true,
                show_on_blocked_trigger_characters = {},
            },
            menu = {
                winblend = 30,
                border = 'single',
                draw = {
                    components = {
                        kind_icon = {
                            ellipsis = false,
                            text = function(ctx)
                                local icon = ctx.kind_icon
                                icon = lspkind.symbolic(ctx.kind, {
                                    mode = "symbol",
                                    symbol_map = {
                                        Copilot = "",
                                    },
                                    before = function(entry, vim_item)
                                        return vim_item
                                    end
                                })

                                return icon .. ctx.icon_gap
                            end
                        },
                        label = {
                            text = function(ctx)
                                return require("colorful-menu").blink_components_text(ctx)
                            end,
                            highlight = function(ctx)
                                return require("colorful-menu").blink_components_highlight(ctx)
                            end,
                        },
                    },
                    columns = { { 'kind_icon', gap = 1 }, { 'label', gap = 1 }, { "kind", gap = 1 },
                        { "source_name" } }
                }
            }
        },
        -- Show documentation when selecting a completion item
        --   documentation = {
        -- auto_show = true,
        --   auto_show_delay_ms = 500,
        --   window = {
        --     winblend = 30,
        --   }
        -- },
        signature = { enabled = true, window = { border = 'padded' } },
        appearance = {
            -- Sets the fallback highlight groups to nvim-cmp's highlight groups
            -- Useful for when your theme doesn't support blink.cmp
            -- Will be removed in a future release
            use_nvim_cmp_as_default = true,
            -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
            -- Adjusts spacing to ensure icons are aligned
            nerd_font_variant = 'mono'
        },
        -- Default list of enabled providers defined so that you can extend it
        -- elsewhere in your config, without redefining it, due to `opts_extend`
        sources = {
            default = function(ctx)
                local success, node = pcall(vim.treesitter.get_node)
                local s = { 'copilot' }
                if vim.bo.filetype == 'lua' then
                    vim.list_extend(s, { 'lazydev', 'lsp', 'path', 'snippets' })
                elseif success and node and vim.tbl_contains({ 'comment', 'line_comment', 'block_comment' }, node:type()) then
                    vim.list_extend(s, { 'buffer' })
                else
                    vim.list_extend(s, { 'lsp', 'path', 'snippets', 'buffer' })
                end
                return s
            end,
            providers = {
                lazydev = {
                    name = "LazyDev",
                    module = "lazydev.integrations.blink",
                    -- make lazydev completions top priority (see `:h blink.cmp`)
                    score_offset = 100,
                },
                copilot = {
                    name = "copilot",
                    module = "blink-cmp-copilot",
                    score_offset = 100,
                    async = true,
                },
            },
        },
        -- Blink.cmp uses a Rust fuzzy matcher by default for typo resistance and significantly better performance

        -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
        --
        -- See the fuzzy documentation for more information
        fuzzy = { implementation = "prefer_rust_with_warning" },
        -- Use a preset for snippets, check the snippets documentation for more information
        snippets = { preset = 'default' },
    })
end



-- lspconfig configuration
M.lspconfig_config = function(_, opts)
    local lsp_defaults = require('lspconfig').util.default_config

    -- Set up diagnostics
    local ds = vim.diagnostic.severity
    local ds_icons = {
        [ds.ERROR] = '',
        [ds.WARN] = '',
        [ds.HINT] = '',
        [ds.INFO] = '',
    }
    local ds_hls = {
        [ds.ERROR] = 'DiagnosticSignError',
        [ds.WARN] = 'DiagnosticSignWarn',
        [ds.HINT] = 'DiagnosticSignHint',
        [ds.INFO] = 'DiagnosticSignInfo',
    }

    vim.diagnostic.config({
        underline = function(namespace, bufnr)
            -- Disable underlines for UI buffers
            local ft = vim.api.nvim_get_option_value('filetype', { buf = bufnr })
            for _, ui_ft in ipairs(M.disabled) do
                if ft == ui_ft then
                    return {
                        severity = {}
                    }
                end
            end
            return {
                severity = { min = ds.HINT },
            }
        end,
        virtual_text = {
            severity = { min = ds.INFO },
            prefix = function(diagnostic, i, total)
                local s = ds_icons[diagnostic.severity] or ''
                if i == 1 then
                    if total == 1 then
                        return string.format('%s', s)
                    else
                        return string.format('%s (%d)', s, total)
                    end
                end
                return ''
            end,
            format = function(diagnostic)
                if not diagnostic.source or diagnostic.source == "" then
                    return string.format('%s', diagnostic.message)
                end
                local s = diagnostic.source:gsub(' Diagnostics.', '')
                return string.format('%s [%s]', diagnostic.message, s)
            end,
        },
        signs = {
            text = ds_icons,
            texthl = ds_hls,
        },
        update_in_insert = true,
        severity_sort = true,
        float = {
            source = true,
            border = "rounded",
        },
    })

    -- Auto formatting
    -- Switch for controlling whether you want autoformatting.
    --  Use :KickstartFormatToggle to toggle autoformatting on or off
    local format_is_enabled = true
    vim.api.nvim_create_user_command('FormatToggle', function()
        format_is_enabled = not format_is_enabled
        print('Setting autoformatting to: ' .. tostring(format_is_enabled))
    end, {})

    -- Create an augroup that is used for managing our formatting autocmds.
    --      We need one augroup per client to make sure that multiple clients
    --      can attach to the same buffer without interfering with each other.
    local _augroups = {}
    local get_augroup = function(client)
        if not _augroups[client.id] then
            local group_name = 'lsp-format-' .. client.name
            local id = vim.api.nvim_create_augroup(group_name, { clear = true })
            _augroups[client.id] = id
        end

        return _augroups[client.id]
    end

    -- Whenever an LSP attaches to a buffer, we will run this function.
    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach-format', { clear = true }),
        -- This is where we attach the autoformatting for reasonable clients
        callback = function(args)
            local client_id = args.data.client_id
            local client = vim.lsp.get_client_by_id(client_id)
            if not client then
                return
            end
            local bufnr = args.buf

            -- Only attach to clients that support document formatting
            if not client.server_capabilities.documentFormattingProvider then
                return
            end

            -- Tsserver usually works poorly. Sorry you work with bad languages
            -- You can remove this line if you know what you're doing :)
            if client.name == 'tsserver' then
                return
            end

            -- Create an autocmd that will run *before* we save the buffer.
            --  Run the formatting command for the LSP that has just attached.
            vim.api.nvim_create_autocmd('BufWritePre', {
                group = get_augroup(client),
                buffer = bufnr,
                callback = function()
                    if not format_is_enabled then
                        return
                    end

                    vim.lsp.buf.format {
                        async = false,
                        filter = function(c)
                            return c.id == client.id
                        end,
                    }
                end,
            })
        end,
    })

    -- LspAttach is where you enable features that only work
    -- if there is a language server active in the file
    vim.api.nvim_create_autocmd('LspAttach', {
        desc = 'LSP actions',
        callback = function(event)
            local opts = { buffer = event.buf }

            
            local nmap = function(keys, func, desc)
                utility.kmap('n', keys, func, { buffer = opts.buffer, remap = false, desc = desc })
            end

            nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
            nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

            nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
            nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
            nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
            nmap('<leader>ld', vim.lsp.buf.type_definition, 'Type [D]efinition')

            -- See `:help K` for why this keymap
            nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
            nmap('<C-i>', vim.lsp.buf.signature_help, 'Signature Documentation')

            -- Lesser used LSP functionality
            nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
            nmap('<leader>lwa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
            nmap('<leader>lwr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
            nmap('<leader>lwl', function()
                print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            end, '[W]orkspace [L]ist Folders')

            -- Create a command `:Format` local to the LSP buffer
            vim.api.nvim_buf_create_user_command(opts.buffer, 'Format', function(_)
                vim.lsp.buf.format()
            end, { desc = 'Format current buffer with LSP' })
        end
    })


    require('mason-lspconfig').setup({
        ensure_installed = M.ensure_installed,
        handlers = {
            -- this first function is the "default handler"
            -- it applies to every language server without a "custom handler"
            function(server_name)
                -- get cfg from opts

                local cfg = opts.servers[server_name] or {}

                cfg.capabilities = require('blink.cmp').get_lsp_capabilities(cfg.capabilities)
                require('lspconfig')[server_name].setup(cfg)
            end,
        }
    })
end

return M
