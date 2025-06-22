local M = {}

---Get the current operating system.
---@return string @The current operating system. (macos, linux, windows)
function M.get_os()
  local os_name = vim.loop.os_uname().sysname
  if os_name:match("Darwin") then
    return "macos"
  elseif os_name:match("Linux") then
    return "linux"
  elseif os_name:match("Windows") then
    return "windows"
  else
    return os_name
  end
end

---True if the current operating system is macOS.
function M.is_macos()
  return M.get_os() == "macos"
end
M.is_mac = M.is_macos -- Alias for is_macos

---True if the current operating system is Linux.
function M.is_linux()
  return M.get_os() == "linux"
end

---True if the current operating system is Windows.
function M.is_windows()
  return M.get_os() == "windows"
end

---Normalize path separators.
---@param path string @The path to normalize.
---@return string @The normalized path.
function M.normalize_path_sep(path)
  local p = string.gsub(path, "\\", "/")
  return p
end

---Create a callable that will run a command.
---@param command string @The command to run.
---@param args? string[] The options to run the command with.
---@return function @The function that will run the command.
---@note This is useful for setting up keymaps that run commands.
---      Instead of remembering "<cmd>Some-command<cr>"
function M.create_cmd(command, args)
  return function()
    if args == nil then
      return vim.cmd(command)
    else
      return vim.cmd { cmd = command, args = args }
    end
  end
end

---Get an environment variable.
---@param name string @The name of the environment variable to get.
---@return string | nil @The value of the environment variable, or nil if it does not exist.
function M.get_env(name)
  local value = os.getenv(name)
  if value == nil then
    return nil
  end
  return value
end

M.env = M.get_env -- Alias for get_env

---Reliably get nvim config path
---@return string @The path to the nvim config directory.
function M.config_path()
  local p = debug.getinfo(1, "S").source:sub(2)
  -- go up directories
  -- backslash to forward slash
  p = p:gsub("\\", "/")
  p = p:gsub("lua/gamma/utility/system.lua", "")
  return p
end

--Get the nvim-data directory
---@return string @The path to the nvim data directory.
function M.data_path()
  local p = vim.fn.stdpath("data"):gsub("\\", "/")
  return p
end

---A better require, that supports recursive require of directories.
---@param path string @The path to require. Can also be a directory.
---@param recursive? boolean Whether or not to require all files in the directory.
---@param allow_empty? boolean Whether or not to allow empty directories.
function M.require_dir(path, recursive, allow_empty)
  allow_empty = allow_empty or false

  if path == nil or path == "" then
    error("require_dir -- Path cannot be nil or empty")
  end
  local dir = M.config_path()

  recursive = recursive or false
  -- check if path starts with ./ or ../ or .\ or ..\

  local rel = {
    dot_slash = string.match(path, "^%./"),
    dot_dot_slash = string.match(path, "^%.%./"),
    dot_back_slash = string.match(path, "^%.\\"),
    dot_dot_back_slash = string.match(path, "^%.%.\\"),
  }

  -- if all of rel are false, check if a lua require path, e.g. mode.path.file and resolve to file instead

  if not rel.dot_back_slash and not rel.dot_dot_back_slash and
      not rel.dot_slash and not rel.dot_dot_slash then
    -- Check if 'path' matches the pattern for a Lua require path
    local require_pattern = "(%.?[%w_]+)+"
    if path:match(require_pattern) then
      path = path:gsub("%.", "/") -- Replace dots with slashes
    end
  end

  -- if dir doesn't start with 'lua/', then add it
  if not string.match(dir, "/lua$") and not string.match(path, "\\lua$") then
    dir = dir .. "/lua"
  end

  if rel.dot_slash then
    path = string.gsub(path, "^%./", "")
    path = dir .. "/" .. path
  elseif rel.dot_dot_slash then
    path = string.gsub(path, "^%.%./", "")
    path = dir .. "/../" .. path
  elseif rel.dot_back_slash then
    path = string.gsub(path, "^%.\\", "")
    path = dir .. "\\" .. path
  elseif rel.dot_dot_back_slash then
    path = string.gsub(path, "^%.%.\\", "")
    path = dir .. "\\..\\" .. path
  else
    path = dir .. "/" .. path
  end

  -- resolve path (with compatibility fallback)
  if vim.fs and vim.fs.abspath then
    path = vim.fs.abspath(path)
  else
    -- Fallback for older Neovim versions
    path = vim.fn.fnamemodify(path, ':p')
  end
  -- Switch backslashes to forward slashes
  path = string.gsub(path, "\\", "/")
  -- Remove trailing slash
  path = path:gsub("//", "/"):gsub("/$", "")
  dir = dir:gsub("\\", "/"):gsub("//", "/")

  local import_path = string.gsub(path, dir, ""):gsub("/$", ""):gsub("^/", ""):gsub("/", ".")

  -- if is directory
  if vim.fn.isdirectory(path) == 1 then
    -- if recursive
    if recursive then
      -- require all files in directory
      local files = vim.fn.readdir(path)
      local req = false
      for _, file in ipairs(files) do
        local file_path = path .. "/" .. file
        if vim.fn.isdirectory(file_path) == 0 and file_path:match("%.lua$") then
          if vim.fn.filereadable(file_path) == 1 then
            local import_file_path = import_path .. "." .. file:gsub("%.lua$", "")
            require(import_file_path)
            req = true
          else
            error("require_dir -- File not readable: " .. file_path)
          end
        elseif vim.fn.isdirectory(file_path) == 1 then
          local next_dir = vim.fs.relpath(dir, file_path)
          if next_dir ~= nil then
            M.require_dir(next_dir, recursive, allow_empty)
          end
        end
      end
      if not req and not allow_empty then
        error("require_dir -- No lua files found in directory: " .. path)
      end
    else
      local init_path = path .. "/init.lua"
      if vim.fn.filereadable(init_path) == 1 then
        require(import_path)
      else
        error("require_dir -- File not readable: " .. init_path)
      end
    end
  else
    -- require file
    if vim.fn.filereadable(path) == 1 then
      require(path:gsub("%.lua$", ""))
    else
      error("require_dir -- File not readable or doesn't exist: " .. path)
    end
  end

  return true
end

return M