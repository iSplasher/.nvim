require('compat')

local M = {}

--- Checks if a plugin is loaded in Lazy.nvim
---@param plugin_name string
---@return boolean
function M.is_plugin_loaded(plugin_name)
    local ok, lazy = pcall(require, 'lazy.core.config')
    if not ok then
        return false -- Lazy.nvim is not loaded
    end

    local plugin = lazy.plugins[plugin_name]
    if plugin and plugin._.loaded then
        return true
    end
    return false
end

--- Checks if which-key is enabled
--- @return boolean
function M.is_which_key_enabled()
    return M.is_plugin_loaded('which-key.nvim')
end
return M
