local utility = require('gamma.utility')
local kmap = utility.kmap

local M = {
    config = function(_, opts)
        require("noice").setup(opts)

        kmap('n', '<leader>qn', function()
            vim.cmd.NoiceDismiss()
        end, "[D]ismiss all [n]otifications")
    end,
    opts = {
        cmdline = {
            view = "cmdline_popup", -- view for rendering the cmdline. Change to `cmdline` to get a classic cmdline at the bottom
            format = {
                conceal = false,
                filter = false,
            }
        },
        messages = {
            view = 'mini', -- default view
            view_error = 'notify',
            view_warn = 'notify',
        },
        format = {
            -- default format
            default = { "{level} ", "{title} ", "{message}" },
            -- default format for vim.notify views
            notify = { "{message}" },
        },
        lsp = {
            -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
            override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.stylize_markdown"] = true,
                ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
            },
            hover = {
                enable = false,
            },
            signature = {
                enable = false
            }
        },
        views = {
            notify = {
                merge = true,
                replace = false,
            },
            cmdline_popup = {
                position = {
                    row = 5,
                    col = "50%",
                },
                size = {
                    width = 60,
                    height = "auto",
                },
            },
            popupmenu = {
                relative = "editor",
                position = {
                    row = 8,
                    col = "50%",
                },
                size = {
                    width = 60,
                    height = 10,
                },
                border = {
                    style = "rounded",
                    padding = { 0, 1 },
                },
                win_options = {
                    winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
                },
            },
        },
        routes = {
            -- Hide annoying bg color warning
            {
                filter = {
                    find = "Highlight group 'NotifyBackground' has no background highlight",
                },
                opts = { skip = true },
            },
            -- Always route any messages with more than 10 lines to the split view
            {
                view = "split",
                filter = { event = "msg_show", min_height = 15, ["not"] = { kind = { "search_count", "echo" } }, },
            },

            -- Block on error messages, require user to acknowledge
            {
                view = "notify",
                filter = { error = true, blocking = true },
            },

            -- Hide Search Virtual Text
            {
                filter = {
                    event = "msg_show",
                    kind = "search_count",
                },
                opts = { skip = true },
            },
            -- Route written messages to the mini view
            {
                view = 'mini',
                filter = {
                    error = false,
                    warning = false,
                    event = "msg_show",
                    find = "written",
                },
                -- opts = { skip = true },
            },
            -- Route config changed msg to the mini view
            {
                view = 'mini',
                filter = {
                    find = "# Config Change Detected. Reloading",
                },
            },

            -- Show @recording messages
            {
                view = "notify",
                filter = { event = "msg_showmode", find = "recording @" },
            },

            -- Show mode change messages
            {
                view = "cmdline",
                filter = { event = "msg_showmode", }
            },

            -- Default titles
            {
                view = "notify",
                filter = { error = true },
                opts = {
                    title = "Error",
                },
            },

            {
                view = "notify",
                filter = { warning = true },
                opts = {
                    title = "Warning",
                },
            },
            {
                view = "notify",
                filter = { event = "notify", error = false, warning = false },
                opts = {
                    title = ""
                },
            },
        },
        -- you can enable a preset for easier configuration
        presets = {
            bottom_search = false,        -- use a classic bottom cmdline for search
            command_palette = true,       -- position the cmdline and popupmenu together
            long_message_to_split = true, -- long messages will be sent to a split
            inc_rename = false,           -- enables an input dialog for inc-rename.nvim
            lsp_doc_border = false,       -- add a border to hover docs and signature help
        },
        -- You can add any custom commands below that will be available with `:Noice command`
        ---@type table<string, NoiceCommand>
        commands = {
            history = {
                -- options for the message history that you get with `:Noice`
                view = "split",
                opts = { enter = true, format = "details" },
                filter = {
                    any = {
                        { event = "notify" },
                        { error = true },
                        { warning = true },
                        { event = "msg_show", kind = { "" } },
                        { event = "lsp",      kind = "message" },
                    },
                },
            },
            log = {
                view = "popup",
                opts = { enter = true, format = "details" },
                filter = {},
            },
            -- :Noice last
            last = {
                view = "popup",
                opts = { enter = true, format = "details" },
                filter = {
                    any = {
                        { event = "notify" },
                        { error = true },
                        { warning = true },
                        { event = "msg_show", kind = { "" } },
                        { event = "lsp",      kind = "message" },
                    },
                },
                filter_opts = { count = 1 },
            },
            -- :Noice errors
            errors = {
                -- options for the message history that you get with `:Noice`
                view = "popup",
                opts = { enter = true, format = "details" },
                filter = { error = true },
                filter_opts = { reverse = true },
            },
            all = {
                -- options for the message history that you get with `:Noice`
                view = "split",
                opts = { enter = true, format = "details" },
                filter = {},
            },
        },
    }
}



return M
