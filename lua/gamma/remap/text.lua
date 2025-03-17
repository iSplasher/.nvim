local utility = require('gamma.utility')

local kmap = utility.kmap


-- Makes cursor remain in the same place when joining lines
kmap("n", "J", "mzJ`z")


-- Copy-paste fixes (the mc and `c are to preserve cursor position)
kmap("x", "p", "\"_dP", { remap = true })

-- kmap("n", "y", "mc\"+y`c", { remap = true })
-- kmap("v", "y", "mc\"+y`c", { remap = true })
kmap("n", "Y", "mc\"+Y`c", { remap = true })

-- Delete into void instead of overwriting previous paste
kmap("n", "d", "\"_d", { remap = true })
kmap("v", "d", "\"_d", { remap = true })

-- X to cut the current line
kmap('n', 'X', 'dd', { remap = true })
