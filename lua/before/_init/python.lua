utility = require('gamma/utility')

local M = {}

---Setup a python virtual environment
function M.setup_env()
    if not vim.g.python3_host_prog or vim.g.python3_host_prog then
        local config_dir = utility.config_path()
        local venv_dir = config_dir .. "/venv"

        
        local python_exe = venv_dir .. "/bin/python"
        if utility.is_windows() then
            python_exe = venv_dir .. "/Scripts/python.exe"
        end

        vim.g.python3_host_prog = python_exe
        vim.g.python_host_prog = python_exe

        if vim.fn.isdirectory(venv_dir) == 0 then
            if not pcall(utility.shell, {'python3', '-m', 'venv', venv_dir}, {silent = false}) then
                if vim.fn.isdirectory(venv_dir) == 0 then
                    pcall(utility.shell, {'python', '-m', 'venv', venv_dir}, {silent = false})
                end
            end
        end

        if vim.fn.isdirectory(venv_dir) == 0 then
            error("Failed to create virtual environment")
            return
        end

        
        -- Check if pynvim is installed
        local pynvim = utility.shell({python_exe, '-m', 'pip', 'show', 'pynvim'})
        if pynvim.code ~= 0 then
            local r = utility.shell({python_exe, '-m', 'pip', 'install', '--upgrade', 'pynvim'})
            if r.code ~= 0 then
                utility.print("pynvim installed")
            else
                error("Failed to install pynvim")
                return
            end
        end
    end
end

M.setup_env()

return M