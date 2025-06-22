local utility = require('gamma.utility')
local kmap = utility.kmap
-- Advanced guide floating window
local M = {}

-- Get dimensions for the floating window
local function get_window_dimensions()
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)
    return { width = width, height = height, row = row, col = col }
end

---@class gamma.popup.FloatingContentReturn
---@field buf number Buffer number of the floating window
---@field win number Window number of the floating window
---@class gamma.popup.FloatingContentBufferOpts
---@field filetype? string Filetype to set for the buffer (defaults to markdown)
---@field spell? boolean Whether to enable spell checking in the buffer (defaults to false)
---@class gamma.popup.FloatingContentOpts
---@field title string Title for the floating window
---@field content? string|string[] Content for the floating window
---@field path? string Path to the file to load in the floating window
---@field keymaps? gamma.utility.kmap_opts[]|fun(popup_opts: gamma.popup.FloatingContentReturn):gamma.utility.kmap_opts[] Keymaps to set for the floating window buffer
---@param opts gamma.popup.FloatingContentOpts Options for the floating window
---@param buffer_opts? gamma.popup.FloatingContentBufferOpts Additional options for the buffer
---@param win_opts? vim.api.keyset.win_config Window options for the floating window
---Create a floating window with content
function M.floating_content(opts, buffer_opts, win_opts)
    local dim = get_window_dimensions()

    -- Create the buffer for the guide
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value('buftype', 'nofile', { buf = buf })

    -- Determine filetype based on file extension or explicit option
    local buf_opts = buffer_opts or {}
    buf_opts.filetype = buf_opts.filetype or 'markdown'
    if opts.path and opts.path:match('%.txt$') then
        buf_opts.filetype = 'help'
    end

    -- Window options
    local default_win_opts = {
        relative = 'editor',
        width = dim.width,
        height = dim.height,
        row = dim.row,
        col = dim.col,
        style = 'minimal',
        border = 'rounded',
        title = string.format(' %s ', opts.title),
        title_pos = 'center',
    }

    local active_win_opts = utility.merge_table(default_win_opts, win_opts or {})
    -- Try and use the snacks win library first, if not, fall back to manual
    -- Snacks.win({
    --   file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
    --   width = 0.6,
    --   height = 0.6,
    --   wo = {
    --     spell = false,
    --     wrap = false,
    --     signcolumn = "yes",
    --     statuscolumn = " ",
    --     conceallevel = 3,
    --   },
    -- })
    --

    -- Create the window
    local win = vim.api.nvim_open_win(buf, true, active_win_opts)

    -- Set window options based on filetype
    vim.api.nvim_set_option_value('winblend', 20, { win = win })
    if buf_opts.filetype == 'help' then
        vim.api.nvim_set_option_value('wrap', false, { win = win })
        vim.api.nvim_set_option_value('conceallevel', 0, { win = win })
        vim.api.nvim_set_option_value('signcolumn', 'no', { win = win })
        vim.api.nvim_set_option_value('number', false, { win = win })
        vim.api.nvim_set_option_value('relativenumber', false, { win = win })
    else
        vim.api.nvim_set_option_value('wrap', true, { win = win })
        vim.api.nvim_set_option_value('conceallevel', 0, { win = win })
    end

    ---@type string[]
    local content = {}
    if opts.content then
        if type(opts.content) == 'string' then
            ---@diagnostic disable-next-line: param-type-mismatch
            content = vim.split(opts.content, '\n')
        else
            ---@diagnostic disable-next-line: cast-local-type
            content = opts.content
        end
    elseif opts.path then
        -- Load the file content
        if vim.fn.filereadable(opts.path) == 1 then
            local file = io.open(opts.path, "r")
            if file then
                local i = 1
                for line in file:lines() do
                    content[i] = line
                    i = i + 1
                end
                file:close()
            end
        else
            content = { "# File not found", "", "Please generate the file first at:", opts.path }
        end
    end

    -- Set buffer options
    local modifiable = false
    local swapfile = false
    for k, v in pairs(buf_opts) do
        if k == 'modifiable' then
            modifiable = v
        elseif k == 'swapfile' then
            swapfile = v
        else
            vim.api.nvim_set_option_value(k, v, { buf = buf })
        end
    end

    vim.api.nvim_set_option_value('swapfile', swapfile, { buf = buf })

    -- Set the content in the buffer (make it modifiable first)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
    vim.api.nvim_set_option_value('modifiable', modifiable, { buf = buf })

    -- Add keymaps for the guide window
    local function close_window()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end

    -- Add keymaps for closing the window and navigation
    local keymaps = {
        { 'n', 'q',     close_window, "Close window", { nowait = true, noremap = true } },
        { 'n', '<Esc>', close_window, "Close window", { nowait = true, noremap = true } },
    }

    local keymaps_arg = function()
        if type(opts.keymaps) == 'function' then
            return opts.keymaps({ buf = buf, win = win })
        end
        ---@type gamma.utility.kmap_opts[]
        ---@diagnostic disable-next-line: assign-type-mismatch
        local o = opts.keymaps or {}
        return o
    end
    for _, map in ipairs(keymaps_arg()) do
        table.insert(keymaps, map)
    end
    -- Add help-specific keymaps if this is a help file
    if buf_opts.filetype == 'help' then
        local help_keymaps = {
            { 'n', '<C-]>', function()
                -- Jump to tag under cursor
                local word = vim.fn.expand('<cWORD>')
                local tag = word:match('|([^|]+)|') or word:match('%*([^*]+)%*')
                if tag then
                    local line_num = nil
                    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
                    for i, line in ipairs(lines) do
                        if line:match('%*' .. vim.pesc(tag) .. '%*') then
                            line_num = i
                            break
                        end
                    end
                    if line_num then
                        vim.api.nvim_win_set_cursor(win, { line_num, 0 })
                        vim.cmd('normal! zz')
                    else
                        vim.notify("Tag not found: " .. tag, vim.log.levels.WARN)
                    end
                end
            end, "Jump to tag", { nowait = true } },
            
            { 'n', '<C-t>', function()
                -- Go back to table of contents
                local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
                for i, line in ipairs(lines) do
                    if line:match('TABLE OF CONTENTS') then
                        vim.api.nvim_win_set_cursor(win, { i, 0 })
                        vim.cmd('normal! zz')
                        break
                    end
                end
            end, "Jump to table of contents", { nowait = true } },
            
            { 'n', 'gd', function()
                -- Jump to section definition
                local word = vim.fn.expand('<cWORD>')
                local section = word:match('|([^|]+)|')
                if section then
                    local line_num = nil
                    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
                    for i, line in ipairs(lines) do
                        if line:match('%*' .. vim.pesc(section) .. '%*') then
                            line_num = i
                            break
                        end
                    end
                    if line_num then
                        vim.api.nvim_win_set_cursor(win, { line_num, 0 })
                        vim.cmd('normal! zz')
                    end
                end
            end, "Go to section definition", { nowait = true } },
            
            { 'n', 'n', function()
                vim.cmd('normal! n')
                vim.cmd('normal! zz')
            end, "Next search result", { nowait = true } },
            
            { 'n', 'N', function()
                vim.cmd('normal! N')
                vim.cmd('normal! zz')
            end, "Previous search result", { nowait = true } },
        }
        
        for _, map in ipairs(help_keymaps) do
            table.insert(keymaps, map)
        end
    end

    for _, map in ipairs(keymaps) do
        local kopts = map[5]
        if kopts == nil then
            if type(map[4]) == 'table' then
                kopts = map[4]
            else
                kopts = {}
            end
        end

        if kopts.buffer == nil then
            kopts.buffer = buf
        end

        if kopts.remap == nil and kopts.noremap == nil then
            kopts.remap = true
        end

        kmap(map[1], map[2], map[3], map[4], kopts)
    end

    -- Center on the beginning of the content
    vim.api.nvim_win_set_cursor(win, { 1, 0 })

    return { buf = buf, win = win }
end

return M
