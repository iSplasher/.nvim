Certainly! Here’s a comprehensive document listing **all keymaps**: your custom keymappings, keymappings from installed plugins, and default Neovim keybindings to help you efficiently navigate and operate text.

### Neovim Keymap Reference Guide

#### Table of Contents
1. **Default Neovim Keymaps**
    - Navigation and Editing
    - Modes and Operations
2. **Plugin-Specific Keymaps**
    - Telescope
    - Nvim-Tree
    - Leap, Cliff, and Movement Plugins
3. **Custom Keymaps**
    - General Editing and Navigation
    - Leader Keymaps
    - Insert Mode Key Enhancements
    - Buffer Management

---

### 1. Default Neovim Keymaps

##### a. Navigation and Editing
- **Basic Navigation**:
  - `h`, `j`, `k`, `l`: Move left, down, up, and right.
  - `^`: Move to the beginning of the line.
  - `$`: Move to the end of the line.
  - `w`, `W`: Move to the next word (based on punctuation or full words).
  - `b`, `B`: Move to the beginning of the previous word.
  - `e`, `E`: Move to the end of the word.
  - `gg`: Jump to the beginning of the file.
  - `G`: Jump to the end of the file.

- **Window Management**:
  - `<C-w> s`: Split window horizontally.
  - `<C-w> v`: Split window vertically.
  - `<C-w> w`: Cycle through windows.
  - `<C-w> q`: Close the current window.

- **Buffer Management**:
  - `:bnext` (`:bn`): Go to the next buffer.
  - `:bprevious` (`:bp`): Go to the previous buffer.
  - `:bdelete` (`:bd`): Close the buffer.

- **Search**:
  - `/pattern`: Search for `pattern`.
  - `n`, `N`: Jump to the next/previous occurrence.

- **Text Operations**:
  - `y`: Yank (copy) selected text.
  - `d`: Delete selected text.
  - `c`: Change (delete + enter insert mode).
  - `p`: Paste after the cursor.
  - `P`: Paste before the cursor.
  - `u`: Undo.
  - `<C-r>`: Redo.

##### b. Modes and Operations
- **Insert Mode**:
  - `i`: Insert at cursor.
  - `I`: Insert at the beginning of the line.
  - `a`: Append after the cursor.
  - `A`: Append at the end of the line.
  - `o`: Open a new line below.
  - `O`: Open a new line above.

- **Visual Mode**:
  - `v`: Enter visual mode.
  - `V`: Enter line-wise visual mode.
  - `<C-v>`: Enter block-wise visual mode.

- **Command Mode**:
  - `:`: Enter command-line mode for commands like saving, quitting, etc.

---

### 2. Plugin-Specific Keymaps

##### a. Telescope
- **File Search**:
  - `<leader>pf`: Open file search.
  - `<leader>gf`: Search files in a Git repository.
  - `<leader>/`: Fuzzy search within the current buffer.

- **Grep Search**:
  - `<leader>ps` or `<leader>sg`: Grep across files.

- **Buffer Management**:
  - `<leader>bf` or `<leader>fb`: List and search for open buffers.

##### b. Nvim-Tree
- **File Tree Operations**:
  - `%`: Create a new file.
  - `D`: Delete a selected file or folder.
  - `?`: Toggle help documentation in Nvim-Tree.
  - `<leader>pt`: Toggle the project tree with the current directory.

##### c. Leap, Cliff, and Movement Plugins
- **Leap Plugin (Directional Movement)**:
  - `s`: Leap forward in a window.
  - `S`: Leap backward.
  - `gs`: Leap to other windows.

- **Cliff Plugin**:
  - `<C-j>`: Move cursor down.
  - `<C-k>`: Move cursor up.

- **Quick Scope** (for fast visual hints):
  - Highlights keys like `f`, `F`, `t`, `T` to jump quickly.

---

### 3. Custom Keymaps

##### a. General Editing and Navigation
- **Cursor Control**:
  - `n`, `N`: Keep the cursor centered when jumping to the next or previous search term.
  - `H`, `L`: Move to the beginning (`H`) or end (`L`) of a line in normal and visual modes.
  
- **Join Lines**:
  - `J`: Join lines without moving the cursor (`mzJ\`z`).

- **Clipboard & Delete Enhancements**:
  - `y`, `Y`: Yank (copy) to the system clipboard, keeping the cursor in place.
  - `d`: Delete into the void register to prevent overwriting the current clipboard.

- **Miscellaneous**:
  - `Q`: Disabled to prevent accidental use.
  - `X`: Cuts the current line (`dd`).

- **Reload Buffers**:
  - `<F5>`: Refresh the current buffer.

##### b. Leader Keymaps
- **General Commands**:
  - `<leader>h`: Open the Dashboard.
  - `<leader>er`: Rename the current file.
  - `<leader>l`: Lazy Plugin Manager.
  - `<leader>=`: Format the current buffer using LSP.

- **Buffer Operations**:
  - `<leader>bb`: List all buffers.
  - `<leader>bd`: Delete the current buffer.
  - `<leader>bn`: Move to the next buffer.
  - `<leader>bp`: Move to the previous buffer.
  - `<leader>bl`: Move to the last buffer.
  - `<leader>bs`: Move to the first buffer.
  - `<leader>bw`: Wipe out the current buffer.

- **Temporary Files**:
  - `<leader>nt`: Create a new temporary file.
  - `<leader>ni`: Create a new temporary file with an input extension.
  - `<leader>ft`: Use Telescope to find temporary files.

##### c. Insert Mode Key Enhancements
- **Arrow Key Navigation**:
  - `<A-h>`: Move left.
  - `<A-j>`: Move down.
  - `<A-k>`: Move up.
  - `<A-l>`: Move right.

- **Word Movement**:
  - `<A-b>`: Move back one word.
  - `<A-w>`: Move to the beginning of the next word.
  - `<A-e>`: Move to the end of the current word.

##### d. Buffer Management Enhancements
- **Buffers and Navigation**:
  - `<leader>bb`: Show buffer list.
  - `<leader>bd`: Delete current buffer.
  - `<leader>bn`, `<leader>bp`: Move between buffers.
  - `<leader>bl`, `<leader>bs`, `<leader>bw`: Move to last, first, or wipe out the buffer.

---

### Summary of Keymap Benefits
- **Default Keymaps** provide the foundation for efficient text navigation, editing, and window/buffer management.
- **Plugin Keymaps** enhance capabilities with powerful features like fuzzy finding (Telescope), directional movement (Leap), and file exploration (`nvim-tree`).
- **Custom Keymaps** are tailored to boost workflow efficiency, making operations like buffer switching, file management, and formatting much more convenient.

This comprehensive keymap guide is designed to help you get the most out of your Neovim configuration, whether you're editing text, managing buffers, or navigating code with advanced plugins.