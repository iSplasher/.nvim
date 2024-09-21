local utility = require('gamma.utility')
local kmap = utility.kmap

return {
  -- 'machakann/vim-sandwich',
    -- 'tpope/vim-surround',
    'tpope/vim-commentary',
    {
        'unblevable/quick-scope',
        lazy = false,
        init = function()
            vim.g.qs_highlight_on_keys = { 'f', 'F', 't', 'T' }
            vim.g.qs_buftype_blacklist = { 'terminal', 'nofile' }
            vim.g.qs_filetype_blacklist = { 'help', 'terminal', 'dashboard' }

            if vim.g.vscode then
                -- set highlighting groups
                vim.cmd("highlight QuickScopePrimary guifg='#afff5f' gui=underline ctermfg=155 cterm=underline")
                vim.cmd("highlight QuickScopeSecondary guifg='#5fffff' gui=underline ctermfg=81 cterm=underline")
            end
        end
    },
    
}
