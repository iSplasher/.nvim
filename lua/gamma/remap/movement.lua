local utility = require('gamma.utility')

local kmap = utility.kmap

-- Keep cursor in the middle when jumping to search terms
kmap("n", "n", "nzzzv", "Next search result", { remap = true })
kmap("n", "N", "Nzzzv", "Previous search result", { remap = true })

--  Keep cursor in the middle when navigating half a page
kmap('n', '<C-d>', '<C-d>zz', "Half page down")
kmap('n', '<C-u>', '<C-u>zz', "Half page up")

-- provide hjkl movements in Insert mode and Command-line mode via the <Alt> modifier key
kmap('i', '<A-h>', '<Left>', { noremap = true })
kmap('i', '<A-j>', '<Down>', { noremap = true })
kmap('i', '<A-k>', '<Up>', { noremap = true })
kmap('i', '<A-l>', '<Right>', { noremap = true })

-- word motion in insert mode
kmap('i', '<A-b>', '<C-o>b', { noremap = true })
kmap('i', '<A-w>', '<C-o>w', { noremap = true })
kmap('i', '<A-e>', '<C-o>e', { noremap = true })

-- H and L to move to the beginning and end of the line
kmap('n', 'H', '^', { noremap = true })
kmap('v', 'H', '^', { noremap = true })
kmap('n', 'L', '$', { noremap = true })
kmap('v', 'L', '$', { noremap = true })

-- Navigate quickfix list
kmap('n', ']q', ':cnext<CR>', "Next quickfix item", { remap = true, silent = true })
kmap('n', '[q', ':cprev<CR>', "Previous quickfix item", { remap = true, silent = true })
