local plugin = require('gamma.utility.plugin')
function ColorMyPencils(color)
	vim.cmd.colorscheme(color)
	-- vim.g.material_style = "deep ocean"

	-- other plugins use this variable to determine colorscheme
	vim.g.colors_name = color
end

if vim.g.vscode then
	return
else
	local function setup_highlights()
		if vim.g.colors_name then
			local loaded = plugin.is_plugin_loaded(vim.g.colors_name)

			if not loaded then -- if colorscheme hasn't loaded yet
				-- Fallback to linking with Comment highlight group
				vim.api.nvim_set_hl(0, 'MiniIndentscopeSymbol', { link = 'Comment' })
				return
			end

			local ftheme, theme = pcall(require, vim.g.colors_name)
			if vim.g.colors_name == 'gruvbox-material' then
				vim.api.nvim_set_hl(0, 'MiniIndentscopeSymbol', { link = 'AquaBold' })
			elseif ftheme and theme.Conceal then
				vim.api.nvim_set_hl(0, 'MiniIndentscopeSymbol', theme.Conceal)
			end
		end
		vim.api.nvim_set_hl(0, "LeapMatch", { link = "CharacterHint" })
		vim.api.nvim_set_hl(0, "LeapLabel", { link = "CharacterHintSecondary" })
		--
		vim.api.nvim_set_hl(0, "QuickScopePrimary", { link = "CharacterHintLabel" })
		vim.api.nvim_set_hl(0, "QuickScopeSecondary", { link = "CharacterHintSecondary" })
	end

	-- Set up autocommand to run after colorscheme loads
	vim.api.nvim_create_autocmd('ColorScheme', {
		callback = setup_highlights,
		desc = 'Set up highlighting after colorscheme loads'
	})

	-- Also run immediately in case colorscheme is already loaded
	setup_highlights()
end


if vim.g.colors_name then
	local ok, err = pcall(ColorMyPencils, vim.g.colors_name)
	if not ok then
		vim.notify("Couldn't load colorscheme '" .. vim.g.colors_name .. "': " .. err, vim.log.levels.WARN)
		-- Fallback to default colorscheme
		pcall(vim.cmd.colorscheme, "default")
	end
else
	vim.notify("No colorscheme set, using default", vim.log.levels.WARN)
	pcall(vim.cmd.colorscheme, "default")
end
