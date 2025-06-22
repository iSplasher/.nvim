local M = {}

---@class gamma.utility.termcodes_opts
---@field replace_leader? boolean Replace <leader> with the value of vim.g.mapleader. Default: true
---@field replace_localleader? boolean Replace <localleader> with the value of vim.g.maplocalleader. Default: true
---@field special? boolean Replace keycodes, e.g. <CR> becomes a "\r" char. Default: true

---Get the termcodes for a keymapping
---@param keys string @The keys to get the termcodes for.
---@param opts? gamma.utility.termcodes_opts The options to use when getting the termcodes.
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

-- Aliases for get_termcodes
M.transkey = M.get_termcodes
M.get_key = M.get_termcodes
M.canonicalize_key = M.get_termcodes

return M