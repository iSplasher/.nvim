local group = vim.api.nvim_create_augroup("Writing Settings", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
    pattern = { "*.md" },
    group = group,
    command = 'Pencil'
})

-- Auto save
vim.api.nvim_create_autocmd({ 'FocusLost' }, {
    command = 'silent! wa'
})
