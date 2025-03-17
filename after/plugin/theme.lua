function ColorMyPencils(color)
	vim.cmd.colorscheme(color)
	-- vim.g.material_style = "deep ocean"

	-- other plugins use this variable to determine colorscheme
	vim.g.colors_name = color
end

if vim.g.vscode then
	return
else
	local function set_highlights()
		vim.api.nvim_set_hl(0, "LeapMatch", { link = "CharacterHint" })
		vim.api.nvim_set_hl(0, "LeapLabelPrimary", { link = "CharacterHintSecondary" })
		vim.api.nvim_set_hl(0, "LeapLabelSecondary", { link = "CharacterHintDimmed" })
	end

	set_highlights()
end


if not vim.g.colors_name then
	error("No colorscheme set (vim.g.colors_name is empty).")
end
ColorMyPencils(vim.g.colors_name)
