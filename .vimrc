" .vimrc - Auto-generated from current Neovim configuration
" Generated on: 2025-06-29 01:59:50
" Exported from Neovim session using gamma.vimrc configuration

" ============================================================================
" TOP CONFIGURATION
" ============================================================================

set encoding=utf-8
language en_US

" Enable 24-bit color if supported
if has('termguicolors')
    set termguicolors
endif

" Directories
if has('persistent_undo')
    set undodir=~/.vim/undo
    silent !mkdir -p ~/.vim/undo
endif

" ============================================================================
" GLOBAL VARIABLES
" ============================================================================

let g:maplocalleader = ","
let g:mapleader = " "

" ============================================================================
" VIM OPTIONS (from current session)
" ============================================================================

set smartindent
set incsearch
set updatetime=50
set showbreak=↪ 
set wrapmargin=2
set autoindent
set smarttab
set undofile
set number
set termguicolors
set timeout
set timeoutlen=500
set list
set relativenumber
set signcolumn=yes
set completeopt=menuone,noselect
set clipboard=unnamedplus
set listchars=trail:·,tab:» ,extends:⟩,nbsp:␣,eol:↲,precedes:⟨
set tabstop=4
set expandtab
set nowrap
set shiftwidth=4
set smartcase
set ignorecase
set autoread
set encoding=utf-8
set scrolloff=8
set hlsearch
set breakindent
set softtabstop=4

" ============================================================================
" MIDDLE CONFIGURATION
" ============================================================================

set ffs=unix,dos,mac

" ============================================================================
" KEYMAPS (from remap files)
" ============================================================================

" Lua\gamma\remap\init (lua\gamma\remap\init.lua)
" Disable quit via Q
nnoremap Q <nop>
" Redo
nnoremap U <C-r>

" Lua\gamma\remap\leader\file (lua\gamma\remap\leader\file.lua)
nnoremap  !q <cmd>echo "Custom keymap from lua\gamma\remap\leader\file.lua:12"<CR>
nnoremap  q! <cmd>echo "Custom keymap from lua\gamma\remap\leader\file.lua:12"<CR>

" Lua\gamma\remap\movement (lua\gamma\remap\movement.lua)
" Next search result
nnoremap n nzzzv
" Previous search result
nnoremap N Nzzzv
" Half page down
nnoremap <silent> <nowait> <C-d> <C-d>zz
" Half page up
nnoremap <silent> <nowait> <C-u> <C-u>zz
" Move cursor left
inoremap <silent> <A-h> <Left>
" Move cursor down
inoremap <silent> <A-j> <Down>
" Move cursor up
inoremap <silent> <A-k> <Up>
" Move cursor right
inoremap <silent> <A-l> <Right>
" Move to beginning of word
inoremap <silent> <A-b> <C-o>b
" Move to next word
inoremap <silent> <A-w> <C-o>w
" Move to end of word
inoremap <silent> <A-e> <C-o>e
" Move to beginning of line
nnoremap <silent> H ^
" Move to beginning of line
vnoremap <silent> H ^
" Move to end of line
nnoremap <silent> L $
" Move to end of line
vnoremap <silent> L $
" Next quickfix item
nnoremap <silent> ]q :cnext<CR>
" Previous quickfix item
nnoremap <silent> [q :cprev<CR>

" Lua\gamma\remap\text (lua\gamma\remap\text.lua)
" Join lines (keep cursor position)
nnoremap J mzJ`z
" Paste without overwriting register
xnoremap p "_dP
" Yank line to system clipboard
nnoremap <silent> Y mc"+Y`c
" Delete to void register
nnoremap d "_d
" Delete to void register
vnoremap d "_d
" Yank character to numbered register then delete
nnoremap x yl"_dl
" Yank line to numbered register then delete
nnoremap X yy"_dd
" Copy to system clipboard
nnoremap <silent> <C-c> "+y
" Copy to system clipboard
vnoremap <silent> <C-c> "+y
" Paste from system clipboard in command mode
cnoremap <silent> <C-v> <C-r>+

" ============================================================================
" KEYMAPS (from vimrc config)
" ============================================================================

" Close current window/buffer
nnoremap <C-q> :close<CR>
" Close current window/buffer
inoremap <C-q> :close<CR>
" Close current window/buffer
vnoremap <C-q> :close<CR>
" List buffers
nnoremap <leader>bb :buffers<CR>
" Delete buffer
nnoremap <leader>bd :bdelete<CR>
" Next buffer
nnoremap <leader>bn :bnext<CR>
" Previous buffer
nnoremap <leader>bp :bprevious<CR>
" Wipeout buffer
nnoremap <leader>b! :bwipeout<CR>
" Search buffer lines
nnoremap <leader>b/ :BLines<CR>
" Toggle relative numbers
nnoremap <leader>tr :set relativenumber!<CR>
" Toggle spell check
nnoremap <leader>ts :set spell!<CR>
" Toggle line wrap
nnoremap <leader>tw :set wrap!<CR>
" Quick write
nnoremap <leader>qw :w<CR>
" Quick quit
nnoremap <leader>qq :q<CR>
" Quit all
nnoremap <leader>qa :qa<CR>
" Scroll down and center
nnoremap <C-d> <C-d>zz
" Scroll up and center
nnoremap <C-u> <C-u>zz
" Next search result centered
nnoremap n nzzzv
" Previous search result centered
nnoremap N Nzzzv
" Move selection down
vnoremap J :m '>+1<CR>gv=gv
" Move selection up
vnoremap K :m '<-2<CR>gv=gv

" ============================================================================
" PLUGIN MANAGEMENT (vim-plug)
" ============================================================================

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" Plugins from configuration
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'
Plug 'machakann/vim-sandwich'
Plug 'tpope/vim-sleuth'
Plug 'justinmk/vim-sneak'
Plug 'unblevable/quick-scope'
Plug 'wellle/targets.vim'
Plug 'matze/vim-move'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'mbbill/undotree'
Plug 'andymass/vim-matchup'
if (!has('ide'))
    Plug 'preservim/nerdtree'
endif
if (!has('ide'))
    Plug 'vim-airline/vim-airline'
endif
if (!has('ide'))
    Plug 'vim-airline/vim-airline-themes'
endif

call plug#end()

" ============================================================================
" PLUGIN CONFIGURATIONS
" ============================================================================

" tpope/vim-fugitive configuration
nnoremap <leader>gs :G<CR>
nnoremap <leader>gd :Gdiff<CR>
nnoremap <leader>gc :G commit<CR>
nnoremap <leader>gp :G push<CR>

" tpope/vim-commentary configuration
" Match Comment.nvim default mappings
nmap gcc <Plug>CommentaryLine
nmap gc <Plug>Commentary
xmap gc <Plug>Commentary
nmap gcu <Plug>Commentary<Plug>Commentary

" machakann/vim-sandwich configuration
" Add aliases to match mini.surround config
" Standard aliases
nmap ds <Plug>(sandwich-delete)
nmap cs <Plug>(sandwich-replace)
nmap ys <Plug>(sandwich-add)
xmap ys <Plug>(sandwich-add)
" Backwards aliases (using , suffix for previous)
nmap Sa <Plug>(sandwich-add),
nmap Sr <Plug>(sandwich-replace),
nmap Sd <Plug>(sandwich-delete),
nmap Sf <Plug>(sandwich-query-n),
xmap Sa <Plug>(sandwich-add),
xmap Sr <Plug>(sandwich-replace),
xmap Sd <Plug>(sandwich-delete),

" justinmk/vim-sneak configuration
" Match leap.nvim functionality (updated to gs/gS)
let g:sneak#label = 1
let g:sneak#use_ic_scs = 1
map gs <Plug>Sneak_s
map gS <Plug>Sneak_S
xmap gs <Plug>Sneak_s
xmap gS <Plug>Sneak_S
omap gs <Plug>Sneak_s
omap gS <Plug>Sneak_S
" Aliases for leap motions
map sg <Plug>Sneak_s
map Sg <Plug>Sneak_S
xmap sg <Plug>Sneak_s
xmap Sg <Plug>Sneak_S
omap sg <Plug>Sneak_s
omap Sg <Plug>Sneak_S

" unblevable/quick-scope configuration
" Quick-scope configuration
let g:qs_highlight_on_keys = ["f", "F", "t", "T"]
let g:qs_buftype_blacklist = ["terminal", "nofile"]
let g:qs_filetype_blacklist = ["help", "terminal", "dashboard"]
" Highlighting for quick-scope
highlight QuickScopePrimary guifg=#afff5f gui=underline ctermfg=155 cterm=underline
highlight QuickScopeSecondary guifg=#5fffff gui=underline ctermfg=81 cterm=underline

" wellle/targets.vim configuration
" targets.vim configuration (mini.ai alternative)
" Match mini.ai functionality as closely as possible

" Enable seeking for quotes and brackets (matches mini.ai search_method)
let g:targets_seekRanges = "cr cb cB lc ac Ac lr rr ll lb ar ab lB Ar aB Ab AB rb al rB Al bb aa bB Aa BB AA"

" Set search range (matches mini.ai n_lines = 50)
let g:targets_nl = 50

" Enable next/last variants (partially matches mini.ai an/in/al/il)
let g:targets_aiAI = 1

" Custom mappings to simulate mini.ai next/last functionality
" Leverage targets.vim's built-in seeking capabilities

" Note: targets.vim already provides enhanced seeking automatically
" These mappings add directional variants similar to mini.ai

" Around/Inside Next - use targets.vim's forward seeking
onoremap an a)
onoremap aN a}
onoremap a<lt>n a>
onoremap a"n a"
onoremap a'n a'
xnoremap an a)
xnoremap aN a}
xnoremap a<lt>n a>
xnoremap a"n a"
xnoremap a'n a'

onoremap In i)
onoremap IN i}
onoremap i<lt>n i>
onoremap i"n i"
onoremap i'n i'
xnoremap In i)
xnoremap IN i}
xnoremap i<lt>n i>
xnoremap i"n i"
xnoremap i'n i'

" Goto text object edges (simplified approach)
nnoremap g[ [{
nnoremap g] ]}

" Enhanced text object seeking with targets.vim
" targets.vim automatically seeks forward/backward as needed
" The above mappings provide directional hints for specific cases

" matze/vim-move configuration
" vim-move configuration (mini.move alternative)
vmap <C-S-j> <Plug>MoveBlockDown
vmap <C-S-k> <Plug>MoveBlockUp
vmap <C-S-h> <Plug>MoveBlockLeft
vmap <C-S-l> <Plug>MoveBlockRight
nmap <C-S-j> <Plug>MoveLineDown
nmap <C-S-k> <Plug>MoveLineUp
nmap <C-S-h> <Plug>MoveCharLeft
nmap <C-S-l> <Plug>MoveCharRight

" junegunn/fzf configuration
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fs :Rg<CR>
nnoremap <leader>bf :Buffers<CR>
nnoremap <leader>fh :History<CR>
nnoremap <leader>fr :file<CR>

" mbbill/undotree configuration
nnoremap <leader>wu :UndotreeToggle<CR>

" andymass/vim-matchup configuration
let g:matchup_matchparen_offscreen = { "method": "popup" }

" preservim/nerdtree configuration
nnoremap <leader><tab> :NERDTreeToggle<CR>

" ============================================================================
" AUTO-GENERATED CONTENT END
" ============================================================================

" Add your custom vim configurations below this line
