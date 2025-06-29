local utility = require('gamma.utility')
local deferred_wk_args = require('gamma.utility.keymap')._deferred_wk_args
local kmap = utility.kmap

-- buftypes that should not show whick-key
local disabled_buftypes = {
    "Dashboard",
    "TelescopePrompt",
    "Trouble",
    "notify",
    "qf",
    "lspinfo",
    "lsp-installer",
    "mason",
    "lazy",
    "toggleterm",
}
-- filetypes that should not show whick-key
local disabled_filetypes = {
}

local localleadermapping = "<leader><localleader>"
local M = {
    disabled_buftypes = disabled_buftypes,
    disabled_filetypes = disabled_filetypes,
    opts = {
        preset = "modern",
        padding  = { 1, 1 }, -- extra window padding [top/bottom, right/left]
        win      = {
            bo = {},
            wo = {
                -- no spelling
                spell = false,
            }
        },
        layout   = {
            spacing = 2, -- spacing between columns
        },
        --- Mappings are sorted using configured sorters and natural sort of the keys
        --- Available sorters:
        --- * local: buffer-local mappings first
        --- * order: order of the items (Used by plugins like marks / registers)
        --- * group: groups last
        --- * alphanum: alpha-numerical first
        --- * mod: special modifier keys last
        --- * manual: the order the mappings were added
        --- * case: lower-case first
        sort     = { "order", "alphanum" },
        expand   = 1, -- expand groups when <= n mappings
        icons    = {
            separator = "󰁔", -- separator icon
        },
        disable  = {
            ft = disabled_filetypes, -- disable for these filetypes
            bt = disabled_buftypes,  -- disable for these buftypes
        },
        triggers = {
            { "<auto>",   mode = "nvxso" },
            { "*",        mode = "nvxso" },
            { "<C>",      mode = "vnxsot" },
            { "r",        mode = "nvxso" },
            { "<leader>", mode = "nvxso" },
            { "s",        mode = "nvxso" },
            { "S",        mode = "nvxso" },
            { "f",        mode = "nvxso" },
            { "F",        mode = "nvxso" },
            { "t",        mode = "nvxso" },
            { "T",        mode = "nvxso" },
        },
        keys = {
            scroll_down = "<Down>",     -- Use down arrow to scroll down
            scroll_up = "<Up>",         -- Use up arrow to scroll up
        },
        defer    = function(ctx)
            local mode = ctx.mode
            local operator = ctx.operator
            -- If the mode is this we defer which-key to second key press
            if vim.list_contains({ "d", "c", "y" }, operator) then
                return true
            end

            -- return vim.list_contains({ "v", "<C-V>", "V", 'T', 't', 'C', 'c' }, mode)
            return vim.list_contains({ "v", "V", "<C-V>", }, mode) and operator == nil
        end,
        filter   = function(mapping)
            -- exclude mappings without a description
            return mapping.desc and mapping.desc ~= ""
        end,
        show     = function(filter, node, current_node)
            -- if buffer is local, don't show leader key mappings
            if filter.global ~= nil and filter.global == false then
                local lhs = utility.get_key(node.lhs)
                local leaderkey = utility.get_key("<leader>")
                local m = lhs and string.sub(lhs, 1, #leaderkey) == leaderkey
                if m then
                    return false -- don't show global leader key mappings in local context
                end
            end
            return true
        end,
    },

    config = function(_, opts)
        local wk = require("which-key")
        wk.setup(opts)

        -- Register leader key mappings
        wk.add({
            {
                localleadermapping,
                function()
                    -- Show buffer-local keymaps
                    local buf = vim.api.nvim_get_current_buf()
                    local mode = vim.api.nvim_get_mode().mode
                    wk.show({ global = false, ["local"] = true, buf = buf, mode = mode, expand = true })
                end,
                desc = "Local keymaps",
                icon = { name = "buffer", icon = "󰈚", color = "cyan" },
            },
            {
                "<leader>w",
                group = "[W]indows",
            },
            {
                "<leader>ww",
                group = "[W]indows",
                expand = function()
                    return require("which-key.extras").expand.win()
                end
            },
            {
                "<leader>b",
                group = "Buffers",
            },
            {
                "<leader>bb",
                group = "Buffers",
                expand = function()
                    return require("which-key.extras").expand.buf()
                end
            },
            { "<leader>f", group = "[F]ind | [F]iles", icon = { name = 'file', icon = '', color = 'azure', cat = "file" } },
            { "<leader>t", group = "[T]oggles", icon = { name = 'toggle', icon = '', color = 'orange' } },
            { "<leader>r", group = "[R]un" },
            -- { "<leader>p", group = "[P]roject | Workspace", icon = { name = 'project', icon = '', color = 'purple' } },

            { "<leader>e", group = "[E]dit", icon = { name = 'edit', icon = '✎', color = 'yellow' } },
            { "<leader>j", group = "[J]ump" },
            { "<leader>m", group = "[M]ark" },
            { "<leader>q", group = "[Q]uit/Close actions", icon = { name = 'quit', icon = '󰈆', color = 'red' } },
            -- { "<leader>a", group = "[A]ctions" },
            { "<leader>bh", group = "[H]arpoon" },
            { "<leader>g", group = "[G]it | [G]lobal", icon = { name = 'git', icon = '', color = 'red' } },
            { "<leader>d", group = "[D]ebug" },
            { "<leader>l", group = "[L]SP" },
            { "<leader>lw", group = "[W]orkspace", icon = { name = 'workspace', icon = '', color = 'blue' } },
            { "<leader>/", group = "Terminal", icon = { name = 'terminal', icon = '', color = 'purple' } },
            { "<leader>;", group = "[C]ommands", icon = { name = 'command', icon = '', color = 'purple' } },

            { "<leader>?", group = "Help", icon = { name = 'help', icon = '󰘥', color = 'blue' } },
            { "<leader>@", group = "Registers" },


            { "<leader>!", group = "[!]" },

            { "<leader>#", group = "[#]" },
            { "<leader>+", group = "[+]" },
        })
        if vim.tbl_count(deferred_wk_args) > 0 then
            wk.add(deferred_wk_args)
        end
    end
}

return M
