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
---@param mode string | table @The mode to set the keymap for.
---@param keys string @The keys to set the keymap for.
---@param command string | function @The command to set the keymap for.
---@param desc_or_opts string | table | nil @The description to set the keymap for.
---@param opts table | nil @The options to set the keymap for.
---@param opts.noremap boolean | nil @Only remap the keymap if it does not already exist.
---@param opts.remap boolean | nil @Remap if the keymap already exists. (default: true if noremap is not set)
---@param opts.silent boolean | nil @Do not echo the command to the command-line.
---@param opts.expr boolean | nil @Evaluate the given command as an expression to obtain the final map resut.
---@param opts.nowait boolean | nil @Do not wait for other keymaps after this one.
---@param opts.cmd boolean | nil @Execute the given command directly when invoked.
---@param opts.script boolean | nil @Only remap characters that were defined local to a script.
---@param opts.unique boolean | nil @Do not override a keymap if it already exists.
---@param opts.buffer boolean | number | nil @Set the keymap for the current buffer only.
---@param opts.local boolean | nil @Set the keymap for the current buffer only.
---@note This is a wrapper around `vim.keymap.set` that provides a more user-friendly interface.
---@example
---- -- Map to a Lua function:
---- kmap('n', 'lhs', function() print("real lua function") end, "description", { noremap = true })
---- -- Map to multiple modes:
---- kmap({'n', 'v'}, '<leader>lr', vim.lsp.buf.references, "description", { buffer = true })
---- -- Buffer-local mapping:
---- kmap('n', '<leader>w', "<cmd>w<cr>", "description", { silent = true, buffer = 5 })
---- -- Expr mapping:
---- kmap('i', '<Tab>', function()
----   return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
---- end, "description", { expr = true })
---- -- <Plug> mapping:
---- kmap('n', '[%%', '<Plug>(MatchitNormalMultiBackward)', "description",)
function M.kmap(mode, keys, command, desc_or_opts, opts)
  -- if desc_or_opts is not a string, then its opts
  local desc = nil
  if opts == nil and type(desc_or_opts) == 'table' then
    opts = desc_or_opts
  elseif type(desc_or_opts) == 'string' then
    desc = desc_or_opts
  elseif type(desc_or_opts) == 'table' then
    error("kmap -- desc_or_opts can't be a table when opts is not nil")
  elseif desc_or_opts ~= nil then
    M.print_error(desc_or_opts)
    error("kmap -- desc_or_opts must be a string or table")
  end

  opts = opts or {}

  if desc then
    desc = '' .. desc
  end

  if opts.noremap == nil and opts.remap == nil then
    -- check if already mapped
    local map_exists = vim.fn.mapcheck(keys, mode)

    if map_exists == "" then
      opts.remap = true
    else
      M.print_error({ keys = keys, mode = mode, command = command, desc = desc})
      error("WARNING: Keymap already exists (use { [no]remap = true } or to disable this warning)")
    end

  end

  vim.keymap.set(mode, keys, command, { desc = desc, table.unpack(opts) })
end

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

---True if the current operating system is Linux.
function M.is_linux()
  return M.get_os() == "linux"
end

---True if the current operating system is Windows.
function M.is_windows()
  return M.get_os() == "windows"
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
  p = p:gsub("lua/gamma/utility/init.lua", "")
  p = p:gsub("lua\\gamma\\utility/init.lua", "")
  return p
end

---A better require, that supports recursive require of directories.
---@param path string @The path to require. Can also be a directory.
---@param recursive boolean | nil @Whether or not to require all files in the directory.
---@param allow_empty boolean | nil @Whether or not to allow empty directories.
function M.require_dir(path, recursive, allow_empty)
  allow_empty = allow_empty or false

  local import_path = path
  import_path = string.gsub(import_path, "/", ".")
  import_path = string.gsub(import_path, "\\", ".")

  recursive = recursive or false
  -- check if path starts with ./ or ../ or .\ or ..\

  local rel = {
    dot_slash = string.match(path, "^%./"),
    dot_dot_slash = string.match(path, "^%.%./"),
    dot_back_slash = string.match(path, "^%.\\"),
    dot_dot_back_slash = string.match(path, "^%.%.\\"),
  }


  local dir = M.config_path()
  dir = vim.fn.fnamemodify(dir, ":p")

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


  -- resolve path
  path = vim.fn.fnamemodify(path, ":p")

  -- Switch backslashes to forward slashes
  path = string.gsub(path, "\\", "/")
  -- Remove trailing slash
  path = string.gsub(path, "/$", "")

  -- if is directory
  if vim.fn.isdirectory(path) == 1 then
    -- remove config dir from path
    path = string.gsub(path, dir, "")

    -- if recursive
    if recursive then
      -- require all files in directory
      local files = vim.fn.readdir(path)
      local req = false
      for _, file in ipairs(files) do
        local file_path = path .. "/" .. file
        if file_path:match("%.lua$") then
          if vim.fn.filereadable(file_path) == 1 then
            local import_file_path = import_path .. "." .. file:gsub("%.lua$", "")
            require(import_file_path)
            req = true
          else
            error("require_dir -- File not readable: " .. file_path)
          end
        end
      end
      if not req and not allow_empty then
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
  if vim.g.vscode then
    print(vim.inspect(obj) .. endstr)
  else
    vim.api.nvim_out_write(vim.inspect(obj) .. endstr)
  end
end

---A helper function to print error messages to the console.
---@param obj any @The object to print.
function M.print_error(obj)
  if vim.g.vscode then
    print(vim.inspect(obj))
  else
    vim.api.nvim_err_writeln(vim.inspect(obj))
  end
end


---Execute shell commands.
---@param cmd string @The command to execute.
---@param opts table | nil @The options to execute the command with.
---@param opts.async boolean | nil @Whether or not to execute the command asynchronously.
---@param opts.cwd string | nil @The current working directory to execute the command in.
---@param opts.env table | nil @The environment variables to execute the command with.
---@param opts.timeout number | nil @The timeout to execute the command with.
---@param opts.input string | nil @The input to execute the command with.
---@param opts.silent boolean | nil @Whether or not to execute the command silently.
---@param opts.on_exit function | nil @The function to execute when the command exits.
---@return table @{ code = 0, signal = 0, stdout = 'hello', stderr = '' }
function M.shell(cmd, opts)
  opts = opts or {}
  local async = opts.async or false
  opts.async = nil
  local on_exit = opts.on_exit or nil
  opts.on_exit = nil
  if opts.text == nil then
    opts.text = true
  end
  local silent = opts.silent
  opts.silent = nil
  if silent == nil then
    silent = true
  end

  function _on_exit(obj)
    if not silent then
      if obj.code == 0 then
        M.print(obj.stdout)
      else
        M.print_error(obj.stderr)
      end
    end

    if on_exit then
      on_exit(obj)
    end
  end

  if async then
    return vim.system(cmd, opts, _on_exit)
  else
    return vim.system(cmd, opts, _on_exit):wait()
  end
end

return M
