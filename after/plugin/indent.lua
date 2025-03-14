local ftheme, theme = pcall(require, vim.g.colors_name)
local utility = require('gamma.utility')

if not vim.g.vscode then
	if ftheme then
		vim.api.nvim_set_hl(0, 'MiniIndentscopeSymbol', theme.Conceal)
	else
		utility.print("Couldn't require colorscheme '" .. vim.g.colors_name .. "'. Using default active indent hl group.")
	end
end
