local utility = require('gamma.utility')
local kmap = utility.kmap

local M = {
    opts = {
        preset = "modern",
        triggers = {
            { "<auto>", mode = "nxso" },
            { "*",      mode = { "n", "v" } },
            { "<C>",    mode = { "v", "n", "v" } },
        },
        defer = function(ctx)
            return vim.list_contains({ "v", "<C-V>", "V", 'T', 't', 'C', 'c' }, ctx.mode)
        end,
        keys = {
            scroll_down = "<Down>",     -- Use down arrow to scroll down
            scroll_up = "<Up>",         -- Use up arrow to scroll up
        },
    },

    config = function(_, opts)
        local wk = require("which-key")
        wk.setup(opts)

        -- Register leader key mappings
        wk.add({
            {
                "<leader>_",
                function()
                    wk.show({ loop = true })
                end,
                desc = "Buffer keymaps",
                icon = { name = "buffer", icon = "󰈚", color = "cyan" }
            },
            {
                "<leader><leader>",
                function()
                    -- Show buffer-local keymaps
                    wk.show({ mode = "n", buffer = 0 })
                end,
                desc = "Buffer keymaps",
                icon = { name = "buffer", icon = "󰈚", color = "cyan" }
            },
            {
                "<leader>w",
                group = "Windows",
                expand = function()
                    return require("which-key.extras").expand.win()
                end
            },
            {
                "<leader>b",
                group = "Buffers",
                expand = function()
                    return require("which-key.extras").expand.buf()
                end
            },
            { "<leader>f", group = "[F]ind | [F]iles", icon = { name = 'file', icon = '', color = 'azure' } },
            { "<leader>t", group = "[T]oggles" },
            { "<leader>r", group = "[R]un | [R]ename" },
            { "<leader>p", group = "[P]roject | Workspace" },
            { "<leader>e", group = "[E]dit" },
            { "<leader>j", group = "[J]ump" },
            { "<leader>k", group = "[K]ill" },
            { "<leader>a", group = "[A]ctions" },
            { "<leader>i", group = "[I]nteractive" },
            { "<leader>g", group = "[G]it | [G]lobal", icon = { name = 'git', icon = '', color = 'red' } },
            { "<leader>d", group = "[D]ebug" },
            { "<leader>h", group = "[H]istory" },
            { "<leader>l", group = "[L]SP" },
            { "<leader>n", group = "[N]ew" },
            { "<leader>z", group = "[Z]en" },
            { "<leader>o", group = "[O]pen" },
            { "<leader>s", group = "[S]earch" },
            { "<leader>c", group = "[C]ode" },
            { "<leader>v", group = "[V]im" },
            { "<leader>wt", group = "[T]erminal" },
            { "<leader>;", group = "[C]ommands" },
            { "<leader>?", group = "Help" },
            { "<leader>@", group = "Registers" },

            { "<leader>0", group = "[0]" },
            { "<leader>1", group = "[1]" },
            { "<leader>2", group = "[2]" },
            { "<leader>3", group = "[3]" },
            { "<leader>4", group = "[4]" },
            { "<leader>5", group = "[5]" },
            { "<leader>6", group = "[6]" },
            { "<leader>7", group = "[7]" },
            { "<leader>8", group = "[8]" },
            { "<leader>9", group = "[9]" },
            { "<leader>!", group = "[!]" },

            { "<leader>#", group = "[#]" },
            { "<leader>+", group = "[+]" },
        })
    end
}

return M
