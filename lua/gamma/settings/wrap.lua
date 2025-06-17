-- Set custom wrap settings for specific filetypes

local group = vim.api.nvim_create_augroup("Default Wrap Settings", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "*.md", "*.txt", "*.rst", "help" },
    group = group,
    command = 'setlocal wrap'
})
