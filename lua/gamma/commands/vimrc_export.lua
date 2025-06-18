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

-- Extract keymap mode+key combinations from remap files using Python
local function get_custom_keymap_list()
    local python = require('config.python')
    local utility = require('gamma.utility')

    -- Python script to extract just mode and keys from kmap calls
    local python_script = [[
import os
import re
import json
import glob

def extract_kmap_keys(file_path):
    """Extract mode, keys and descriptions from kmap function calls"""
    keymap_keys = []

    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Pattern to extract mode, keys, description, and position
        pattern = r'kmap\s*\(\s*["\']([^"\']+)["\']\s*,\s*["\']([^"\']+)["\']\s*,\s*[^,]+\s*(?:,\s*["\']([^"\']*)["\'])?'

        # Find matches with line numbers
        lines = content.split('\n')
        for line_num, line in enumerate(lines, 1):
            # Skip commented lines
            stripped_line = line.strip()
            if stripped_line.startswith('--') or stripped_line.startswith('#'):
                continue

            matches = re.findall(pattern, line)
            for match in matches:
                mode, keys, desc = match
                # Get relative path from config root
                rel_path = os.path.relpath(file_path, config_path)
                keymap_keys.append({
                    'mode': mode,
                    'keys': keys,
                    'desc': desc or '',
                    'file': rel_path,
                    'line': line_num
                })

    except Exception as e:
        print(f"Error parsing {file_path}: {e}")

    return keymap_keys

config_path = os.getcwd()
remap_path = os.path.join(config_path, 'lua', 'gamma', 'remap')

all_keys = []

# Find all Lua files in remap directory recursively
lua_files = glob.glob(os.path.join(remap_path, '**', '*.lua'), recursive=True)

for file_path in lua_files:
    keys = extract_kmap_keys(file_path)
    all_keys.extend(keys)

# Output as JSON
print(json.dumps(all_keys, indent=2))
]]


    -- Run Python script
    local result = python.run({ '-c', python_script }, { silent = true })

    if result.code ~= 0 then
        vim.notify('Error running Python keymap parser: ' .. (result.stderr or ''), vim.log.levels.ERROR)
        return {}
    end

    -- Parse JSON output
    local ok, keymap_keys = pcall(vim.json.decode, result.stdout)
    if not ok then
        vim.notify('Error parsing keymap JSON: ' .. result.stdout, vim.log.levels.ERROR)
        return {}
    end

    return keymap_keys or {}
end

-- Get current keymaps that match our custom keymap list
local function get_matching_keymaps()
    local custom_keys = get_custom_keymap_list()
    local keymaps = {}
    local modes = { 'n', 'i', 'v', 'x', 'o', 'c' }

    -- Create lookup table for custom keys
    local custom_lookup = {}
    for _, custom in ipairs(custom_keys) do
        local key = custom.mode .. ':' .. custom.keys
        custom_lookup[key] = {
            file = custom.file,
            desc = custom.desc or '',
            line = custom.line
        }
    end

    -- First pass: try to match with live session keymaps (nvim_get_keymap)
    local matched_keys = {}
    local found_count = 0
    for _, mode in ipairs(modes) do
        local mode_maps = vim.api.nvim_get_keymap(mode)
        for _, map in ipairs(mode_maps) do
            -- Check if this keymap matches one from our custom files
            local lookup_key = mode .. ':' .. (map.lhs or '')
            if custom_lookup[lookup_key] then
                found_count = found_count + 1
                matched_keys[lookup_key] = true
                local custom_info = custom_lookup[lookup_key]
                table.insert(keymaps, {
                    mode = mode,
                    lhs = map.lhs,
                    rhs = map.rhs or '',
                    desc = map.desc or custom_info.desc or '',
                    noremap = map.noremap == 1,
                    silent = map.silent == 1,
                    file = custom_info.file
                })
            end
        end
    end

    -- Second pass: try to match with saved_maps from utility
    local utility = require('gamma.utility')
    local saved_maps = utility.get_saved_maps()

    for _, saved_map in ipairs(saved_maps) do
        -- Handle mode being a table or string
        local modes_to_check = {}
        if type(saved_map.mode) == 'table' then
            modes_to_check = saved_map.mode
        else
            modes_to_check = { saved_map.mode }
        end

        for _, mode in ipairs(modes_to_check) do
            local lookup_key = mode .. ':' .. saved_map.keys
            if custom_lookup[lookup_key] and not matched_keys[lookup_key] then
                found_count = found_count + 1
                matched_keys[lookup_key] = true
                local custom_info = custom_lookup[lookup_key]

                -- Convert saved_map.map to string if it's a function
                local rhs = saved_map.map
                if type(rhs) == 'function' then
                    -- Try to find a substitution for this function
                    local function_info = debug.getinfo(rhs, 'S')
                    local function_str = tostring(rhs)
                    local substitution = nil

                    -- Get the function source if available
                    local source_lines = {}
                    if function_info and function_info.source and function_info.source:match("^@") then
                        local file_path = function_info.source:sub(2)
                        if vim.fn.filereadable(file_path) == 1 then
                            local lines = vim.fn.readfile(file_path)
                            if function_info.linedefined and function_info.lastlinedefined then
                                for i = function_info.linedefined, function_info.lastlinedefined do
                                    if lines[i] then
                                        table.insert(source_lines, lines[i])
                                    end
                                end
                            end
                        end
                    end

                    local combined_text = function_str .. " " .. table.concat(source_lines, " ")

                    -- Check substitutions against function content
                    for pattern, replacement in pairs(vimrc_config.substitutions) do
                        if combined_text:find(pattern, 1, true) or combined_text:match(pattern) then
                            substitution = replacement
                            break
                        end
                    end

                    if substitution then
                        rhs = substitution
                    else
                        -- Skip function mappings that can't be substituted
                        goto continue
                    end
                end

                table.insert(keymaps, {
                    mode = mode,
                    lhs = saved_map.keys,
                    rhs = rhs,
                    desc = saved_map.desc or custom_info.desc or '',
                    noremap = true, -- Most custom maps are noremap
                    silent = false,
                    file = custom_info.file
                })

                ::continue::
            end
        end
    end

    -- Third pass: add any custom keymaps that still weren't matched (fallback with placeholder)
    for lookup_key, custom_info in pairs(custom_lookup) do
        if not matched_keys[lookup_key] then
            -- Check if this mapping should be excluded
            if not vimrc_config.exclude_mappings[lookup_key] then
                local mode, keys = lookup_key:match("^([^:]+):(.+)$")
                if mode and keys then
                    local line_info = custom_info.line and (':' .. custom_info.line) or ''
                    table.insert(keymaps, {
                        mode = mode,
                        lhs = keys,
                        rhs = '<cmd>echo "Custom keymap from ' .. custom_info.file .. line_info .. '"<CR>',
                        desc = custom_info.desc or '',
                        noremap = true,
                        silent = false,
                        file = custom_info.file,
                        line = custom_info.line
                    })
                end
            end
        end
    end

    -- Debug output
    local total_custom = 0
    for _ in pairs(custom_lookup) do
        total_custom = total_custom + 1
    end
    vim.notify(
    string.format('Matched %d/%d custom keymaps (from nvim_get_keymap + saved_maps)', found_count, total_custom),
        vim.log.levels.INFO)
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
        -- Handle arrays (with compatibility fallback)
        local is_array = vim.isarray and vim.isarray(value) or
            (type(value) == 'table' and #value > 0 and value[1] ~= nil)
        if is_array then
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
        local is_array = vim.isarray and vim.isarray(value) or
            (type(value) == 'table' and #value > 0 and value[1] ~= nil)
        if name == 'completeopt' and is_array then
            return string.format('set %s=%s', name, table.concat(value, ','))
        elseif name == 'clipboard' and is_array then
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
-- Convert keymap to vimscript with comment above
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

    local lines = {}

    -- Add comment above if description exists
    if map.desc and map.desc ~= '' then
        table.insert(lines, '" ' .. map.desc)
    end

    -- Add the mapping itself
    local rhs = map.rhs or ''
    if rhs == '' then
        -- Check if this should be a <nop> mapping (disable default behavior)
        -- Look for common disable patterns in substitutions
        local found_nop = false
        for pattern, replacement in pairs(vimrc_config.substitutions) do
            if replacement == '<nop>' then
                found_nop = true
                break
            end
        end

        if found_nop then
            -- This is likely meant to be a disable mapping
            rhs = '<nop>'
        else
            -- Skip truly incomplete mappings
            return {}
        end
    end
    table.insert(lines, string.format('%s%s %s %s', cmd, flags, map.lhs, rhs))

    return lines
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
    add('" KEYMAPS (from remap files)')
    add('" ============================================================================')
    add('')

    local keymaps = get_matching_keymaps()

    -- Group keymaps by file
    local files_keymaps = {}
    for _, map in ipairs(keymaps) do
        local file = map.file or 'unknown'
        if not files_keymaps[file] then
            files_keymaps[file] = {}
        end
        table.insert(files_keymaps[file], map)
    end

    -- Sort files alphabetically
    local sorted_files = {}
    for file, _ in pairs(files_keymaps) do
        table.insert(sorted_files, file)
    end
    table.sort(sorted_files)

    -- Output keymaps grouped by file
    for _, file in ipairs(sorted_files) do
        local maps = files_keymaps[file]
        if #maps > 0 then
            -- Derive category from filename
            local category = file:match("([^/]+)%.lua$") or file
            category = category:gsub("^(.)", string.upper) -- Capitalize first letter

            add(string.format('" %s (%s)', category, file))

            for _, map in ipairs(maps) do
                local keymap_lines = keymap_to_vimscript(map)
                for _, line in ipairs(keymap_lines) do
                    add(line)
                end
            end
            add('')
        end
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
                local plugin_name = plugin[1] or plugin.name

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
                local plugin_name = plugin[1] or plugin.name
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
                        ---@type string[]
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

-- Analyze placeholder mappings and suggest improvements
local function analyze_placeholder_mappings(content)
    local improvements = {
        substitutions = {},
        exclusions = {}
    }

    -- Find all placeholder mappings with file:line info
    for line in content:gmatch('[^\n]+') do
        local mapping = line:match('<cmd>echo "Custom keymap from ([^"]+)"<CR>')
        if mapping then
            local file_path, line_num = mapping:match('([^:]+):?(%d*)')
            if file_path and line_num ~= '' then
                line_num = tonumber(line_num)

                -- Read the source file and analyze the function at that line
                local full_path = vim.fn.fnamemodify(
                vimrc_config.top and vim.fn.getcwd() .. '/' .. file_path or file_path, ':p')
                if vim.fn.filereadable(full_path) == 1 then
                    local lines = vim.fn.readfile(full_path)
                    if lines[line_num] then
                        local source_line = lines[line_num]

                        -- Extract the keymap definition
                        local mode, keys, func = source_line:match(
                        'kmap%s*%(%s*["\']([^"\']+)["\']%s*,%s*["\']([^"\']+)["\']%s*,%s*([^,]+)')
                        if mode and keys and func then
                            local lookup_key = mode .. ':' .. keys

                            -- Analyze the function
                            if func:match('create_cmd') then
                                -- Simple command wrapper
                                local cmd = func:match('create_cmd%(["\']([^"\']+)["\']%)')
                                if cmd then
                                    improvements.substitutions[lookup_key] = {
                                        pattern = 'create_cmd%(["\']' .. cmd .. '["\']%)',
                                        replacement = '<cmd>' .. cmd .. '<CR>',
                                        confidence = 'high'
                                    }
                                end
                            elseif func:match('vim%.cmd%.') then
                                -- Vim command
                                local cmd = func:match('vim%.cmd%.([%w_]+)')
                                if cmd then
                                    improvements.substitutions[lookup_key] = {
                                        pattern = 'vim%.cmd%.' .. cmd,
                                        replacement = ':' .. cmd .. '<CR>',
                                        confidence = 'medium'
                                    }
                                end
                            elseif func:match('function%s*%(%s*%)') or func:match('=>') then
                                -- Complex function - suggest exclusion if it's very complex
                                local complexity = 0
                                -- Check following lines for function body
                                for i = line_num + 1, math.min(line_num + 10, #lines) do
                                    if lines[i] and (lines[i]:match('if ') or lines[i]:match('for ') or lines[i]:match('while ')) then
                                        complexity = complexity + 1
                                    end
                                    if lines[i] and lines[i]:match('end') then
                                        break
                                    end
                                end

                                if complexity > 2 then
                                    improvements.exclusions[lookup_key] = {
                                        reason = 'Complex function with ' .. complexity .. ' control structures',
                                        confidence = 'high'
                                    }
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return improvements
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

    -- Analyze placeholder mappings and suggest improvements
    local improvements = analyze_placeholder_mappings(content)

    if next(improvements.substitutions) or next(improvements.exclusions) then
        vim.notify('Found placeholder mappings that could be improved:', vim.log.levels.INFO)

        if next(improvements.substitutions) then
            vim.notify('Suggested substitutions:', vim.log.levels.INFO)
            for key, info in pairs(improvements.substitutions) do
                vim.notify(
                string.format('  %s: %s -> %s (%s confidence)', key, info.pattern, info.replacement, info.confidence),
                    vim.log.levels.INFO)
            end
        end

        if next(improvements.exclusions) then
            vim.notify('Suggested exclusions:', vim.log.levels.INFO)
            for key, info in pairs(improvements.exclusions) do
                vim.notify(string.format('  %s: %s (%s confidence)', key, info.reason, info.confidence),
                    vim.log.levels.INFO)
            end
        end

        vim.notify('Add these to lua/config/context/vimrc.lua substitutions or exclude_mappings table',
            vim.log.levels.INFO)
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
