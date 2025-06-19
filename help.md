# Advanced Neovim Movement and Editing Techniques

This guide covers advanced movement and editing techniques for Neovim, organized by functional categories and tailored to your specific setup.

## 1. Navigation & Movement

### 1.1 Cursor Movement

#### Precision Jumping
- `s{char}{char}` - Jump forward to a position matching these two characters¹
- `S{char}{char}` - Jump backward to a position matching these two characters¹
- `gs{char}{char}` - Jump to any visible window (cross-window jump)¹

#### Horizontal Navigation
- `f{char}`/`F{char}` - Jump to next/previous occurrence of character (enhanced with highlighting)²
- `t{char}`/`T{char}` - Jump to before next/previous occurrence of character (enhanced with highlighting)²
- `;`/`,` - Repeat previous f/t/F/T movement forward/backward
- `ge`/`gE` - Jump backwards to end of word (WORD)
- `g_` - Jump to last non-blank character of line
- `0` - Jump to start of line
- `^` - Jump to first non-blank character of line
- `H` - Jump to first non-whitespace character in line³
- `L` - Jump to end of line³

#### Vertical Navigation
- `gj`/`gk` - Move cursor down/up (multi-line text, respects wrapping)
- `<C-j>` - Move cursor down intelligently⁴
- `<C-k>` - Move cursor up intelligently⁴
- `zz`/`zt`/`zb` - Center/top/bottom cursor on screen
- `Ctrl+e`/`Ctrl+y` - Scroll screen down/up one line (cursor stays)
- `Ctrl+d`/`Ctrl+u` - Move cursor and screen down/up 1/2 page
- `n`/`N` - Next/previous search result (centered on screen)³

#### Insert Mode Navigation
- `Alt` + `h/j/k/l` - Move cursor while staying in insert mode³
- `Alt` + `b/w/e` - Word movement in insert mode³
- `Ctrl+h` - Delete character before cursor during insert
- `Ctrl+w` - Delete word before cursor during insert
- `Ctrl+t`/`Ctrl+d` - Indent/de-indent line during insert
- `Ctrl+n`/`Ctrl+p` - Auto-complete next/previous match
- `Ctrl+r{register}` - Insert contents of register
- `Ctrl+o{command}` - Execute one normal mode command, return to insert

### 1.2 Code Structure Navigation

#### Function/Class Navigation
- `]f`/`[f` - Go to next/previous function start⁵
- `]F`/`[F` - Go to next/previous function end⁵
- `]c`/`[c` - Go to next/previous class start⁵
- `]C`/`[C` - Go to next/previous class end⁵

#### Block Navigation
- `][`/`[[` - Go to next/previous block start⁵
- `]]`/`[]` - Go to next/previous block end⁵
- `]s`/`[s` - Go to next/previous scope start⁵
- `]S`/`[S` - Go to next/previous scope end⁵

#### Pair Matching
- `%` - Jump between matching pairs (brackets, if/endif, etc.) with enhanced capabilities⁶
- Visual indication of matching pairs, even off-screen⁶

### 1.3 List Navigation
- `]q`/`[q` - Next/previous quickfix list item³
- `<leader>fq` - List items in the quickfix list⁷
- `<leader>fj` - Jump list⁷

## 2. Text Selection

### 2.1 Semantic Text Objects

#### Code Structure Objects
- `as`/`is` - Select language scope⁵
- `ac`/`ic` - Select class (outer/inner)⁵
- `af`/`if` - Select function (outer/inner)⁵
- `al`/`il` - Select loop (outer/inner)⁵
- `ab`/`ib` - Select block (outer/inner)⁵
- `aa`/`ia` - Select argument (outer/inner)⁵

#### Special Text Objects
- `aB`/`iB` - Select entire buffer⁸
- `at`/`it` - A/inner block with <> tags
- `ab`/`ib` - A/inner block with () (same as a(/i()
- `aw`/`iw` - A/inner word

### 2.2 Visual Mode Enhancements
- Expand/contract selections using TreeSitter nodes⁵
- Precognition highlights showing motion targets⁹
- `o` - Move to other end of visual selection
- `O` - Move to other corner of visual block
- `u`/`U` - Change selected text to lowercase/uppercase
- `~` - Switch case of selected text

## 3. Editing & Manipulation

### 3.1 Text Manipulation

#### Line and Selection Movement
- `<C-S-h>` / `<C-S-left>` - Move selection/line left¹⁰
- `<C-S-l>` / `<C-S-right>` - Move selection/line right¹⁰
- `<C-S-k>` / `<C-S-up>` - Move selection/line up¹⁰
- `<C-S-j>` / `<C-S-down>` - Move selection/line down¹⁰

#### Clipboard Management
- `p` in visual mode - Paste without overwriting register³
- `y` - Copy to system clipboard while preserving cursor position³
- `d` - Delete to void register instead of overwriting clipboard³
- `X` - Cut current line³
- `J` - Join lines while preserving cursor position³
- `gJ` - Join line below without adding space
- `gp`/`gP` - Paste and leave cursor after new text

#### Advanced Text Manipulation
- `R` - Replace mode (keep typing to replace characters)
- `xp` - Transpose two letters (delete and paste)
- `U` - Restore last changed line
- `gwip` - Reflow paragraph
- `g~`/`gu`/`gU` - Switch case/lowercase/uppercase up to motion

#### Code Commenting
- Smart auto-detection of comment styles¹¹
- Contextual commenting, handles mixed language files¹¹

### 3.2 Advanced Operators & LSP Integration

#### Operator + Motion Combinations
- `d]f` - Delete to next function
- `y]c` - Yank to next class
- `c][` - Change to next block

#### LSP Code Actions
- `<leader>rn` - Rename symbol
- `<leader>ca` - Code action
- `gd` - Go to definition
- `gr` - Find references
- `gI` - Go to implementation
- `K` - Show hover documentation

#### Repeating Operations
- `.` - Repeat last change
- `@:` - Repeat last command
- `@@` - Repeat last macro

#### Diagnostic Navigation
- `<leader>lx` - Toggle Trouble diagnostics panel
- `<leader>lw` - Workspace diagnostics
- `<leader>ld` - Document diagnostics

## 4. Multi-file & Project Navigation

### 4.1 File Navigation
- `<leader>pf` - Find files⁷
- `<leader>fs` - Grep in files⁷
- `<leader>bf` - Find buffers⁷
- `<leader>b/` - Fuzzy find in current buffer⁷
- `<leader>pt` - Toggle project file tree¹⁷

### 4.2 Terminal Integration
- `<leader>/` - Toggle floating terminal¹⁸
- `<leader>tf` - Toggle floating terminal¹⁸
- `<leader>th` - Create horizontal terminal¹⁸
- `<leader>tv` - Create vertical terminal¹⁸
- `<esc>` or `jk` in terminal mode - Exit terminal mode¹⁸
- `<C-h/j/k/l>` in terminal mode - Navigate between windows¹⁸

### 4.3 Window Management
- `<C-w>h/j/k/l` - Move cursor to window in that direction¹⁷
- `<C-w>w` - Move cursor to previous window¹⁷
- `<C-w></+/->` - Resize window in that direction¹⁷
- `<C-w>bh/j/k/l` - Swap buffer with window in that direction¹⁷
- `Ctrl+wT` - Move current split to new tab
- `#gt` - Move to tab number #
- `:tabmove #` - Move current tab to position #
- `:tabdo command` - Run command on all tabs

### 4.4 Advanced Telescope Usage
- `<C-g>` in Telescope - Choose which window to open the selection in⁷
- `<esc>` in insert mode - Close Telescope⁷
- `<leader>fq` - List quickfix items⁷
- `<leader>fj` - Jump list⁷
- `<leader>fr` - Browse registers⁷
- `<leader>fm` - List marks⁷

### 4.5 Mark Management
- Named marks (`ma` through `mz`) for positions within a file
- File marks with capital letters (`mA` through `mZ`) that work across buffers
- `<leader>fm` - List and navigate marks⁷

#### Special Marks
- `` `0 `` - Position where Vim was last exited
- `` `" `` - Position when last editing this file
- `` `. `` - Position of last change in this file
- `` `` `` - Position before last jump

#### Jump & Change Lists
- `:jumps` - List of jumps
- `Ctrl+i`/`Ctrl+o` - Go to newer/older position in jump list
- `:changes` - List of changes
- `g,`/`g;` - Go to newer/older position in change list

## 5. Search & History Navigation

### 5.1 Enhanced Search with Hlslens
- `n`/`N` - Navigate search results with count indicator¹²
- `*`/`#` - Search for word under cursor with enhanced visibility¹²
- `g*`/`g#` - Search for partial word under cursor¹²

### 5.2 Undo History Navigation
- `<leader>u` - Toggle undo tree visualization¹³
- Navigate through complex undo history
- Restore previous states even after multiple changes

### 5.3 Advanced Search Operations
- `:vimgrep /pattern/ **/*` - Search pattern in all files
- `:cn`/`:cp` - Jump to next/previous match in quickfix
- `:copen`/`:cclose` - Open/close quickfix window

## 6. Focus & Zen Modes

### 6.1 Distraction-Free Editing
- `<leader>z` - Toggle Zen Mode for focused editing¹⁴
- Control width and appearance of the editing environment

### 6.2 Enhanced Reading
- Twilight plugin dims inactive portions of code¹⁵
- No-Neck-Pain provides balanced window layouts¹⁶

### 6.3 AI Integration
- `<Tab>` - Accept Copilot suggestion
- Seamless integration with Copilot for intelligent code completions

## 7. Collaboration & Sessions

### 7.1 Collaborative Editing
- `<leader>ciu` - Set up collaboration server²³
- `<leader>ciss` - Stop collaboration server²³
- `<leader>cij*` - Various commands to join collaborative sessions²³
- `<leader>cif` - Follow another collaborator²³

### 7.2 Session Management
- Automatic session saving and loading based on git projects²⁴
- Preserves window layouts, tab pages, and terminal state
- Handles session management across different directories

## 8. Git Integration

### 8.1 Neogit Commands
- `<leader>gs` - Open git status window²⁰
- `<leader>gc` - Commit changes²⁰
- `<leader>gp` - Push changes²⁰
- `<leader>gP` - Pull changes²⁰
- `<leader>gm` - Merge²⁰
- Various other git operations accessible through leader mappings²⁰

### 8.2 Diffview
- `<leader>gd` - Open diff viewer²⁰
- `<leader>gh` - View file history²⁰
- Compare changes with powerful interactive interface

## 9. Indentation & Formatting

### 9.1 Smart Indentation
- `>>` / `<<` - Indent/de-indent line one shiftwidth
- `>%` / `<%` - Indent/de-indent block with cursor on brace
- `>ib` / `<ib` - Indent/de-indent inner block with ()
- `>at` / `<at` - Indent/de-indent block with <> tags
- `3==` - Re-indent 3 lines
- `=%` - Re-indent block with cursor on brace
- `=iB` - Re-indent inner block with {}
- `gg=G` - Re-indent entire buffer
- `]p` - Paste and adjust indent to current line

## 10. Advanced Techniques & Workflows

### 10.1 Registers and Macros
- Named registers (`"a` through `"z`) for storing text
- `<leader>fr` - Browse registers⁷
- Record complex macros with `q{register}` that use leap, text objects and TreeSitter movements
- `:registers` - Show all register contents

#### Special Registers
- `"0p` - Paste last yank (not affected by deletes)
- `"%` - Current file name register
- `"#` - Alternate file name register
- `"*` - Primary clipboard (X11)
- `"+` - System clipboard
- `"/` - Last search pattern
- `":` - Last command-line
- `".` - Last inserted text
- `"-` - Last small delete
- `"=` - Expression register (calculate expressions)
- `"_` - Black hole register (delete without storing)

### 10.2 Command Mode Power Tools
- `:g/pattern/command` - Execute a command on lines matching a pattern
- `:v/pattern/command` - Execute a command on lines NOT matching a pattern
- `:s/pattern/replacement/g` - Substitute text with regex support
- `:norm! command` - Execute normal mode commands on multiple lines
- `\vpattern` - Very magic pattern (no escaping needed for regex)
- `:nohl` - Remove search highlighting

#### Bulk Operations
- `:g/{pattern}/d` - Delete all lines containing pattern
- `:g!/{pattern}/d` - Delete all lines NOT containing pattern
- `:.,$d` - Delete from current line to end of file
- `:.,1d` - Delete from current line to beginning

#### File Operations
- `:saveas file` - Save file with new name
- `:w !sudo tee %` - Write file using sudo
- `K` - Open man page for word under cursor

### 10.3 Composing Complex Commands
- Use count prefix and complex motions together:
- `2d2]f` - Delete two functions forward twice
- `3yaf` - Yank three functions
- `ct}` - Change until the next closing curly brace

---

**Plugin References:**
1. leap.nvim
2. quick-scope
3. Custom remaps
4. cliff.nvim
5. nvim-treesitter-textobjects
6. vim-matchup
7. telescope.nvim
8. mini.ai
9. precognition.nvim
10. mini.move
11. Comment.nvim
12. nvim-hlslens
13. undotree
14. zen-mode.nvim
15. twilight.nvim
16. no-neck-pain.nvim
17. smart-splits.nvim
18. toggleterm.nvim
19. nvim-tree.lua
20. neogit/diffview (git integration)
21. Trouble.nvim
22. Copilot.lua
23. instant.nvim
24. neovim-session-manager
