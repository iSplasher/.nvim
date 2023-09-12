## General

**Leader key**: ` ` (space)

### Opening files

- `:e <path>`: Open a file at `<path>`.
- `pt`: Open tree view of pwd
- `pf`: Open file finder

### Saving and exiting

- `:w`: Save the current file.
- `:wq`: Save the current file and exit.
- `:q!`: Discard changes and exit.
- `:qa!`: Discard changes and exit all open windows.

### Movement

- `h`, `j`, `k`, `l`: Move the cursor left, down, up, or right, respectively.
- `w`, `b`: Move the cursor forward or backward one word, respectively.
- `0`, `$`: Move the cursor to the beginning or end of the current line, respectively.
- `gg`, `G`: Move the cursor to the beginning or end of the file, respectively.
- `H`, `M`, `L`: Move the cursor to the top, middle, or bottom of the screen, respectively.
- `f` + char: Move the cursor to the next occurrence of the character `char` on the current line.
- `F` + char: Move the cursor to the previous occurrence of the character `char` on the current line.
- `t` + char: Move the cursor to just before the next occurrence of the character `char` on the current line.
- `T` + char: Move the cursor to just after the previous occurrence of the character `char` on the current line.
- `;`: Repeat the last `f`, `F`, `t`, or `T` command.
- `,`: Repeat the last `f`, `F`, `t`, or `T` command in the opposite direction.
- `%`: Jump to the matching bracket or parenthesis.

### Editing

- `i`: Enter insert mode at the current cursor position.
- `a`: Enter insert mode after the current cursor position.
- `A`: Enter insert mode at the end of the current line.
- `o`: Begin a new line below the current line and enter insert mode.
- `O`: Begin a new line above the current line and enter insert mode.
- `r`: Replace the character under the cursor with the next character typed.
- `x`: Cut the character under the cursor.
- `X`: Cut the current line.
- `dd`: Delete the current line.
- `yy`: Copy the current line.
- `p`: Paste the last deleted or copied text.
- `u`: Undo the last change.
- `Ctrl + r`: Redo the last change.
- `.`: Repeat the last change.
- `~`: Toggle the case of the character under the cursor.
- `gU` + motion: Uppercase the selected text.
- `gu` + motion: Lowercase the selected text.
- `>`: Indent the selected text one level to the right.
- `<`: Indent the selected text one level to the left.
- `=`: Auto-indent the selected text.
- `Ctrl + v`: Enter visual block mode to select rectangular blocks of text.
- `I`: Enter insert mode at the beginning of each line in the selection.
- `A`: Enter insert mode at the end of each line in the selection.
- `r`: Replace the selected block with a single character.
- `d`: Delete the selected block.
- `y`: Yank (copy) the selected block.
- `!`: Run the selected block as a shell command.

### Searching

- `/`: Begin a search for the next occurrence of a pattern.
- `n`: Move to the next occurrence of the pattern found with `/`.
- `N`: Move to the previous occurrence of the pattern found with `/`. p

### Visual mode

- `v`: Enter visual mode to select characters.
- `V`: Enter visual line mode to select entire lines.
- `Ctrl + v`: Enter visual block mode to select rectangular blocks of text.
- `o`: Toggle the selection between the start and end of the visual block.
- `gv`: Reselect the last visual block.
- `I`: Enter insert mode at the beginning of the selected text.
- `A`: Enter insert mode at the end of the selected text.
- `r`: Replace the selected text with a single character.
- `d`: Delete the selected text.
- `y`: Yank (copy) the selected text.
- `gU`: Convert the selected text to uppercase.
- `gu`: Convert the selected text to lowercase.
- `=`: Auto-indent the selected text.
- `>`: Indent the selected text one level to the right.
- `<`: Indent the selected text one level to the left.
- `!`: Run the selected text as a shell command.
- `~`: Toggle the case of the selected text.
- `J`: Join the selected lines.
- `s`: Substitute the selected text with new text.
- `Ctrl + a`: Increment the number under the cursor.
- `Ctrl + x`: Decrement the number under the cursor.
- `Ctrl + y`: Scroll the view up.
- `Ctrl + e`: Scroll the view down.
- `:s/old/new/g`: Substitute all occurrences of `old` with `new`.

### Indentation

- `>>`: Indent the current line one level to the right.
- `<<`: Indent the current line one level to the left.
- `==`: Auto-indent the current line.

### Windows `Ctrl + w`

- `Ctrl + w + q`: Quit the current window.`
- `Ctrl + w + s`: Split the current window horizontally.
- `Ctrl + w + v`: Split the current window vertically.
- `Ctrl + w + h`: Move the cursor to the window on the left.
- `Ctrl + w + j`: Move the cursor to the window below.
- `Ctrl + w + k`: Move the cursor to the window above.
- `Ctrl + w + l`: Move the cursor to the window on the right.


### Buffers

- `:ls`: List all open buffers.
- `:bnext`: Move to the next buffer.
- `:bprevious`: Move to the previous buffer.
- `:bdelete`: Delete the current buffer.

### Macros

- `q` + letter: Start recording a macro to register "letter".
- `q`: Stop recording the macro.
- `@` + letter: Replay the macro stored in register "letter".

### Visual block mode

- `Ctrl + v`: Enter visual block mode to select rectangular blocks of text.
- `I`: Enter insert mode at the beginning of each line in the selection.
- `A`: Enter insert mode at the end of each line in the selection.
- `r`: Replace the selected block with a single character.
- `d`: Delete the selected block.
- `y`: Yank (copy) the selected block.
- `!`: Run the selected block as a shell command.

### Multiple cursors

- `Ctrl + v`: Enter visual block mode.
- Select the text you want to edit with multiple cursors.
- `Ctrl + g`: Toggle the current selection.
- Use `j` or `k` to move to the next or previous selection.
- Edit the text as needed.

### Folding

- `za`: Toggle the fold under the cursor.
- `zc`: Close the fold under the cursor.
- `zo`: Open the fold under the cursor.
- `zR`: Open all folds.
- `zM`: Close all folds.

### Registers

- `"letter`: Prefix a command with a register letter to use that register. For example, `"ayy` copies the current line to register a.
- `:reg`: Display the contents of all registers.

### Marks

- `m` + letter: Set a mark at the current cursor position.
- `'` + letter: Jump to the line containing the mark.
- ```` + letter: Jump to the exact cursor position of the mark.

## Plugins

### vim-commentary -- Comment stuff out
- `gcc`: Comment out the current line.
- `gc`: Comment out the target of a motion command.

### vim-surround -- All about surroundings

- `cs` + old_char + new_char: Replace the surrounding character `old_char` with `new_char`.
- `ds` + old_char: Delete the surrounding character `old_char`.
- `ys` + motion + new_char: Add `new_char` as the new surrounding character around the selected text.
- `yS` + old_char + new_char: Same as `ys` but the surrounding character is a newline.

### session-manager

- `:SessionManager load_session`: Load a session from a list.
- `:SessionManager delete_session`: Delete a session from a list.


