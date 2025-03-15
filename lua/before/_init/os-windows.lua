require('compat')
local utility = require('gamma.utility')

if utility.is_windows() then
    -- Better shell settings for Windows
    if vim.fn.executable('pwsh') == 1 then
        vim.o.shell = 'pwsh'
        vim.o.shellcmdflag =
        '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;'
        vim.o.shellredir = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
        vim.o.shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
        vim.o.shellquote = ''
        vim.o.shellxquote = ''
    end
end
