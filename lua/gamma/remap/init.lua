require('compat')
local utility = require('gamma.utility')

local kmap = utility.kmap

-- Remap caps-lock to escape
kmap({ 'i', 'n' }, '<Caps>', '<Esc>', { remap = true })

-- disable Q
kmap("n", "Q", "<nop>", { remap = true })

-- refresh/reload buffers
kmap("n", "<F5>", function()
  vim.cmd("checktime")
  vim.cmd("edit")
end, "[R]eload current buffer")

-- remap for dealing with word wrap
-- kmap('n', 'k', "v:count == 0 ? 'gk' : 'k'", { remap = true, expr = true, silent = true })
-- kmap('n', 'j', "v:count == 0 ? 'gj' : 'j'", { remap = true, expr = true, silent = true })

-- U to redo
kmap('n', 'U', '<C-r>', { noremap = true })
