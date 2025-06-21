require('compat')

local M = {}

---A helper function to turn a table into a string.
---@param tbl table @The table.
---@param depth? number @The depth of sub-tables to traverse through.
---@param indent? number @Do NOT manually set this. This controls formatting through recursion.
---@return string @The string representation of the table.
function M.table_to_string(tbl, depth, indent)
  indent = indent or 0
  depth = depth or 5
  local str = ""
  
  if depth == 0 then
    return string.rep("  ", indent) .. "..."
  end

  if type(tbl) ~= "table" then
    return tostring(tbl)
  end

  -- Check if table is empty
  if next(tbl) == nil then
    return "{}"
  end

  -- Check if table is array-like
  local is_array = true
  local max_index = 0
  for k, _ in pairs(tbl) do
    if type(k) ~= "number" or k <= 0 or k ~= math.floor(k) then
      is_array = false
      break
    end
    max_index = math.max(max_index, k)
  end

  -- For arrays, check if indices are contiguous
  if is_array then
    for i = 1, max_index do
      if tbl[i] == nil then
        is_array = false
        break
      end
    end
  end

  str = str .. "{\n"

  if is_array then
    -- Format as array
    for i = 1, max_index do
      local value = tbl[i]
      str = str .. string.rep("  ", indent + 1)

      if type(value) == "table" then
        str = str .. M.table_to_string(value, depth - 1, indent + 1)
      elseif type(value) == "string" then
        str = str .. string.format("%q", value)
      elseif type(value) == "function" then
        str = str .. "<function>"
      elseif type(value) == "nil" then
        str = str .. "nil"
      elseif type(value) == "boolean" then
        str = str .. tostring(value)
      else
        str = str .. tostring(value)
      end

      if i < max_index then
        str = str .. ","
      end
      str = str .. "\n"
    end
  else
    -- Format as dictionary
    local keys = {}
    for k, _ in pairs(tbl) do
      table.insert(keys, k)
    end

    -- Sort keys for consistent output
    table.sort(keys, function(a, b)
      local ta, tb = type(a), type(b)
      if ta == tb then
        if ta == "string" or ta == "number" then
          return tostring(a) < tostring(b)
        end
      end
      return ta < tb
    end)

    for i, key in ipairs(keys) do
      local value = tbl[key]
      str = str .. string.rep("  ", indent + 1)

      -- Format key
      if type(key) == "string" then
        if key:match("^[%a_][%w_]*$") then
          str = str .. key -- Valid identifier, no quotes needed
        else
          str = str .. "[" .. string.format("%q", key) .. "]"
        end
      elseif type(key) == "number" then
        str = str .. "[" .. tostring(key) .. "]"
      else
        str = str .. "[" .. tostring(key) .. "]"
      end

      str = str .. " = "

      -- Format value
      if type(value) == "table" then
        str = str .. M.table_to_string(value, depth - 1, indent + 1)
      elseif type(value) == "string" then
        str = str .. string.format("%q", value)
      elseif type(value) == "function" then
        str = str .. "<function>"
      elseif type(value) == "nil" then
        str = str .. "nil"
      elseif type(value) == "boolean" then
        str = str .. tostring(value)
      else
        str = str .. tostring(value)
      end

      if i < #keys then
        str = str .. ","
      end
      str = str .. "\n"
    end
  end

  str = str .. string.rep("  ", indent) .. "}"
  return str
end

M.format_table = M.table_to_string -- Alias for table_to_string
---A helper function to print a table's contents.
---@param tbl table @The table to print.
---@param depth? number @The depth of sub-tables to traverse through and print.
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

---@class gamma.utility.saved_kmap
---@field mode string | string[] The mode the keymap is set for.
---@field keys string The keys the keymap is set for.
---@field map string | function The command the keymap is set for.
---@field desc string The description of the keymap.
---@field icon? gamma.utility.kmap_icon_opts The icon options for the keymap.


---Custom keymaps set throughout will be inserted here.
---@type gamma.utility.saved_kmap[]
M.saved_maps = {}
---Custom keymaps set throughout will be inserted here.




---@type gamma.utility.saved_kmap[]
M.saved_maps_d = {}
--
---@class gamma.utility.kmap_icon_opts
---@field hl? string The highlight group to use for the icon.
---@field color? string The color to use for the icon, can be azure|blue|cyan|green|grey|orange|purple|red|yellow.
---@field cat? string The category of the icon, can be file|filetype|extension.
---@field name? string The name of the icon in the specified category.
--
---@class gamma.utility.kmap_opts
---@field noremap? boolean Only remap the keymap if it does not already exist.
---@field remap? boolean Remap if the keymap already exists. (default: true if noremap is not set)
---@field silent? boolean Do not echo the command to the command-line.
---@field expr? boolean Evaluate the given command as an expression to obtain the final map resut.
---@field nowait? boolean Do not wait for other keymaps after this one.
---@field cmd? boolean Execute the given command directly when invoked.
---@field script? boolean Only remap characters that were defined local to a script.
---@field unique? boolean Do not override a keymap if it already exists.
---@field buffer? boolean | number Set the keymap for a given buffer only.
---@field local? boolean Set the keymap for the current buffer only.
---@field desc? string The description of the keymap.
---@field icon? string | gamma.utility.kmap_icon_opts The icon to use for the keymap.
---@field group? string The group to use for the keymap, used by which-key.



local _deferred_wk_args = {}

--
--
--- Set a keymap
---@param mode string | string[] @The mode to set the keymap for.
---@param keys string | string[]  @The keys to set the keymap for.
---@param command string | function @The command to set the keymap for.
---@param desc_or_opts? string | table The description to set the keymap for or the options to set the keymap for.
---@param opts? gamma.utility.kmap_opts The options to set the keymap for.
---@note This is a wrapper around `vim.keymap.set` that provides a more user-friendly interface.
function M.kmap(mode, keys, command, desc_or_opts, opts)
  -- if desc_or_opts is not a string, then its opts
  local desc = nil
  if type(desc_or_opts) == 'string' then
    desc = desc_or_opts
  end
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
  local _mode = {}
  if type(mode) == 'string' then
    _mode = { mode }
  elseif type(mode) == 'table' then
    _mode = mode
  else
    error("kmap -- mode parameter must be a string or table")
  end

  -- keys to list
  if type(keys) == 'string' then
    keys = { keys }
  end
  opts = opts or {}

  if desc == nil then
    desc = opts.desc or nil
  end
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
      local map_exists = M.keymap_exists(_mode, key)
      if map_exists ~= false then
        if not err then
          err = true
          M.print_error({ keys = key, mode = _mode, command = command, desc = desc })
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
            " already exists in '" .. M.table_to_string(_mode) ..
            "' mode. (use { [no]remap = true } or to disable this warning)" ..
            "\n  Existing map: " .. e_map_lhs .. " -> " .. e_map_rhs .. " (" .. e_map_mode .. ") " .. e_map_desc)
        end
      else
        k_opts.remap = true
      end
    end

    if type(k_opts.icon) == 'string' then
      -- if icon is a string, then convert it to a table
      k_opts.icon = {
        name = k_opts.icon,
      }
    elseif type(k_opts.icon) ~= 'table' and k_opts.icon ~= nil then
      M.print_error("kmap -- icon must be a string or table, got " .. type(k_opts.icon))
      error("kmap -- icon must be a string or table")
    end

    -- set the keymap
    vim.keymap.set(_mode, key, command, { desc = desc, table.unpack(k_opts) })

    -- add to which-key
    --  defer the call BufReadPost because whick-key might not be loaded yet, we defer the call
    table.insert(_deferred_wk_args, {
      key,
      mode = _mode,
      desc = desc,
      buffer = k_opts.buffer,
      icon = k_opts.icon,
      group = k_opts.group,
    })
    -- add to saved_maps
    local map = {
      mode = _mode,
      keys = key,
      map = command,
      desc = desc,
      icon = k_opts.icon,
      group = k_opts.group,
    }
    table.insert(M.saved_maps, map)
    M.saved_maps_d[key] = map
    
    

  end
end

vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local ok, wk = pcall(require, "which-key")
    if ok and wk and vim.tbl_count(_deferred_wk_args) > 0 then
      wk.add(_deferred_wk_args)
    else
      M.warn("kmap -- which-key not loaded, cannot add icon to keymaps")
    end
  end,
})
---Get a dictionary of all saved keymaps.
---@return gamma.utility.saved_kmap[] @The saved keymaps.
function M.get_saved_maps()
  -- if saved_maps is empty, then fill it with current mappings
  if #M.saved_maps == 0 then
    for _, m in ipairs(vim.fn.maplist()) do
      local map = {
        mode = m.mode,
        keys = m.lhs,
        map = m.rhs,
        desc = "",
      }
      table.insert(M.saved_maps, map)
      M.saved_maps_d[m.lhs] = map
    end
  end

  return M.saved_maps
end

---Check if a keymap exists.
---@param mode string | string[] @The mode to check the keymap for.
---@param keys string @The keys to check the keymap for.
---@return false|gamma.utility.saved_kmap @Whether or not the keymap exists. If it does, return the keymap.
function M.keymap_exists(mode, keys)
  if #M.saved_maps == 0 then
    M.get_saved_maps()
  end

  local _mode = {}
  if type(mode) == 'string' then
    _mode = { mode }
  elseif type(mode) == 'table' then
    _mode = mode
  else
    error("keymap_exists -- mode parameter must be a string or table")
  end

  for _, m in ipairs(_mode) do
    local r = vim.fn.mapcheck(keys, m) ~= ""
    if r ~= "" then
      local m = M.saved_maps_d[keys]
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
  p = p:gsub("lua/gamma/utility/init.lua", "")
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

M._print = vim.schedule_wrap(function(obj, endstr, level)
  endstr = endstr or "\n"
  local msg = vim.inspect(obj) .. endstr
  local p = print
  if level == vim.log.levels.ERROR then
    p = error
  elseif level == vim.log.levels.WARN then
    msg = "WARN: " .. msg
  elseif level == vim.log.levels.DEBUG then
    msg = "DEBUG: " .. msg
  end
  if vim.g.vscode then
    p(msg)
  else
    local ok, _ = pcall(vim.notify, msg, level)
    if not ok then
      -- Fallback to print if notify fails
      p(msg)
    end
  end
end)

---A helper function to print something to the console.
---@param obj any @The object to print.
---@param endstr? string The string to print at the end. (default: "\n")
function M.print(obj, endstr)
  M._print(obj, endstr, vim.log.levels.INFO)
end

---A helper function to print error messages to the console.
---@param obj any @The object to print.
function M.print_error(obj)
  M._print(obj, nil, vim.log.levels.ERROR)
end

---A helper function to print warning messages to the console.
---@param obj any @The object to print.
function M.print_warn(obj)
  M._print(obj, nil, vim.log.levels.WARN)
end
---A helper function to print debug messages to the console.
---@param obj any @The object to print.
function M.print_debug(obj)
  M._print(obj, nil, vim.log.levels.DEBUG)
end

---@class gamma.utility.shell_opts
---@field async? boolean Whether or not to execute the command asynchronously.
---@field cwd? string The current working directory to execute the command in.
---@field env? table The environment variables to execute the command with.
---@field timeout? number The timeout to execute the command with.
---@field input? string The input to execute the command with.
---@field text? boolean Whether or not to return the output as text. (default: true)
---@field verbose? boolean Print the command before executing it, and print the output.
---@field silent? boolean Do not print the output, or command.
---@field on_exit? function The function to execute when the command exits. (optional)
---A helper function to execute shell commands.
---@param cmd string[] @The command to execute.
---@param opts? gamma.utility.shell_opts The options to execute the command with.
---@return vim.SystemObj | vim.SystemCompleted
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

  local function _on_exit(obj)
    if not opts.silent or opts.silent == nil then
      if obj.code == 0 then
        if verbose then
          M.print(obj.stdout)
          if obj.stderr and obj.stderr ~= "" then
            M.print(obj.stderr)
          end
        end
      else
        M.print_error(M.print_table(obj))
      end
    end
    
    if on_exit then
      on_exit(obj)
    end
    return obj
  end

  ---@type vim.SystemOpts
  ---@diagnostic disable-next-line: assign-type-mismatch
  local _opts = opts
  if async then
    return vim.system(cmd, _opts, _on_exit)
  else
    return vim.system(cmd, _opts, _on_exit):wait()
  end
end

---Check if a command exists and is executable and returns its abspath
---@param cmd string @The command to check.
---@return string | nil @The absolute path to the command if it exists, otherwise nil.
function M.which(cmd)
  local p = vim.fn.resolve(vim.fn.exepath(cmd))
  if p ~= "" then
    return p
  else
    return nil
  end
end

---@class gamma.utility.termcodes_opts
---@field replace_leader? boolean Replace <leader> with the value of vim.g.mapleader. Default: true
---@field replace_localleader? boolean Replace <localleader> with the value of vim.g.maplocalleader. Default: true
---@field special? boolean Replace keycodes, e.g. <CR> becomes a "\r" char. Default: true


---Get the termcodes for a keymapping
---@param keys string @The keys to get the termcodes for.
---@gamma.utility.termcodes_opts? opts The options to use when getting the termcodes.
---@return string @The termcodes for the keys.
function M.get_termcodes(keys, opts)
  opts = opts or {}
  if keys == nil or keys == "" then
    return ""
  end
  if type(keys) ~= "string" then
    error("get_termcodes -- keys must be a string, not " .. type(keys))
  end
  if opts.replace_leader ~= false and keys and string.find(keys, "<leader>") then
    keys = string.gsub(keys, "<leader>", vim.g.mapleader or "\\")
  end
  if opts.replace_localleader ~= false and keys and string.find(keys, "<localleader>") then
    keys = string.gsub(keys, "<localleader>", vim.g.maplocalleader or "\\")
  end

  return vim.api.nvim_replace_termcodes(keys, true, true, opts.special ~= false)
end

M.transkey = M.get_termcodes         -- Alias for get_termcodes
M.get_key = M.get_termcodes          -- Alias for get_termcodes
M.canonicalize_key = M.get_termcodes -- Alias for get_termcodes
return M

