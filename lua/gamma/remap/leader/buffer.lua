local utility = require('gamma.utility')

local kmap = utility.kmap


-- buffers
kmap("n", "<leader>bb", vim.cmd.buffers, "[B]uffers", {})
kmap("n", "<leader>bd", vim.cmd.bdelete, "[B]uffer [D]elete", {})
kmap("n", "<leader>bn", vim.cmd.bnext, "[B]uffer [N]ext", {})
kmap("n", "<leader>bp", vim.cmd.bprevious, "[B]uffer [P]revious", {})
kmap("n", "<leader>b!", vim.cmd.bwipeout, "[B]uffer [W]ipeout", {})
