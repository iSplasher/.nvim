local utility = require('gamma.utility')

local kmap = utility.kmap


-- Makes cursor remain in the same place when joining lines
kmap("n", "J", "mzJ`z", "Join lines (keep cursor position)", { remap = true })

-- Copy-paste fixes (the mc and `c are to preserve cursor position)
kmap("x", "p", "\"_dP", "Paste without overwriting register", { remap = true })

-- kmap({"n", "v"}, "y", "mc\"+y`c", { remap = true })
kmap("n", "Y", "mc\"+Y`c", "Yank line to system clipboard", { remap = true })

-- Delete into void instead of overwriting previous paste
kmap({ "n", "v" }, "d", "\"_d", "Delete to void register", { remap = true })

-- X to cut the current line
kmap('n', 'X', 'dd', "Cut current line", { remap = true })

-- Copy with Ctrl+C
kmap({ "n", "v" }, "<C-c>", "\"+y", "Copy to system clipboard", { remap = true })

-- Paste in command mode using Ctrl+V
kmap('c', '<C-v>', '<C-r>+', "Paste from system clipboard in command mode", { remap = true })
-- Remove the Windows ^M - when the encodings get messed up
-- kmap("n", "<leader>m", "mmHmt:%s/<C-V<cr>//ge<cr>'tzt'm", "Remove Windows ^M")
