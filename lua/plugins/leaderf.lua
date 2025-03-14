local utility = require('gamma.utility')
local kmap = utility.kmap

return {
    {
        'Yggdroot/LeaderF',
        build = ':LeaderfInstallCExtension',
        
        init = function()
            -- these break the plugin for some reason
            -- vim.g.Lf_ShortcutF = ''
            -- vim.g.Lf_ShortcutB = ''
            -- vim.g.Lf_WindowPosition = 'popup'
            -- vim.g.Lf_CommandMap = { ['<C-K>'] = '<Up>',['<C-J>'] = '<Down>' }
        end,
        config = function()
            kmap('n', "<leader>f", '<nop>', {})
            kmap('n', "<leader>b", '<nop>', {})

            kmap('n', "<leader>ff", vim.cmd.LeaderfFile, "Find [F]ile", {})
            kmap('n', "<leader>f#", vim.cmd.LeaderfRgInteractive, "Find Interactive", {})
            kmap('n', "<leader>fw", vim.cmd.LeaderfWindow, "Find [W]indow", {})
            kmap('n', "<leader>fl", vim.cmd.LeaderfLine, "Find [L]ine", {})
        end
    },

    {
        'folke/which-key.nvim',
        event = 'VeryLazy',
        priorty = 200,
        opts = {},
        config = function(_, opts)
            vim.opt.timeout = true
            vim.opt.timeoutlen = 300
            require('which-key').setup {

            }
        end
    },
    
}
