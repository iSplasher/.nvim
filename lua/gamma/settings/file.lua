local M = {}

M.group = vim.api.nvim_create_augroup("File Settings", { clear = false })

if not vim.g.vscode then
    -- Auto save
    vim.api.nvim_create_autocmd('FocusLost', {
        command = 'silent! wa',
        desc = "Auto save files when focus is lost",
    })
   
end

return M
