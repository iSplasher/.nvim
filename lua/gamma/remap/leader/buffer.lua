local utility = require('gamma.utility')

local kmap = utility.kmap


-- buffers
kmap("n", "<leader>bq", utility.create_cmd("bdelete"), "Delete current [b]uffer ", {})
kmap("n", "<leader>bn", utility.create_cmd("bnext"), "Switch to [n]ext [b]uffer", {})
kmap("n", "<leader>bp", utility.create_cmd("bprevious"), "Switch to [p]revious [b]uffer", {})
kmap("n", "<leader>b!", utility.create_cmd("bwipeout"), "[B]uffer [W]ipeout", {})

-- format
kmap("n", "<leader>=", function()
    vim.lsp.buf.format()
end, "[F]ormat current buffer")
