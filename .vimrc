" .vimrc - Auto-generated from current Neovim configuration
" Generated on: 2025-06-23 16:00:08
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

set list
set smarttab
set number
set breakindent
set ignorecase
set smartindent
set incsearch
set completeopt=menuone,noselect
set listchars=extends:⟩,eol:↲,precedes:⟨,trail:·,nbsp:␣,tab:» 
set nowrap
set encoding=utf-8
set smartcase
set relativenumber
set softtabstop=4
set timeoutlen=300
set expandtab
set wrapmargin=2
set showbreak=↪ 
set tabstop=4
set autoread
set timeout
set scrolloff=8
set signcolumn=yes
set undofile
set updatetime=50
set clipboard=unnamedplus
set hlsearch
set shiftwidth=4
set termguicolors
set autoindent

" ============================================================================
" MIDDLE CONFIGURATION
" ============================================================================

set ffs=unix,dos,mac

" ============================================================================
" KEYMAPS (from remap files)
" ============================================================================

" Init (lua/gamma/remap/init.lua)
" Disable quit via Q
nmap Q <nop>
" Redo
nmap U <C-r>

" Movement (lua/gamma/remap/movement.lua)
nmap [q <nop>
nmap ]q <nop>
" Next search result
nmap n nzzzv
" Previous search result
nmap N Nzzzv
" Half page down
nmap <C-d> <C-d>zz
" Half page up
nmap <C-u> <C-u>zz
" Move cursor left
inoremap <A-h> <Left>
" Move cursor down
inoremap <A-j> <Down>
" Move cursor up
inoremap <A-k> <Up>
" Move cursor right
inoremap <A-l> <Right>
" Move to beginning of word
imap <silent> <A-b> <C-o>b
" Move to next word
imap <silent> <A-w> <C-o>w
" Move to end of word
imap <silent> <A-e> <C-o>e
" Move to beginning of line
nmap <silent> H ^
" Move to beginning of line
vmap <silent> H ^
" Move to end of line
nmap <silent> L $
" Move to end of line
vmap <silent> L $
" Next quickfix item
nmap <silent> ]q :cnext<CR>
" Previous quickfix item
nmap <silent> [q :cprev<CR>

" Text (lua/gamma/remap/text.lua)
nmap Y y$
" Join lines (keep cursor position)
nmap J mzJ`z
" Paste without overwriting register
xmap p "_dP
" Yank line to system clipboard
nmap Y mc"+Y`c
" Cut current line
nmap X dd
" Paste from system clipboard in command mode
cmap <C-v> <C-r>+

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
Plug 'tpope/vim-surround'
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

" justinmk/vim-sneak configuration
" Match leap.nvim functionality
let g:sneak#label = 1
let g:sneak#use_ic_scs = 1
map s <Plug>Sneak_s
map S <Plug>Sneak_S
xmap s <Plug>Sneak_s
xmap S <Plug>Sneak_S
omap s <Plug>Sneak_s
omap S <Plug>Sneak_S

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
omap an a)
omap aN a}
omap a<lt>n a>
omap a"n a"
omap a'n a'
xmap an a)
xmap aN a}
xmap a<lt>n a>
xmap a"n a"
xmap a'n a'

omap In i)
omap IN i}
omap i<lt>n i>
omap i"n i"
omap i'n i'
xmap In i)
xmap IN i}
xmap i<lt>n i>
xmap i"n i"
xmap i'n i'

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
