require('compat')

---@class gamma.context.KeymapOpts
---@field [1] string Keymap pattern (first positional element).
---@field [2] string Commentary

---@class gamma.context.PluginOpts
---@field [1] string Name of the plugin (first positional element). Will get installed with `Plug` command in the vimrc file.
---@field enabled? boolean Whether the plugin is enabled. defaults to true.
---@field context? string[] Context in which the plugin should be enabled
---                         in the vimrc file and will be tested with `has()`.
---                        Prefix with `!` to disable the plugin in that context. E.g. '!ide' for !has('ide').
---@field mappings? string[] Mappings to set for the plugin.
---@field plug? table Plug options.
---@field config? fun():string[] | string[] Plugin configuration function or list of lines. Can be used to add more custom settings for the plugin.
---                        Should return a list of lines to be added to the vimrc file.

---@class gamma.context.Vimrc
---@field top string[] List of lines to include at the top of the vimrc file.
---@field middle string[] List of lines to include at the middle of the vimrc file.
---@field bottom string[] List of lines to include at the bottom of the vimrc file.
---@field plugs gamma.context.PluginOpts[] List of plugins to be included in the vimrc.
---@field exports string[] List of options to export.
---                        Will look for these options in the gamma.set module, otherwise in the current Neovim session.
---@field mappings gamma.context.KeymapOpts[] General keymap patterns to add to the vimrc file.
---@field substitutions table<string, string> Function to vimscript substitutions for function-based keymaps.
---@field exclude_mappings table<string, true> Keys to exclude from vimrc export (format: "mode:keys")
---@type gamma.context.Vimrc
local M = {
    top = {
        'set encoding=utf-8',
        'language en_US',
        '',
        '" Enable 24-bit color if supported',
        'if has(\'termguicolors\')',
        '    set termguicolors',
        'endif',
        '',
        '" Directories',
        'if has(\'persistent_undo\')',
        '    set undodir=~/.vim/undo',
        '    silent !mkdir -p ~/.vim/undo',
        'endif',
        -- 'set backupdir=~/.vim/backup//,.',
        -- 'silent !mkdir -p ~/.vim/backup'
    },
    middle = {
        'set ffs=unix,dos,mac', -- file formats
    },
    bottom = {},

    exports = {
        'mapleader', 'maplocalleader',
        'number', 'relativenumber', 'tabstop', 'softtabstop', 'shiftwidth',
        'expandtab', 'smartindent', 'breakindent', 'undofile', 'ignorecase',
        'smartcase', 'hlsearch', 'incsearch', 'wrap',
        'scrolloff', 'signcolumn', 'autoread', 'updatetime', 'list',
        'showbreak', 'listchars', 'completeopt', 'clipboard', 'mouse',
        'wrapmargin', 'autoindent', 'smarttab',
        'termguicolors', 'timeout', 'timeoutlen', 'isfname', 'guifont',
        'fileformats', 'encoding', 'langmap', 'ffs'
        -- Shell configuration (platform-specific)
        -- 'shell', 'shellcmdflag', 'shellredir', 'shellpipe', 'shellquote', 'shellxquote'
    },

    mappings = {
        -- Remap substitutions
        { 'nnoremap <C-q> :close<CR>',                    'Close current window/buffer' },
        { 'inoremap <C-q> :close<CR>',                    'Close current window/buffer' },
        { 'vnoremap <C-q> :close<CR>',                    'Close current window/buffer' },
        -- Buffer operations
        { 'nnoremap <leader>bb :buffers<CR>', 'List buffers' },
        { 'nnoremap <leader>bd :bdelete<CR>', 'Delete buffer' },
        { 'nnoremap <leader>bn :bnext<CR>', 'Next buffer' },
        { 'nnoremap <leader>bp :bprevious<CR>', 'Previous buffer' },
        { 'nnoremap <leader>b! :bwipeout<CR>', 'Wipeout buffer' },
        { 'nnoremap <leader>b/ :BLines<CR>', 'Search buffer lines' },
        
        -- Toggle operations
        { 'nnoremap <leader>tr :set relativenumber!<CR>', 'Toggle relative numbers' },
        { 'nnoremap <leader>ts :set spell!<CR>', 'Toggle spell check' },
        { 'nnoremap <leader>tw :set wrap!<CR>', 'Toggle line wrap' },
        
        -- Quick operations
        { 'nnoremap <leader>qw :w<CR>', 'Quick write' },
        { 'nnoremap <leader>qq :q<CR>', 'Quick quit' },
        { 'nnoremap <leader>qa :qa<CR>', 'Quit all' },
        
        -- Movement enhancements
        { 'nnoremap <C-d> <C-d>zz', 'Scroll down and center' },
        { 'nnoremap <C-u> <C-u>zz', 'Scroll up and center' },
        { 'nnoremap n nzzzv', 'Next search result centered' },
        { 'nnoremap N Nzzzv', 'Previous search result centered' },
        
        -- Text manipulation
        { 'vnoremap J :m \'>+1<CR>gv=gv', 'Move selection down' },
        { 'vnoremap K :m \'<-2<CR>gv=gv', 'Move selection up' },
    },
    plugs = {},
    -- Keys to exclude from vimrc export (format: "mode:keys")
    exclude_mappings = {
        -- Note: These are checked against the RHS content, not just the key
        ['hlslens'] = true,  -- Exclude any mapping whose RHS contains 'hlslens'
    },

    -- Function to vimscript substitutions for common function-based keymaps
    substitutions = {
        -- Buffer operations
        ['vim.cmd.buffers'] = ':buffers<CR>',
        ['vim.cmd.bdelete'] = ':bdelete<CR>',
        ['vim.cmd.bnext'] = ':bnext<CR>',
        ['vim.cmd.bprevious'] = ':bprevious<CR>',
        ['vim.cmd.bwipeout'] = ':bwipeout<CR>',

        -- File operations
        ['vim.cmd.write'] = ':w<CR>',
        ['vim.cmd.quit'] = ':q<CR>',

        -- Vim settings toggles
        ['set wrap!'] = ':set wrap!<CR>',
        ['set relativenumber!'] = ':set relativenumber!<CR>',

        -- File operations
        ['utility.create_cmd("file")'] = '<cmd>file<CR>',

        -- Disable mappings
        ['<nop>'] = '<nop>',

        -- Reload commands
        ['checktime.*edit'] = ':e<CR>',
        ['vim%.cmd%(\"checktime\"%);.*vim%.cmd%(\"edit\"%);'] = ':e<CR>',

        -- Complex function patterns (matched with string.match)
        ['write.*quit'] = ':wq<CR>',
        ['wrap'] = ':set wrap!<CR>',
        ['relativenumber'] = ':set relativenumber!<CR>',
        
        -- hlslens plugin substitutions (remove lua calls for pure vim)
        -- Match the exact strings from the RHS
        ["<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>"] = 'nzzzv',
        ["<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>"] = 'Nzzzv',
    },
}


--- Add a plugin to the list of enabled vimrc plugins.
---@param opts (gamma.context.PluginOpts | string)[] Options for the plugin.
local function plugins(opts)
    local plugin_list = {}
    for _, opt in ipairs(opts) do
        if type(opt) == "string" then
            table.insert(plugin_list, { name = opt, enabled = true })
        elseif type(opt) == "table" then
            -- Set default enabled to true if not specified
            if opt.enabled == nil then
                opt.enabled = true
            end
            table.insert(plugin_list, opt)
        end
    end

    for _, p in ipairs(plugin_list) do
        if p.enabled ~= false then
            table.insert(M.plugs, p)
        end
    end
end



-- Enabled plugins
plugins {
    {
        'tpope/vim-fugitive',
        mappings = {
            'nnoremap <leader>gs :G<CR>',
            'nnoremap <leader>gd :Gdiff<CR>',
            'nnoremap <leader>gc :G commit<CR>',
            'nnoremap <leader>gp :G push<CR>'
        },
        config = function()
            return {} -- lines to be added to vimrc
        end
    },
    'tpope/vim-repeat',
    { 'tpope/vim-commentary',
        config = function()
            return {
                '" Match Comment.nvim default mappings',
                'nmap gcc <Plug>CommentaryLine',
                'nmap gc <Plug>Commentary',
                'xmap gc <Plug>Commentary',
                'nmap gcu <Plug>Commentary<Plug>Commentary'
            }
        end
    },
    { 'machakann/vim-sandwich',
        config = function()
            return {
                '" Add aliases to match mini.surround config',
                '" Standard aliases',
                'nmap ds <Plug>(sandwich-delete)',
                'nmap cs <Plug>(sandwich-replace)',
                'nmap ys <Plug>(sandwich-add)',
                'xmap ys <Plug>(sandwich-add)',
                '" Backwards aliases (using , suffix for previous)',
                'nmap Sa <Plug>(sandwich-add),',
                'nmap Sr <Plug>(sandwich-replace),',
                'nmap Sd <Plug>(sandwich-delete),',
                'nmap Sf <Plug>(sandwich-query-n),',
                'xmap Sa <Plug>(sandwich-add),',
                'xmap Sr <Plug>(sandwich-replace),',
                'xmap Sd <Plug>(sandwich-delete),'
            }
        end
    },
    'tpope/vim-sleuth',
    { 'justinmk/vim-sneak',
        config = function()
            return {
                '" Match leap.nvim functionality (updated to gs/gS)',
                'let g:sneak#label = 1',
                'let g:sneak#use_ic_scs = 1',
                'map gs <Plug>Sneak_s',
                'map gS <Plug>Sneak_S',
                'xmap gs <Plug>Sneak_s',
                'xmap gS <Plug>Sneak_S',
                'omap gs <Plug>Sneak_s',
                'omap gS <Plug>Sneak_S',
                '" Aliases for leap motions',
                'map sg <Plug>Sneak_s',
                'map Sg <Plug>Sneak_S',
                'xmap sg <Plug>Sneak_s',
                'xmap Sg <Plug>Sneak_S',
                'omap sg <Plug>Sneak_s',
                'omap Sg <Plug>Sneak_S'
            }
        end
    },
    { 'unblevable/quick-scope',
        config = function()
            return {
                '" Quick-scope configuration',
                'let g:qs_highlight_on_keys = ["f", "F", "t", "T"]',
                'let g:qs_buftype_blacklist = ["terminal", "nofile"]',
                'let g:qs_filetype_blacklist = ["help", "terminal", "dashboard"]',
                '" Highlighting for quick-scope',
                'highlight QuickScopePrimary guifg=#afff5f gui=underline ctermfg=155 cterm=underline',
                'highlight QuickScopeSecondary guifg=#5fffff gui=underline ctermfg=81 cterm=underline'
            }
        end
    },
    { 'wellle/targets.vim',
        config = function()
            return {
                '" targets.vim configuration (mini.ai alternative)',
                '" Match mini.ai functionality as closely as possible',
                '',
                '" Enable seeking for quotes and brackets (matches mini.ai search_method)',
                'let g:targets_seekRanges = "cr cb cB lc ac Ac lr rr ll lb ar ab lB Ar aB Ab AB rb al rB Al bb aa bB Aa BB AA"',
                '',
                '" Set search range (matches mini.ai n_lines = 50)',
                'let g:targets_nl = 50',
                '',
                '" Enable next/last variants (partially matches mini.ai an/in/al/il)',
                'let g:targets_aiAI = 1',
                '',
                '" Custom mappings to simulate mini.ai next/last functionality',
                '" Leverage targets.vim\'s built-in seeking capabilities',
                '',
                '" Note: targets.vim already provides enhanced seeking automatically',
                '" These mappings add directional variants similar to mini.ai',
                '',
                '" Around/Inside Next - use targets.vim\'s forward seeking',
                'onoremap an a)',
                'onoremap aN a}',
                'onoremap a<lt>n a>',
                'onoremap a"n a"',
                'onoremap a\'n a\'',
                'xnoremap an a)',
                'xnoremap aN a}',
                'xnoremap a<lt>n a>',
                'xnoremap a"n a"',
                'xnoremap a\'n a\'',
                '',
                'onoremap In i)',
                'onoremap IN i}',
                'onoremap i<lt>n i>',
                'onoremap i"n i"',
                'onoremap i\'n i\'',
                'xnoremap In i)',
                'xnoremap IN i}',
                'xnoremap i<lt>n i>',
                'xnoremap i"n i"',
                'xnoremap i\'n i\'',
                '',
                '" Goto text object edges (simplified approach)',
                'nnoremap g[ [{',
                'nnoremap g] ]}',
                '',
                '" Enhanced text object seeking with targets.vim',
                '" targets.vim automatically seeks forward/backward as needed',
                '" The above mappings provide directional hints for specific cases'
            }
        end
    },
    { 'matze/vim-move',
        mappings = {
            '" vim-move configuration (mini.move alternative)',
            'vmap <C-S-j> <Plug>MoveBlockDown',
            'vmap <C-S-k> <Plug>MoveBlockUp',
            'vmap <C-S-h> <Plug>MoveBlockLeft',
            'vmap <C-S-l> <Plug>MoveBlockRight',
            'nmap <C-S-j> <Plug>MoveLineDown',
            'nmap <C-S-k> <Plug>MoveLineUp',
            'nmap <C-S-h> <Plug>MoveCharLeft',
            'nmap <C-S-l> <Plug>MoveCharRight'
        }
    },
    { 'junegunn/fzf',
        plug = { ["do"] = "{ -> fzf#install() }" },
        mappings = {
            'nnoremap <leader>ff :Files<CR>',
            'nnoremap <leader>fs :Rg<CR>',
            'nnoremap <leader>bf :Buffers<CR>',
            'nnoremap <leader>fh :History<CR>',
            'nnoremap <leader>fr :file<CR>'
        }
    },
    'junegunn/fzf.vim',
    { 'mbbill/undotree',
        mappings = {
            'nnoremap <leader>wu :UndotreeToggle<CR>'
        }
    },
    { 'andymass/vim-matchup',
        config = function()
            return {
                'let g:matchup_matchparen_offscreen = { "method": "popup" }'
            }
        end
    },
    { 'preservim/nerdtree',
        context = { '!ide' },
        mappings = {
            'nnoremap <leader><tab> :NERDTreeToggle<CR>'
        }
    },
    { 'vim-airline/vim-airline',
        context = { '!ide' }
    },
    { 'vim-airline/vim-airline-themes',
        context = { '!ide' }
    }
}


return M;
