require('compat')
local utility = require('gamma.utility')

if utility.is_windows() then
	if vim.g.neovide then
		-- Register a right click context menu item to edit a given file with Neovide
		vim.cmd("NeovideRegisterRightClick") -- NeovideUnregisterRightClick
	end
end
