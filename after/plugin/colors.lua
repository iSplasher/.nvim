function ColorMyPencils(color)
	color = color or 'gruvy'
	vim.cmd.colorscheme(color)
	vim.g.material_style = "deep ocean"

	-- Transparent background
	-- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

end

ColorMyPencils()
