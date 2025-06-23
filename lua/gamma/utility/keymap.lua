local M = {}

---@class gamma.utility.saved_kmap : vim.keymap.set.Opts
---@field mode string | string[] The mode the keymap is set for.
---@field keys string The keys the keymap is set for.
---@field map string | function The command the keymap is set for.
---@field icon? gamma.utility.kmap_icon_opts The icon options for the keymap.

---Custom keymaps set throughout will be inserted here.
---@type gamma.utility.saved_kmap[]
M.saved_maps = {}

---Custom keymaps set throughout will be inserted here.
---@type gamma.utility.saved_kmap[]
M.saved_maps_d = {}

---@class gamma.utility.kmap_icon_opts
---@field hl? string The highlight group to use for the icon.
---@field color? string The color to use for the icon, can be azure|blue|cyan|green|grey|orange|purple|red|yellow.
---@field cat? string The category of the icon, can be file|filetype|extension.
---@field name? string The name of the icon in the specified category.

---@class gamma.utility.kmap_opts : vim.keymap.set.Opts
---@field noremap? boolean Only remap the keymap if it does not already exist.
---@field remap? boolean Remap if the keymap already exists. (default: true if noremap is not set)
---@field silent? boolean Do not echo the command to the command-line.
---@field expr? boolean Evaluate the given command as an expression to obtain the final map resut.
---@field nowait? boolean Do not wait for other keymaps after this one.
---@field cmd? boolean Execute the given command directly when invoked.
---@field script? boolean Only remap characters that were defined local to a script.
---@field buffer? boolean | number Set the keymap for a given buffer only.
---@field local? boolean Set the keymap for the current buffer only.
---@field desc? string The description of the keymap.
---@field icon? string | gamma.utility.kmap_icon_opts The icon to use for the keymap.
---@field group? string The group to use for the keymap, used by which-key.

M._deferred_wk_args = {}

--- Set a keymap
---@param mode string | string[] @The mode to set the keymap for.
---@param keys string | string[]  @The keys to set the keymap for.
---@param command string | function @The command to set the keymap for.
---@param desc_or_opts? string | table The description to set the keymap for or the options to set the keymap for.
---@param opts? gamma.utility.kmap_opts The options to set the keymap for.
---@note This is a wrapper around `vim.keymap.set` that provides a more user-friendly interface.
function M.kmap(mode, keys, command, desc_or_opts, opts)
  local table_utils = require('gamma.utility.table')
  local logging_utils = require('gamma.utility.logging')
  
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
    logging_utils.print_error(desc_or_opts)
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
    local k_opts = table_utils.merge_table({}, opts)

    if k_opts.noremap == nil and k_opts.remap == nil then
      -- check if already mapped
      local map_exists = M.keymap_exists(_mode, key)
      if map_exists ~= false then
        logging_utils.print_error({ keys = key, mode = _mode, command = command, desc = desc })

        -- Format existing mapping info
        local e_map_lhs = map_exists.lhs or key
        local e_map_rhs = map_exists.rhs or map_exists.callback or ""
        if type(e_map_rhs) == "function" then
          e_map_rhs = "<function>"
        elseif map_exists.callback then
          e_map_rhs = "<callback>"
        end
        local e_map_desc = map_exists.desc or ""
        local e_map_mode = map_exists.mode or ""

        -- Get source location if available
        local source_info = ""
        if map_exists.sid and map_exists.sid > 0 then
          local script_info = vim.fn.getscriptinfo({ sid = map_exists.sid })
          if script_info and #script_info > 0 and script_info[1].name then
            source_info = " [" .. script_info[1].name .. "]"
          end
        end

        -- Get current location where new keymap is being defined
        local current_info = debug.getinfo(2, "Sl")
        local current_location = ""
        if current_info and current_info.source and current_info.currentline then
          local file = current_info.source:match("^@(.+)") or current_info.source
          current_location = string.format("\n  Attempting to define at: %s:%d", file, current_info.currentline)
        end
        -- Create readable mode list
        local mode_str = type(_mode) == "table" and table.concat(_mode, ",") or tostring(_mode)

        error(string.format(
          "\nWARNING: Keymap '%s' (%s) already exists in '%s' mode.\n" ..
          "  Existing: %s -> %s (%s) %s%s\n" ..
          "  Use { remap = true } to override or { noremap = true } to skip",
          key, desc or "no desc", mode_str,
          e_map_lhs, e_map_rhs, e_map_mode, e_map_desc, current_location
        ))
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
      logging_utils.print_error("kmap -- icon must be a string or table, got " .. type(k_opts.icon))
      error("kmap -- icon must be a string or table")
    end

    -- set the keymap (filter out custom fields that vim.keymap.set doesn't accept)
    local vim_opts = {}
    for k, v in pairs(k_opts) do
        if k ~= 'icon' and k ~= 'group' then
            vim_opts[k] = v
        end
    end
    local opts_args = vim.tbl_extend('keep', { desc = desc }, vim_opts)
    vim.keymap.set(_mode, key, command, opts_args)

    if k_opts.icon or k_opts.group then
      -- add to which-key
      local wk_arg = vim.tbl_extend('keep', {
        key,
        command,
        mode = _mode,
        icon = k_opts.icon,
        group = k_opts.group,
      }, opts_args)
      local ok, wk = pcall(require, "which-key")
      if ok and wk then
        wk.add({ wk_arg })
      else
        --  defer the call because which-key might not be loaded yet, we defer the call
        table.insert(M._deferred_wk_args, wk_arg)
      end
    end
    -- add to saved_maps
    local map = vim.tbl_extend('keep', {
      mode = _mode,
      keys = key,
      map = command,
      icon = k_opts.icon,
      group = k_opts.group,
      table.unpack(opts_args),
    }, opts_args)
    table.insert(M.saved_maps, map)
    M.saved_maps_d[key] = map
  end
end

vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
   
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
---@return false|table @Whether or not the keymap exists. If it does, return the keymap info.
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
    -- Fast check first with mapcheck
    if vim.fn.mapcheck(keys, m) ~= "" then
      -- Only call maparg if mapping exists
      local map_info = vim.fn.maparg(keys, m, false, true)
      if map_info and next(map_info) then
        return map_info
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

return M