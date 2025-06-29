local utility = require('gamma.utility')

local kmap = utility.kmap

-- Keep cursor in the middle when jumping to search terms
kmap("n", "n", "nzzzv", "Next search result", { force = true })
kmap("n", "N", "Nzzzv", "Previous search result", { force = true })

--  Keep cursor in the middle when navigating half a page
kmap('n', '<C-d>', '<C-d>zz', "Half page down", { force = true, silent = true, nowait = true })
kmap('n', '<C-u>', '<C-u>zz', "Half page up", { force = true, silent = true, nowait = true })

-- provide hjkl movements in Insert mode and Command-line mode via the <Alt> modifier key
kmap('i', '<A-h>', '<Left>', "Move cursor left", { force = false, silent = true })
kmap('i', '<A-j>', '<Down>', "Move cursor down", { force = false, silent = true })
kmap('i', '<A-k>', '<Up>', "Move cursor up", { force = false, silent = true })
kmap('i', '<A-l>', '<Right>', "Move cursor right", { force = false, silent = true })

-- word motion in insert mode
kmap('i', '<A-b>', '<C-o>b', "Move to beginning of word", { force = true, silent = true })
kmap('i', '<A-w>', '<C-o>w', "Move to next word", { force = true, silent = true })
kmap('i', '<A-e>', '<C-o>e', "Move to end of word", { force = true, silent = true })

-- H and L to move to the beginning and end of the line
kmap('n', 'H', '^', "Move to beginning of line", { force = true, silent = true })
kmap('v', 'H', '^', "Move to beginning of line", { force = true, silent = true })
kmap('n', 'L', '$', "Move to end of line", { force = true, silent = true })
kmap('v', 'L', '$', "Move to end of line", { force = true, silent = true })

-- Navigate quickfix list
kmap('n', ']q', ':cnext<CR>', "Next quickfix item", { force = true, silent = true })
kmap('n', '[q', ':cprev<CR>', "Previous quickfix item", { force = true, silent = true })
