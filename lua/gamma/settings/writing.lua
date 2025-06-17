local M = {}

M.group = vim.api.nvim_create_augroup("Writing Settings", { clear = true })

if not vim.g.vccode then
    -- Auto save
    vim.api.nvim_create_autocmd({ 'FocusLost' }, {
        command = 'silent! wa'
    })
end

return M
