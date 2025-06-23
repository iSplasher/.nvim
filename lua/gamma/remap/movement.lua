local utility = require('gamma.utility')

local kmap = utility.kmap

-- Keep cursor in the middle when jumping to search terms
kmap("n", "n", "nzzzv", "Next search result", { remap = true })
kmap("n", "N", "Nzzzv", "Previous search result", { remap = true })

--  Keep cursor in the middle when navigating half a page
kmap('n', '<C-d>', '<C-d>zz', "Half page down", { remap = true })
kmap('n', '<C-u>', '<C-u>zz', "Half page up", { remap = true })

-- provide hjkl movements in Insert mode and Command-line mode via the <Alt> modifier key
kmap('i', '<A-h>', '<Left>', "Move cursor left", { noremap = true })
kmap('i', '<A-j>', '<Down>', "Move cursor down", { noremap = true })
kmap('i', '<A-k>', '<Up>', "Move cursor up", { noremap = true })
kmap('i', '<A-l>', '<Right>', "Move cursor right", { noremap = true })

-- word motion in insert mode
kmap('i', '<A-b>', '<C-o>b', "Move to beginning of word", { remap = true, silent = true })
kmap('i', '<A-w>', '<C-o>w', "Move to next word", { remap = true, silent = true })
kmap('i', '<A-e>', '<C-o>e', "Move to end of word", { remap = true, silent = true })

-- H and L to move to the beginning and end of the line
kmap('n', 'H', '^', "Move to beginning of line", { remap = true, silent = true })
kmap('v', 'H', '^', "Move to beginning of line", { remap = true, silent = true })
kmap('n', 'L', '$', "Move to end of line", { remap = true, silent = true })
kmap('v', 'L', '$', "Move to end of line", { remap = true, silent = true })

-- Navigate quickfix list
kmap('n', ']q', ':cnext<CR>', "Next quickfix item", { remap = true, silent = true })
kmap('n', '[q', ':cprev<CR>', "Previous quickfix item", { remap = true, silent = true })
