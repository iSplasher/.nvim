local utility = require('gamma.utility')

local kmap = utility.kmap

-- Quick save and quit
kmap('n', '<leader>qw', function()
  vim.cmd.write()
  vim.cmd.quit()
end, "Save file & quit")

-- Force quit
kmap('n', { '<leader>!q', '<leader>q!' }, function()
  vim.cmd.quit({ bang = true })
end, "Force quit")

-- Quick quit
kmap('n', '<leader>qq', vim.cmd.quit, "Quit/Close")

-- Rename file
kmap("n", "<leader>fr", utility.create_cmd("file"), "[R]ename file")
