vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.keymap.set("n", "<leader>pt", vim.cmd.Ex)

-- Makes cursor remain in the same place when joining lines
-- vim.keymap.set("n", "J", "mzJ`z")

-- Keep cursor in the middle when jumping pages
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Keep cursor in the middle when jumping to search terms
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Copy-paste fixes
vim.keymap.set("x", "p", "\"_dP")

vim.keymap.set("n", "y", "\"+y")
vim.keymap.set("v", "y", "\"+y")
vim.keymap.set("n", "Y", "\"+Y")

-- delete into void instead of overwriting previous paste
vim.keymap.set("n", "d", "\"_d")
vim.keymap.set("v", "d", "\"_d")

-- disable Q
vim.keymap.set("n", "Q", "<nop>")

-- format
vim.keymap.set("n", "<leader>f", function()
  vim.lsp.buf.format()
end)

-- remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })












