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
            kmap('n', "<leader>f", '<nop>', { remap = true})
            kmap('n', "<leader>b", '<nop>', { remap = true})

            kmap('n', "<leader>ff", vim.cmd.LeaderfFile, "Find [F]ile", { remap = true})
            kmap('n', "<leader>fh", vim.cmd.LeaderfHelp, "Find [H]elp", { remap = true})
            kmap('n', "<leader>fm", vim.cmd.LeaderfMru, "Find [M]ost [R]ecently [U]sed", { remap = true})
            kmap('n', "<leader>fs", vim.cmd.LeaderfGTagsSymbol, "Find [S]ymbol", { remap = true})
            kmap('n', "<leader>f#", vim.cmd.LeaderfRgInteractive, "Find Interactive", { remap = true})
            kmap('n', "<leader>fc", vim.cmd.LeaderfCommand, "Find [C]ommand", { remap = true})
            kmap('n', "<leader>fw", vim.cmd.LeaderfWindow, "Find [W]indow", { remap = true})
            kmap('n', "<leader>fl", vim.cmd.LeaderfLine, "Find [L]ine", { remap = true})
        end
    },

    {
        'folke/which-key.nvim',
        
        config = function()
            vim.opt.timeout = true
            vim.opt.timeoutlen = 300
            require('which-key').setup {

            }
        end
    },
    
}
