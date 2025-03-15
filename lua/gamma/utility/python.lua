local utility = require('gamma/utility')

local M = {}

---Setup a python virtual environment
---@param root_dir string @The root directory to create the virtual environment
function M.setup_env(root_dir)
  local venv_dir = root_dir .. "/.venv"


  local python_exe = venv_dir .. "/bin/python"
  if utility.is_windows() then
    python_exe = venv_dir .. "/Scripts/python.exe"
  end

  vim.g.python3_host_prog = python_exe
  vim.g.python_host_prog = python_exe

  local py_exe = "python3"
  if vim.fn.executable(py_exe) == 0 then
    py_exe = "python"
  end


  if vim.fn.isdirectory(venv_dir) == 0 then
    utility.print("Creating a python virtual environment at " .. venv_dir)
    if not pcall(utility.shell, { py_exe, '-m', 'venv', venv_dir }, { silent = false, verbose = true }) then
      utility.print_error("Failed to create virtual environment")
      return
    end
  end

  -- set $VIRTUAL_ENV
  vim.env.VIRTUAL_ENV = venv_dir

  -- Check if pynvim is installed
  local pynvim = utility.shell({ python_exe, '-m', 'pip', 'show', 'pynvim' })
  if pynvim.code ~= 0 then
    local r = utility.shell({ python_exe, '-m', 'pip', 'install', '--upgrade', 'pynvim' })
    if r.code ~= 0 then
      utility.print("pynvim installed")
    else
      error("Failed to install pynvim")
      return
    end
  end
end

---Get the python executable
---@return string @The python executable path
function M.python_exe()
  return vim.g.python3_host_prog
end

---Run a python command
---@param cmd string|string[] @The command to run
---@param opts table @The options to run the command
---@return table @Same as utility.shell
function M.run(cmd, opts)
  local python_exe = M.python_exe()
  local cmds = { python_exe }
  if type(cmd) == "string" then
    table.insert(cmds, cmd)
  else
    vim.list_extend(cmds, cmd)
  end

  return utility.shell(cmds, opts)
end

---Ensure a package is installed
---@param package string|string[] @The package to install
function M.ensure_package(package)
  local pkg = ""
  if type(package) == "table" then
    for _, p in ipairs(package) do
      M.ensure_package(p)
    end
    return
  else
    pkg = package
  end

  local r = M.run({ '-m', 'pip', 'install', '-U', pkg })
  if r.code ~= 0 then
    error("Failed to install " .. pkg)
    return
  end
end

return M
