require('compat')
local utility = require('gamma.utility')

-- Load all remaps
utility.require_dir("gamma/remap/leader", true)

local kmap = utility.kmap

-- Makes cursor remain in the same place when joining lines
-- kmap("n", "J", "mzJ`z")

-- Keep cursor in the middle when jumping to search terms
kmap("n", "n", "nzzzv", {remap = true})
kmap("n", "N", "Nzzzv", {remap = true})

-- Copy-paste fixes (the mc and `c are to preserve cursor position)
kmap("x", "p", "\"_dP", {remap = true})

kmap("n", "y", "mc\"+y`c", {remap = true})
kmap("v", "y", "mc\"+y`c", {remap = true})
kmap("n", "Y", "mc\"+Y`c", {remap = true})

-- Delete into void instead of overwriting previous paste
kmap("n", "d", "\"_d", {remap = true})
kmap("v", "d", "\"_d", {remap = true})

-- X to cut the current line
kmap('n', 'X', 'dd', { noremap = true })

-- disable Q
kmap("n", "Q", "<nop>", { remap = true })

-- format
if not vim.g.vscode then
  kmap("n", "<leader>=", function()
    vim.lsp.buf.format()
  end, "[F]ormat current buffer")
end

-- refresh/reload buffers
kmap("n", "<F5>", function()
  vim.cmd("checktime")
  vim.cmd("edit")
end, "[R]eload current buffer")

-- remap for dealing with word wrap
kmap('n', 'k', "v:count == 0 ? 'gk' : 'k'", { remap = true, expr = true, silent = true })
kmap('n', 'j', "v:count == 0 ? 'gj' : 'j'", { remap = true, expr = true, silent = true })

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

-- U to redo
kmap('n', 'U', '<C-r>', { noremap = true })

-- buffers
kmap("n", "<leader>bb", vim.cmd.buffers, "[B]uffers", { remap = true })
kmap("n", "<leader>bd", vim.cmd.bdelete, "[B]uffer [D]elete", { remap = true })
kmap("n", "<leader>bn", vim.cmd.bnext, "[B]uffer [N]ext", { remap = true })
kmap("n", "<leader>bp", vim.cmd.bprevious, "[B]uffer [P]revious", { remap = true })
kmap("n", "<leader>bl", vim.cmd.blast, "[B]uffer [L]ast", { remap = true })
kmap("n", "<leader>bs", vim.cmd.bstart, "[B]uffer [S]tart", { remap = true })
kmap("n", "<leader>bw", vim.cmd.bwipeout, "[B]uffer [W]ipeout", { remap = true })
