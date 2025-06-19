local utility = require('gamma.utility')
local kmap = utility.kmap
local popup = require('gamma.popup')

local M = {}

-- File to store disabled plugins
local disabled_plugins_file = vim.fn.stdpath('data') .. '/__disabled_plugins__.json'

-- Load disabled plugins from file
function M.load_disabled_plugins()
    local file = io.open(disabled_plugins_file, 'r')
    if not file then
        return {}
    end

    local content = file:read('*all')
    file:close()

    if content == '' then
        return {}
    end

    local ok, disabled = pcall(vim.json.decode, content)
    return ok and disabled or {}
end

-- Save disabled plugins to file
function M.save_disabled_plugins(disabled)
    local file = io.open(disabled_plugins_file, 'w')
    if not file then
        vim.notify('Failed to save disabled plugins', vim.log.levels.ERROR)
        return
    end

    file:write(vim.json.encode(disabled))
    file:close()
end

-- Check if plugin should be loaded (used in lazy.lua)
function M.should_load_plugin(plugin_name)
    local disabled = M.load_disabled_plugins()
    return not vim.tbl_contains(disabled, plugin_name)
end

local ignored_plugins = {
    'lazy.nvim', -- Lazy itself should not be disabled
}

-- Get all installed plugins from lazy
function M.get_all_plugins()
    local lazy_ok, lazy = pcall(require, 'lazy')
    if not lazy_ok then
        return {}
    end


    local plugins = {}
    for _, plugin in pairs(lazy.plugins()) do
        if not vim.tbl_contains(ignored_plugins, plugin.name) then
            table.insert(plugins, {
                name = plugin.name,
                loaded = plugin._.loaded ~= nil,
                url = plugin.url or 'local',
                dir = plugin.dir
            })
        end
    end

    -- lazy won't include disabled plugins in the list,
    -- so we need to load them from the disabled file
    local disabled = M.load_disabled_plugins()
    for _, name in ipairs(disabled) do
        if not vim.tbl_contains(plugins, function(p) return p.name == name end) then
            table.insert(plugins, {
                name = name,
                loaded = false,
                url = 'disabled',
                dir = nil
            })
        end
    end

    -- Sort plugins alphabetically
    table.sort(plugins, function(a, b) return a.name < b.name end)
    return plugins
end

-- Toggle plugin enabled/disabled state
function M.toggle_plugin(plugin_name)
    local disabled = M.load_disabled_plugins()
    local index = nil

    for i, name in ipairs(disabled) do
        if name == plugin_name then
            index = i
            break
        end
    end

    if index then
        -- Plugin is disabled, enable it
        table.remove(disabled, index)
        vim.notify(string.format('Enabled plugin: %s (restart required)', plugin_name), vim.log.levels.INFO)
    else
        -- Plugin is enabled, disable it
        table.insert(disabled, plugin_name)
        vim.notify(string.format('Disabled plugin: %s (restart required)', plugin_name), vim.log.levels.WARN)
    end

    M.save_disabled_plugins(disabled)
end

-- Enable all plugins
function M.enable_all_plugins()
    M.save_disabled_plugins({})
    vim.notify('Enabled all plugins (restart required)', vim.log.levels.INFO)
end

-- Clear the disabled plugins file (fix corrupted data)
function M.clear_disabled_plugins()
    local file = io.open(disabled_plugins_file, 'w')
    if file then
        file:write('[]')
        file:close()
        vim.notify('Cleared disabled plugins file', vim.log.levels.INFO)
    else
        vim.notify('Failed to clear disabled plugins file', vim.log.levels.ERROR)
    end
end

-- Disable all plugins
function M.disable_all_plugins()
    local plugins = M.get_all_plugins()
    local all_names = {}

    for _, plugin in ipairs(plugins) do
        table.insert(all_names, plugin.name)
    end

    M.save_disabled_plugins(all_names)
    vim.notify(string.format('Disabled all %d plugins (restart required)', #all_names), vim.log.levels.WARN)
end

-- Create plugin management UI
function M.show_plugin_manager(filter_mode)
    filter_mode = filter_mode or 'all' -- 'all', 'enabled', 'disabled'
    local plugins = M.get_all_plugins()
    local disabled = M.load_disabled_plugins()

    -- Filter plugins based on mode
    local filtered_plugins = {}
    for _, plugin in ipairs(plugins) do
        local is_disabled = vim.tbl_contains(disabled, plugin.name)

        if filter_mode == 'all' then
            table.insert(filtered_plugins, plugin)
        elseif filter_mode == 'enabled' and not is_disabled then
            table.insert(filtered_plugins, plugin)
        elseif filter_mode == 'disabled' and is_disabled then
            table.insert(filtered_plugins, plugin)
        end
    end

    -- Build content
    local filter_text = filter_mode == 'all' and 'All' or
        filter_mode == 'enabled' and 'Enabled Only' or 'Disabled Only'

    local lines = {
        string.format('# Plugin Manager - %s', filter_text),
        '',
        'Controls:',
        '  <Enter>  - Toggle plugin on/off',
        '  1        - Show all plugins',
        '  2        - Show enabled plugins only',
        '  3        - Show disabled plugins only',
        '  a        - Enable all plugins',
        '  d        - Disable all plugins',
        '  c        - Clear disabled plugins file',
        '  r        - Restart Neovim',
        '  q        - Close',
        '',
        string.format('Total: %d | Shown: %d | Disabled: %d', #plugins, #filtered_plugins, #disabled),
        '',
        '--- Plugins ---'
    }

    local plugin_start_line = #lines + 1

    for i, plugin in ipairs(filtered_plugins) do
        local is_disabled = vim.tbl_contains(disabled, plugin.name)
        local status = is_disabled and '[DISABLED]' or '[ENABLED] '
        local loaded_indicator = plugin.loaded and '●' or '○'

        table.insert(lines, string.format('%s %s %s %s',
            status, loaded_indicator, plugin.name, plugin.url))
    end


    -- Set up keymaps
    local opts = { silent = true, remap = true }

    popup.floating_content({
            title = string.format('Plugin Manager - %s', filter_text),
            content = lines,
            keymaps = function(popup_opts)
                local win = popup_opts.win

                -- Helper function to preserve cursor position during refresh
                local function refresh_with_cursor(new_filter_mode)
                    local cursor_pos = vim.api.nvim_win_get_cursor(win)
                    vim.api.nvim_win_close(win, true)
                    vim.schedule(function()
                        M.show_plugin_manager(new_filter_mode or filter_mode)
                        -- Try to restore cursor position after refresh
                        vim.schedule(function()
                            local current_win = vim.api.nvim_get_current_win()
                            local line_count = vim.api.nvim_buf_line_count(vim.api.nvim_win_get_buf(current_win))
                            local target_line = math.min(cursor_pos[1], line_count)
                            pcall(vim.api.nvim_win_set_cursor, current_win, { target_line, cursor_pos[2] })
                        end)
                    end)
                end

                return {
                    -- Filter controls
                    { 'n', '1', function()
                        refresh_with_cursor('all')
                    end, "Show all plugins", opts },

                    { 'n', '2', function()
                        refresh_with_cursor('enabled')
                    end, "Show enabled plugins only", opts },

                    { 'n', '3', function()
                        refresh_with_cursor('disabled')
                    end, "Show disabled plugins only", opts },

                    -- Toggle plugin
                    { 'n', '<CR>', function()
                        local cursor_pos = vim.api.nvim_win_get_cursor(win)
                        local line = cursor_pos[1]
                        local plugin_index = line - plugin_start_line + 1

                        if plugin_index > 0 and plugin_index <= #filtered_plugins then
                            local plugin = filtered_plugins[plugin_index]
                            M.toggle_plugin(plugin.name)
                            refresh_with_cursor()
                        end
                    end, "Toggle plugin on/off", opts },

                    -- Enable all
                    { 'n', 'a', function()
                        M.enable_all_plugins()
                        refresh_with_cursor()
                    end, "Enable all plugins", opts },

                    -- Disable all
                    { 'n', 'd', function()
                        M.disable_all_plugins()
                        refresh_with_cursor()
                    end, "Disable all plugins", opts },

                    -- Clear corrupted data
                    { 'n', 'c', function()
                        M.clear_disabled_plugins()
                        refresh_with_cursor()
                    end, "Clear disabled plugins file", opts },

                    -- Restart Neovim
                    { 'n', 'r', function()
                        vim.api.nvim_win_close(win, true)
                        M.restart_neovim()
                    end, "Restart Neovim", opts },

                    -- Closes
                    { 'n', 'q', function()
                        vim.api.nvim_win_close(win, true)
                    end, "Close plugin manager", opts },
                }
            end,
        },
        {
            filetype = 'markdown',
            modifiable = false
        }, {
            -- width = 80,
            -- height = 20,
        })
end

-- Restart Neovim
function M.restart_neovim()
    local choice = vim.fn.confirm('Restart Neovim now?', '&Yes\n&No', 1)
    if choice == 1 then
        vim.cmd('silent! wall') -- Save all files
        -- Use different restart methods based on environment
        if vim.env.TMUX then
            vim.fn.system('tmux respawn-pane -k')
        elseif vim.env.TERM_PROGRAM then
            vim.cmd('!exec $SHELL -c "exec nvim"')
        else
            vim.cmd('qall!')
        end
    end
end

return M
