local utility = require('gamma.utility')

local kmap = utility.kmap


-- Makes cursor remain in the same place when joining lines
kmap("n", "J", "mzJ`z", "Join lines (keep cursor position)", { force = true })

-- Copy-paste fixes (the mc and `c are to preserve cursor position)
kmap("x", "p", "\"_dP", "Paste without overwriting register", { force = true })

-- kmap({"n", "v"}, "y", "mc\"+y`c", { force = true })
kmap("n", "Y", "mc\"+Y`c", "Yank line to system clipboard", { force = true, silent = true })

-- Delete into void instead of overwriting previous paste
kmap({ "n", "v" }, "d", "\"_d", "Delete to void register", { force = true })

-- x to yank character to numbered register then delete
kmap('n', 'x', 'yl"_dl', "Yank character to numbered register then delete", { force = true })

-- X to yank line to numbered register then delete
kmap('n', 'X', 'yy"_dd', "Yank line to numbered register then delete", { force = true })

-- Copy with Ctrl+C
kmap({ "n", "v" }, "<C-c>", "\"+y", "Copy to system clipboard", { force = true, silent = true })

-- Paste in command mode using Ctrl+V
kmap('c', '<C-v>', '<C-r>+', "Paste from system clipboard in command mode", { force = true, silent = true })
-- Remove the Windows ^M - when the encodings get messed up
-- kmap("n", "<leader>m", "mmHmt:%s/<C-V<cr>//ge<cr>'tzt'm", "Remove Windows ^M")
