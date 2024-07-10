local ftheme, theme = pcall(require, vim.g.colors_name)

if ftheme then
	vim.api.nvim_set_hl(0, 'MiniIndentscopeSymbol', theme.Conceal)
else
	error("Couldn't require colorscheme '" .. vim.g.colors_name .. "'. Using default active indent hl group.")
end
