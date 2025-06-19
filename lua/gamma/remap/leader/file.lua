local utility = require('gamma.utility')

local kmap = utility.kmap

-- Quick save
kmap('n', '<leader>qw', vim.cmd.write, "Save file")

-- Quick save and quit
kmap('n', '<leader>qqw', function()
  vim.cmd.write()
  vim.cmd.quit()
end, "Save and quit")

-- Quick quit
kmap('n', '<leader>qq', vim.cmd.quit, "Quit")

-- Rename file
kmap("n", "<leader>fe", utility.create_cmd("file"), "Rename file")
