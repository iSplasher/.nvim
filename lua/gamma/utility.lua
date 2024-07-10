require('compat')

local M = {}

---A helper function to print a table's contents.
---@param tbl table @The table to print.
---@param depth number @The depth of sub-tables to traverse through and print.
---@param n number @Do NOT manually set this. This controls formatting through recursion.
function M.print_table(tbl, depth, n)
  n = n or 0;
  depth = depth or 5;

  if (depth == 0) then
    print(string.rep(' ', n) .. "...");
    return;
  end

  if (n == 0) then
    print(" ");
  end

  for key, value in pairs(tbl) do
    if (key and type(key) == "number" or type(key) == "string") then
      key = string.format("[\"%s\"]", key);

      if (type(value) == "table") then
        if (next(value)) then
          print(string.rep(' ', n) .. key .. " = {");
          M.print_table(value, depth - 1, n + 4);
          print(string.rep(' ', n) .. "},");
        else
          print(string.rep(' ', n) .. key .. " = {},");
        end
      else
        if (type(value) == "string") then
          value = string.format("\"%s\"", value);
        else
          value = tostring(value);
        end

        print(string.rep(' ', n) .. key .. " = " .. value .. ",");
      end
    end
  end

  if (n == 0) then
    print(" ");
  end
end

---A helper function to merge two tables.
---@param a table @The first table to merge.
---@param b table @The second table to merge. (overwrites)
---@return table @The merged table.
function M.merge_table(a, b)
  if type(a) == 'table' and type(b) == 'table' then
    for k, v in pairs(b) do
      if type(v) == 'table' and type(a[k] or false) == 'table' then
        M.merge_table(a[k], v)
      else
        a[k] =
            v
      end
    end
  end
  return a
end

---Set a keymap.
---@param mode string @The mode to set the keymap for.
---@param keys string @The keys to set the keymap for.
---@param func string | function @The function to set the keymap for.
---@param desc string | nil @The description to set the keymap for.
---@param opts table | nil @The options to set the keymap for.
function M.kmap(mode, keys, func, desc, opts)
  opts = opts or {}
  if desc then
    desc = '' .. desc
  end

  if opts.noremap == nil and opts.remap == nil then
    opts.remap = true
  end

  vim.keymap.set(mode, keys, func, { desc = desc, table.unpack(opts) })
end

---Get the current operating system.
---@return string @The current operating system. (macos, linux, windows)
function M.get_os()
  local os_name = vim.loop.os_uname().sysname
  if os_name == "Darwin" then
    return "macos"
  elseif os_name == "Linux" then
    return "linux"
  elseif os_name == "Windows" then
    return "windows"
  else
    return os_name
  end
end

---Create a callable that will run a command.
---@param command string @The command to run.
---@param opts table | nil @The options to run the command with.
---@return function @The function that will run the command.
---@note This is useful for setting up keymaps that run commands.
---      Instead of remembering "<cmd>Some-command<cr>"
function M.cmd(command, opts)
  return function()
    if opts == nil then
      return vim.cmd(command)
    else
      return vim.cmd { cmd = command, args = opts }
    end
  end
end

---Check if a plugin is loaded.
---@param plugin_name string @The name of the plugin to check.
---@return boolean @Whether or not the plugin is loaded.
function M.is_plugin_loaded(plugin_name)
  return package.loaded[plugin_name] ~= nil
end

---Reliably get nvim config path
---@return string @The path to the nvim config directory.
function M.config_path()
  local p = debug.getinfo(1, "S").source:sub(2)
  -- go up directories
  p = p:gsub("lua/gamma/utility.lua", "")
  p = p:gsub("lua\\gamma\\utility.lua", "")
  return p
end

---A better require, that supports recursive require of directories.
---@param path string @The path to require. Can also be a directory.
---@param recursive boolean | nil @Whether or not to require all files in the directory.
function M.require_dir(path, recursive)
  recursive = recursive or false
  -- check if path starts with ./ or ../ or .\ or ..\

  local rel = {
    dot_slash = string.match(path, "^%./"),
    dot_dot_slash = string.match(path, "^%.%./"),
    dot_back_slash = string.match(path, "^%.\\"),
    dot_dot_back_slash = string.match(path, "^%.%.\\"),
  }


  local dir = M.config_path()

  M.print("dir:" .. dir)

  -- if all of rel are false, check if a lua require path, e.g. mode.path.file and resolve to file instead

  if not rel.dot_back_slash and not rel.dot_dot_back_slash and
      not rel.dot_slash and not rel.dot_dot_slash then
    -- Check if 'path' matches the pattern for a Lua require path
    local require_pattern = "(%.?[%w_]+)+"
    if path:match(require_pattern) then
      path = path:gsub("%.", "/") -- Replace dots with slashes
    end
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
  end


  -- resolve path
  path = vim.fn.fnamemodify(path, ":p")

  M.print("resolved path" .. path)

  -- if is directory
  if vim.fn.isdirectory(path) == 1 then
    -- if recursive
    if recursive then
      -- require all files in directory
      local files = vim.fn.readdir(path)
      local req = false
      for _, file in ipairs(files) do
        local file_path = path .. "/" .. file
        if file_path:match("%.lua$") then
          if vim.fn.filereadable(file_path) == 1 then
            require(file_path:gsub("%.lua$", ""))
            req = true
          else
            error("require_dir -- File not readable: " .. file_path)
          end
        end
      end
      if not req then
        error("require_dir -- No lua files found in directory: " .. path)
      end
    else
      -- require init.lua
      local init_path = path .. "/init.lua"
      if vim.fn.filereadable(init_path) == 1 then
        require(init_path:gsub("%.lua$", ""))
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

---A helper function to print something to the console.
---@param obj any @The object to print.
---@param endstr string | nil @The string to print at the end. (default: "\n")
function M.print(obj, endstr)
  endstr = endstr or "\n"
  vim.api.nvim_out_write(vim.inspect(obj) .. endstr)
end

---A helper function to print error messages to the console.
---@param obj any @The object to print.
function M.print_error(obj)
  vim.api.nvim_err_writeln(vim.inspect(obj))
end

return M
