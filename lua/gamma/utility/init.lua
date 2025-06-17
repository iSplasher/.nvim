require('compat')

local M = {}

---A helper function to turn a table into a string.
---@param tbl table @The table.
---@param depth number @The depth of sub-tables to traverse through.
---@param n number @Do NOT manually set this. This controls formatting through recursion.
function M.table_to_string(tbl, depth, n)
  n = n or 0;
  depth = depth or 5;
  str = ""

  if (depth == 0) then
    str = str .. (string.rep(' ', n) .. "...");
    return str
  end

  if (n == 0) then
    str = str .. (" ");
  end

  for key, value in pairs(tbl) do
    if (key and type(key) == "number" or type(key) == "string") then
      key = string.format("[\"%s\"]", key);

      if (type(value) == "table") then
        if (next(value)) then
          str = str .. (string.rep(' ', n) .. key .. " = {");
          str = str .. M.table_to_string(value, depth - 1, n + 4);
          str = str .. (string.rep(' ', n) .. "},");
        else
          str = str .. (string.rep(' ', n) .. key .. " = {},");
        end
      else
        if (type(value) == "string") then
          value = string.format("\"%s\"", value);
        else
          value = tostring(value);
        end

        str = str .. (string.rep(' ', n) .. key .. " = " .. value .. ",");
      end
    end
  end

  if (n == 0) then
    str = str .. (" ");
  end
  return str
end

---A helper function to print a table's contents.
---@param tbl table @The table to print.
---@param depth number @The depth of sub-tables to traverse through and print.
function M.print_table(tbl, depth)
  print(M.table_to_string(tbl, depth));
end

---A helper function to deep merge two tables.
---@param a table @The first table to merge.
---@param b table @The second table(s) to merge. (overwrites)
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

---A helper function to deep merge two tables.
---@param a table @The first table to merge.
---@param b table[] @The  tables to merge. (overwrites)
---@return table @The merged table.
function M.merge_tables(a, b)
  for _, t in ipairs(b) do
    a = M.merge_table(a, t)
  end
  return a
end

local _saved_maps = {}
local _saved_maps_d = {}
---Set a keymap.
---@param mode string | table @The mode to set the keymap for.
---@param keys string | table @The keys to set the keymap for.
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

  -- mode to list
  if type(mode) == 'string' then
    mode = { mode }
  end

  -- keys to list
  if type(keys) == 'string' then
    keys = { keys }
  end
  opts = opts or {}

  if desc then
    desc = '' .. desc
  end

  for _, key in ipairs(keys) do
    -- deep copy opts
    local k_opts = M.merge_table({}, opts)

    if k_opts.noremap == nil and k_opts.remap == nil then
      -- check if already mapped
      local err = false
      -- for each mode
      local map_exists = M.keymap_exists(mode, key)
      if map_exists ~= false then
        if not err then
          err = true
          M.print_error({ keys = key, mode = mode, command = command, desc = desc })
          -- Get the map
          -- {'lnum': 0, 'script': 0, 'mode': 'i', 'silent': 0, 'callback': function('<lambda>1'), 'noremap': 1, 'lhs': '<CR>', 'lhsr', 'nowait': 0, 'expr': 0, 'sid': -8, 'buffer': 0}
          local e_map = map_exists
          local e_map_lhs = e_map.lhs or ""
          local e_map_rhs = e_map.rhs or e_map.callback or e_map.expr or ""
          if type(e_map_rhs) == "function" then
            e_map_rhs = "<function>"
          end
          local e_map_desc = e_map.desc or ""
          local e_map_mode = e_map.mode or ""
          if type(e_map_mode) == "table" then
            e_map_mode = table.concat(e_map_mode, ", ")
          end

          error("\nWARNING: Keymap '" .. key .. "' (" .. desc .. ")" ..
            " already exists in '" .. M.table_to_string(mode) ..
            "' mode. (use { [no]remap = true } or to disable this warning)" ..
            "\n  Existing map: " .. e_map_lhs .. " -> " .. e_map_rhs .. " (" .. e_map_mode .. ") " .. e_map_desc)
        end
      else
        k_opts.remap = true
      end
    end

    vim.keymap.set(mode, key, command, { desc = desc, table.unpack(k_opts) })

    -- add to saved_maps
    local map = {
      mode = mode,
      keys = key,
      map = command,
      desc = desc,
    }
    table.insert(_saved_maps, map)
    _saved_maps_d[key] = map
  end
end

---Get a dictionary of all saved keymaps.
---@return table @The dictionary of all saved keymaps.
function M.get_saved_maps()
  -- if saved_maps is empty, then fill it with current mappings
  if #_saved_maps == 0 then
    for _, m in ipairs(vim.fn.maplist()) do
      local map = {
        mode = m.mode,
        keys = m.lhs,
        map = m.rhs,
        desc = "",
      }
      table.insert(_saved_maps, map)
      _saved_maps_d[m.lhs] = map
    end
  end

  return _saved_maps
end

---Check if a keymap exists.
---@param mode string @The mode to check the keymap for.
---@param keys string @The keys to check the keymap for.
---@return false|table @Whether or not the keymap exists. If it does, return the keymap.
function M.keymap_exists(mode, keys)
  if #_saved_maps == 0 then
    M.get_saved_maps()
  end

  if type(mode) == 'string' then
    mode = { mode }
  end

  for _, m in ipairs(mode) do
    local r = vim.fn.mapcheck(keys, m) ~= ""
    if r ~= "" then
      local m = _saved_maps_d[keys]
      if m ~= nil then
        return m
      end
    end
  end

  return false
end

---Execute keymap as if it was typed.
---@param keys string @The keys to execute the keymap for.
---@param mode string @The mode to execute the keymap for.
function M.type_keymap(keys, mode)
  mode = mode or "n"

  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, true, true), mode, false)
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

---Normalize path separators.
---@param path string @The path to normalize.
---@return string @The normalized path.
function M.normalize_path_sep(path)
  return path:gsub("\\", "/")
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


---Reliably get nvim config path
---@return string @The path to the nvim config directory.
function M.config_path()
  local p = debug.getinfo(1, "S").source:sub(2)
  -- go up directories
  p = p:gsub("lua/gamma/utility/init.lua", "")
  p = p:gsub("lua\\gamma\\utility/init.lua", "")
  return p
end

--Get the nvim-data directory
---@return string @The path to the nvim data directory.
function M.data_path()
  return vim.fn.stdpath("data")
end

---A better require, that supports recursive require of directories.
---@param path string @The path to require. Can also be a directory.
---@param recursive boolean | nil @Whether or not to require all files in the directory.
---@param allow_empty boolean | nil @Whether or not to allow empty directories.
function M.require_dir(path, recursive, allow_empty)
  allow_empty = allow_empty or false

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


  -- resolve path
  path = vim.fs.abspath(path)
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
          M.require_dir(next_dir, recursive, allow_empty)
        end
      end
      if not req and not allow_empty then
        error("require_dir -- No lua files found in directory: " .. path)
      end
    else
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

---A helper function to print something to the console.
---@param obj any @The object to print.
---@param endstr string | nil @The string to print at the end. (default: "\n")
function M.print(obj, endstr)
  endstr = endstr or "\n"
  local msg = vim.inspect(obj) .. endstr
  if vim.g.vscode then
    print(msg)
  else
    vim.notify(msg, 'info')
  end
end

---A helper function to print error messages to the console.
---@param obj any @The object to print.
function M.print_error(obj)
  local msg = vim.inspect(obj)
  if vim.g.vscode then
    print(msg)
  else
    vim.notify(msg, 'error')
  end
end

---Execute shell commands.
---@param cmd string[] @The command to execute.
---@param opts table | nil @The options to execute the command with.
---@param opts.async boolean | nil @Whether or not to execute the command asynchronously.
---@param opts.cwd string | nil @The current working directory to execute the command in.
---@param opts.env table | nil @The environment variables to execute the command with.
---@param opts.timeout number | nil @The timeout to execute the command with.
---@param opts.input string | nil @The input to execute the command with.
---@param opts.verbose boolean | nil @Print the command before executing it, and print the output.
---@param opts.silent boolean | nil @Do not print the output, or command.
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
  local verbose = opts.verbose
  opts.silent = opts.silent
  if verbose then
    verbose = true
    opts.silent = false
    M.print(string.format("shell: %s", table.concat(cmd, " ")))
  end

  function _on_exit(obj)
    if not opts.silent or opts.silent == nil then
      if obj.code == 0 then
        if verbose then
          M.print(obj.stdout)
        end
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
