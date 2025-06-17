-- lua/gamma/commands/vimrc_export.lua
-- Export current Neovim configuration to .vimrc using gamma/vimrc.lua config
-- Usage: :VimrcExport [filename]

local M = {}
local vimrc_config = require('config.context.vimrc')

-- Get vim options and globals based on exports list
local function get_vim_options_and_globals()
    local opts = {}
    local globals = {}

    for _, export in ipairs(vimrc_config.exports) do
        -- Check if it's a global variable first
        if vim.g[export] ~= nil then
            globals[export] = vim.g[export]
        else
            -- Try to get it as a vim option
            local ok, value = pcall(function() return vim.opt[export]:get() end)
            if ok and value ~= nil then
                opts[export] = value
            end
        end
    end

    return opts, globals
end

-- Get current keymaps that match custom patterns
local function get_keymaps()
    local keymaps = {}
    local modes = { 'n', 'i', 'v', 'x', 'o', 'c' }

    for _, mode in ipairs(modes) do
        local mode_maps = vim.api.nvim_get_keymap(mode)
        for _, map in ipairs(mode_maps) do
            -- Skip built-in and plugin-generated maps
            if map.lhs and not map.lhs:match('^<Plug>') and not map.lhs:match('^<SNR>') then
                -- Focus on our custom mappings
                if map.lhs:match('^<leader>') or
                    map.lhs:match('^<[FHLU]>') or
                    map.lhs:match('^<C%-[du]>') or
                    map.lhs:match('^<A%-[hjklbwe]>') or
                    map.lhs:match('^[HJLQNUX]$') or
                    map.lhs:match('^%[q$') or map.lhs:match('^%]q$') then
                    table.insert(keymaps, {
                        mode = mode,
                        lhs = map.lhs,
                        rhs = map.rhs or '',
                        desc = map.desc or '',
                        noremap = map.noremap == 1,
                        silent = map.silent == 1
                    })
                end
            end
        end
    end

    return keymaps
end

-- Convert Lua value to vimscript
local function lua_to_vim_value(value)
    local value_type = type(value)

    if value_type == 'boolean' then
        return value and 'v:true' or 'v:false'
    elseif value_type == 'number' then
        return tostring(value)
    elseif value_type == 'string' then
        return string.format('"%s"', value:gsub('"', '\\"'))
    elseif value_type == 'table' then
        -- Handle arrays
        if vim.isarray(value) then
            local items = {}
            for _, v in ipairs(value) do
                table.insert(items, lua_to_vim_value(v))
            end
            return '[' .. table.concat(items, ', ') .. ']'
        else
            -- Handle dictionaries
            local items = {}
            for k, v in pairs(value) do
                table.insert(items, string.format('"%s": %s', k, lua_to_vim_value(v)))
            end
            return '{' .. table.concat(items, ', ') .. '}'
        end
    else
        return '""'
    end
end

-- Convert vim option to vimscript set command
local function option_to_vimscript(name, value)
    local value_type = type(value)

    if value_type == 'boolean' then
        if value then
            return 'set ' .. name
        else
            return 'set no' .. name
        end
    elseif value_type == 'number' then
        return string.format('set %s=%d', name, value)
    elseif value_type == 'string' then
        if name == 'listchars' then
            return string.format('set %s=%s', name, value)
        else
            return string.format('set %s=%s', name, value)
        end
    elseif value_type == 'table' then
        if name == 'completeopt' and vim.isarray(value) then
            return string.format('set %s=%s', name, table.concat(value, ','))
        elseif name == 'clipboard' and vim.isarray(value) then
            return string.format('set %s=%s', name, table.concat(value, ','))
        elseif name == 'listchars' then
            local parts = {}
            for k, v in pairs(value) do
                table.insert(parts, k .. ':' .. v)
            end
            return string.format('set %s=%s', name, table.concat(parts, ','))
        end
    end

    return '# TODO: Handle ' .. name .. ' = ' .. vim.inspect(value)
end

-- Convert keymap to vimscript
local function keymap_to_vimscript(map)
    local mode_map = {
        n = 'nnoremap',
        i = 'inoremap',
        v = 'vnoremap',
        x = 'xnoremap',
        o = 'onoremap',
        c = 'cnoremap'
    }

    local cmd = mode_map[map.mode] or 'nnoremap'
    if not map.noremap then
        cmd = cmd:gsub('nore', '')
    end

    local flags = ''
    if map.silent then
        flags = flags .. ' <silent>'
    end

    local comment = map.desc and map.desc ~= '' and ' " ' .. map.desc or ''

    return string.format('%s%s %s %s%s', cmd, flags, map.lhs, map.rhs, comment)
end

-- Generate the complete .vimrc content
function M.generate_vimrc_content()
    local lines = {}

    local function add(line)
        table.insert(lines, line or '')
    end

    -- Header
    add('" .vimrc - Auto-generated from current Neovim configuration')
    add('" Generated on: ' .. os.date('%Y-%m-%d %H:%M:%S'))
    add('" Exported from Neovim session using gamma.vimrc configuration')
    add('')

    -- Top section from configuration
    if vimrc_config.top and #vimrc_config.top > 0 then
        add('" ============================================================================')
        add('" TOP CONFIGURATION')
        add('" ============================================================================')
        add('')
        for _, line in ipairs(vimrc_config.top) do
            add(line)
        end
        add('')
    end

    -- Get vim options and globals
    local opts, globals = get_vim_options_and_globals()

    -- Global variables
    if next(globals) then
        add('" ============================================================================')
        add('" GLOBAL VARIABLES')
        add('" ============================================================================')
        add('')

        for name, value in pairs(globals) do
            add(string.format('let g:%s = %s', name, lua_to_vim_value(value)))
        end
        add('')
    end

    -- Vim options
    if next(opts) then
        add('" ============================================================================')
        add('" VIM OPTIONS (from current session)')
        add('" ============================================================================')
        add('')

        for name, value in pairs(opts) do
            local vimscript = option_to_vimscript(name, value)
            if not vimscript:match('^#') then -- Skip TODO items
                add(vimscript)
            end
        end
        add('')
    end

    -- Middle section from configuration
    if vimrc_config.middle and #vimrc_config.middle > 0 then
        add('" ============================================================================')
        add('" MIDDLE CONFIGURATION')
        add('" ============================================================================')
        add('')
        for _, line in ipairs(vimrc_config.middle) do
            add(line)
        end
        add('')
    end

    -- Keymaps
    add('" ============================================================================')
    add('" KEYMAPS (from current session)')
    add('" ============================================================================')
    add('')

    local keymaps = get_keymaps()

    -- Group keymaps by type
    local leader_maps = {}
    local movement_maps = {}
    local text_maps = {}
    local other_maps = {}

    for _, map in ipairs(keymaps) do
        if map.lhs:match('^<leader>') then
            table.insert(leader_maps, map)
        else
            table.insert(other_maps, map)
        end
    end

    -- Other keymaps
    if #other_maps > 0 then
        add('" General keymaps')
        for _, map in ipairs(other_maps) do
            add(keymap_to_vimscript(map))
        end
        add('')
    end

    -- Movement keymaps
    if #movement_maps > 0 then
        add('" Movement keymaps')
        for _, map in ipairs(movement_maps) do
            add(keymap_to_vimscript(map))
        end
        add('')
    end

    -- Text manipulation
    if #text_maps > 0 then
        add('" Text manipulation keymaps')
        for _, map in ipairs(text_maps) do
            add(keymap_to_vimscript(map))
        end
        add('')
    end

    -- Leader keymaps
    if #leader_maps > 0 then
        add('" Leader keymaps')
        for _, map in ipairs(leader_maps) do
            add(keymap_to_vimscript(map))
        end
        add('')
    end

    -- Plugin management section
    if vimrc_config.plugs and #vimrc_config.plugs > 0 then
        add('" ============================================================================')
        add('" PLUGIN MANAGEMENT (vim-plug)')
        add('" ============================================================================')
        add('')
        add('if empty(glob(\'~/.vim/autoload/plug.vim\'))')
        add('  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs')
        add('    \\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim')
        add('  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC')
        add('endif')
        add('')
        add('call plug#begin(\'~/.vim/plugged\')')
        add('')
        add('" Plugins from configuration')

        -- Generate plugin entries from vimrc_config
        for _, plugin in ipairs(vimrc_config.plugs) do
            if plugin.enabled ~= false then
                local plugin_name = plugin[1]

                -- Handle context conditions
                if plugin.context then
                    for _, ctx in ipairs(plugin.context) do
                        if ctx:match('^!') then
                            -- Negated context (e.g., '!ide' means "if not in IDE")
                            local context_name = ctx:sub(2)
                            add(string.format('if (!has(\'%s\'))', context_name))
                        else
                            -- Positive context
                            add(string.format('if (has(\'%s\'))', ctx))
                        end
                    end
                end

                -- Generate Plug line
                if plugin.plug then
                    local plug_opts = {}
                    for k, v in pairs(plugin.plug) do
                        table.insert(plug_opts, string.format('\'%s\': %s', k, v))
                    end
                    if plugin.context then
                        add(string.format('    Plug \'%s\', { %s }', plugin_name, table.concat(plug_opts, ', ')))
                    else
                        add(string.format('Plug \'%s\', { %s }', plugin_name, table.concat(plug_opts, ', ')))
                    end
                else
                    if plugin.context then
                        add(string.format('    Plug \'%s\'', plugin_name))
                    else
                        add(string.format('Plug \'%s\'', plugin_name))
                    end
                end

                if plugin.context then
                    add('endif')
                end
            end
        end

        add('')
        add('call plug#end()')
        add('')

        -- Plugin configurations
        add('" ============================================================================')
        add('" PLUGIN CONFIGURATIONS')
        add('" ============================================================================')
        add('')

        -- Add plugin-specific mappings and configs from configuration
        for _, plugin in ipairs(vimrc_config.plugs) do
            if plugin.enabled ~= false then
                local plugin_name = plugin[1]
                local has_config = false

                -- Add mappings
                if plugin.mappings then
                    if not has_config then
                        add(string.format('" %s configuration', plugin_name))
                        has_config = true
                    end
                    for _, mapping in ipairs(plugin.mappings) do
                        add(mapping)
                    end
                end

                -- Add custom config
                if plugin.config then
                    if not has_config then
                        add(string.format('" %s configuration', plugin_name))
                        has_config = true
                    end

                    local config_lines
                    if type(plugin.config) == 'function' then
                        config_lines = plugin.config()
                    else
                        config_lines = plugin.config
                    end

                    if config_lines then
                        for _, line in ipairs(config_lines) do
                            add(line)
                        end
                    end
                end

                if has_config then
                    add('')
                end
            end
        end
    end

    -- Bottom section from configuration
    if vimrc_config.bottom and #vimrc_config.bottom > 0 then
        add('" ============================================================================')
        add('" BOTTOM CONFIGURATION')
        add('" ============================================================================')
        add('')
        for _, line in ipairs(vimrc_config.bottom) do
            add(line)
        end
        add('')
    end

    -- Footer
    add('" ============================================================================')
    add('" AUTO-GENERATED CONTENT END')
    add('" ============================================================================')
    add('')
    add('" Add your custom vim configurations below this line')
    add('')

    return table.concat(lines, '\n')
end

-- Export function
function M.export_vimrc(filename)
    filename = filename or '.vimrc'

    local content = M.generate_vimrc_content()

    local file = io.open(filename, 'w')
    if not file then
        vim.notify('Error: Could not write to ' .. filename, vim.log.levels.ERROR)
        return false
    end

    file:write(content)
    file:close()

    local line_count = 0
    for _ in content:gmatch('\n') do
        line_count = line_count + 1
    end

    vim.notify(string.format('Exported .vimrc to %s (%d lines)', filename, line_count), vim.log.levels.INFO)
    return true
end

-- Create user command
vim.api.nvim_create_user_command('VimrcExport', function(opts)
    M.export_vimrc(opts.args ~= '' and opts.args or nil)
end, {
    nargs = '?',
    desc = 'Export current Neovim configuration to .vimrc',
    complete = 'file'
})

return M
