require('compat')

---@class gamma.context.KeymapOpts
---@field [1] string Keymap pattern (first positional element).
---@field [2] string Commentary

---@class gamma.context.PluginOpts
---@field [1] string Name of the plugin (first positional element).
---@field enabled? boolean Whether the plugin is enabled. defaults to true.
---@field context? string[] Context in which the plugin should be enabled
---                         in the vimrc file and will be tested with `has()`.
---                        Prefix with `!` to disable the plugin in that context. E.g. '!ide' for !has('ide').
---@field mappings? string[] Mappings to set for the plugin.
---@field plug? table Plug options.
---@field config? function | string[] Plugin configuration function or list of lines. Can be used to add more custom settings for the plugin.
---                        Should return a list of lines to be added to the vimrc file.

---@class gamma.context.Vimrc
---@field top string[] List of lines to include at the top of the vimrc file.
---@field middle string[] List of lines to include at the middle of the vimrc file.
---@field bottom string[] List of lines to include at the bottom of the vimrc file.
---@field plugs gamma.context.PluginOpts[] List of plugins to be included in the vimrc.
---@field exports string[] List of options to export.
---                        Will look for these options in the gamma.set module, otherwise in the current Neovim session.
---@field mappings gamma.context.KeymapOpts[] Keymap patterns to add to the vimrc file.
---@type gamma.context.Vimrc
local M = {
    top = {
        'set encoding=utf-8',
        'language en_US',
        '',
        '" Directories',
        'if has(\'persistent_undo\')',
        '    set undodir=~/.vim/undo',
        '    silent !mkdir -p ~/.vim/undo',
        'endif',
        -- 'set backupdir=~/.vim/backup//,.',
        -- 'silent !mkdir -p ~/.vim/backup'
    },
    middle = {},
    bottom = {},

    exports = {
        'mapleader', 'maplocalleader', 'backupdir',
        'number', 'relativenumber', 'tabstop', 'softtabstop', 'shiftwidth',
        'expandtab', 'smartindent', 'breakindent', 'undofile', 'ignorecase',
        'smartcase', 'hlsearch', 'incsearch', 'wrap', 'termguicolors',
        'scrolloff', 'signcolumn', 'autoread', 'updatetime', 'list',
        'showbreak', 'listchars', 'completeopt', 'clipboard', 'mouse'
    },

    mappings = {},
    plugs = {},
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
        mappings = {
            'nnoremap <leader>cc :Commentary<CR>',
            'vnoremap <leader>cc :Commentary<CR>'
        }
    },
    'tpope/vim-surround',
    { 'junegunn/fzf',
        plug = { ["do"] = "{ -> fzf#install() }" },
        mappings = {
            'nnoremap <leader>pf :Files<CR>',
            'nnoremap <leader>ff :Files<CR>',
            'nnoremap <leader>fb :Buffers<CR>',
            'nnoremap <leader>fh :History<CR>',
            'nnoremap <leader>fs :Rg<CR>',
            'nnoremap <leader>sg :Rg<CR>'
        }
    },
    'junegunn/fzf.vim',
    { 'preservim/nerdtree',
        context = { '!ide' },
        mappings = {
            '" nnoremap <leader>pt :NERDTreeToggle<CR>'
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
