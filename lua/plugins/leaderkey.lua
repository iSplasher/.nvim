local utility = require('gamma.utility')
local kmap = utility.kmap
local wkcfg = require('config.whick_key')

return {
    {
        'Yggdroot/LeaderF',
        build = ':LeaderfInstallCExtension',
        cmd = { 'Leaderf', 'LeaderfInstallCExtension' },
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

            kmap('n', "<leader>fw", vim.cmd.LeaderfWindow, "Find [W]indow", {})
            kmap('n', "<leader>fl", vim.cmd.LeaderfLine, "Find [L]ine", {})
        end
    },

    {
        'isplasher-forks/which-key.nvim',
        event = 'VeryLazy',
        priorty = 200,
        opts = wkcfg.opts,
        config = wkcfg.config,
        init = function()
            -- This option and 'timeoutlen' determine the behavior when part of a
            -- mapped key sequence has been received. For example, if <c-f> is
            -- pressed and 'timeout' is set, Nvim will wait 'timeoutlen' milliseconds
            -- for any key that can follow <c-f> in a mapping.
            vim.opt.timeout = true
            vim.opt.timeoutlen = 300
        end
    },

}
