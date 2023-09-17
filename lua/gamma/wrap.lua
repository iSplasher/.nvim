-- Set custom wrap settings for specific filetypes

local group = vim.api.nvim_create_augroup("Wrap Settings", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
    pattern = { "*.md" },
    group = group,
    command = 'setlocal wrap'
})

-- Disable wrap for all other filetypes
vim.api.nvim_create_autocmd("BufLeave", {
    pattern = "*",
    group = group,
    command = 'setlocal nowrap'
})
