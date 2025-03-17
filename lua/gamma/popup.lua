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

---Create a floating window with content
---@param opts table: Options for the floating window
---@field opts.title string: Title for the floating window
---@field opts.content string?: Content for the floating window
---@field opts.path string?: Path to the file to load in the floating window
function M.floating_content(opts)
    local dim = get_window_dimensions()

    -- Create the buffer for the guide
    local buf = vim.api.nvim_create_buf(false, true)

    -- Set buffer options
    vim.api.nvim_set_option_value('filetype', 'markdown', { buf = buf })

    -- Window options
    local win_opts = {
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
    local win = vim.api.nvim_open_win(buf, true, win_opts)

    -- Set window options
    vim.api.nvim_set_option_value('winblend', 20, { win = win })
    vim.api.nvim_set_option_value('wrap', true, { win = win })
    vim.api.nvim_set_option_value('conceallevel', 0, { win = win })

    local content = {}

    if opts.content then
        content = vim.split(opts.content, '\n')
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

    -- Set the content in the buffer (make it modifiable first, then lock it again)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
    vim.api.nvim_set_option_value('modifiable', false, { buf = buf })

    -- Add keymaps for the guide window
    local function close_window()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end

    -- Add keymaps for closing the window
    local keymaps = {
        { 'n', 'q',     close_window, { nowait = true, buffer = buf } },
        { 'n', '<Esc>', close_window, { nowait = true, buffer = buf } },
    }

    for _, map in ipairs(keymaps) do
        vim.keymap.set(map[1], map[2], map[3], map[4])
    end

    -- Center on the beginning of the content
    vim.api.nvim_win_set_cursor(win, { 1, 0 })

    return { buf = buf, win = win }
end

return M
