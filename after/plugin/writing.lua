local writing = require('gamma.settings.writing')


if package.loaded.pencil then
	-- Auto enable Panciĺ plugin for certain filetypes
	vim.api.nvim_create_autocmd("BufEnter", {
		pattern = { "*.md" },
		group = writing.group,
		command = 'Pencil'
	})
end
