local M = {
    spell_group = vim.api.nvim_create_augroup("Spell Settings", { clear = true }),
    writing_group = vim.api.nvim_create_augroup("Writing Settings", { clear = false }),
    wrap_group = vim.api.nvim_create_augroup("Wrap Settings", { clear = false }),
    filetypes = { 'markdown', 'text', 'rst', 'tex', 'asciidoc', 'typst' },
    -- Filetypes where spell checking should be enabled
    spell_enabled_filetypes = {
        "markdown",
        "text",
        "gitcommit",
        "NeogitCommitMessage",
        "tex",
        "plaintex",
        "rst",
        "asciidoc",
        "org",
    },

    -- Filetypes where spell checking should be explicitly disabled
    spell_disabled_filetypes = {
        "help",
        "WhichKey",
        "TelescopePrompt",
        "TelescopeResults",
        "mason",
        "lazy",
        "lspinfo",
        "toggleterm",
        "startuptime",
        "checkhealth",
        "man",
        "notify",
        "nofile",
        "quickfix",
        "notify",
        "prompt",
        "popup",
        "NvimTree",
        "neo-tree",
        "Trouble",
        "alpha",
        "dashboard",
        "oil",
        "fugitive",
        "git",
        "diff",
    },
}



--- Toggle options for the current buffer
---@param on_opt string
---@param off_opt string
---@param label string
local function toggle_option(on_opt, off_opt, label)
    local current = vim.opt_local[on_opt]:get()
    vim.cmd('setlocal ' .. (current and off_opt or on_opt))
    local status = not current and "enabled" or "disabled"
    vim.notify(label .. " " .. status, vim.log.levels.INFO)
end

if not vim.g.vscode then
    -- Auto enable Pencil plugin for certain filetypes
    vim.api.nvim_create_autocmd("BufEnter", {
        group = M.writing_group,
        pattern = M.filetypes,
        callback = function()
            if vim.fn.exists(':Pencil') == 2 then
                vim.cmd('Pencil')
            end
        end,
        desc = "Enable Pencil plugin for writing filetypes",
    })

    -- Set custom wrap settings for specific filetypes

    vim.api.nvim_create_autocmd("FileType", {
        -- M.filetypes + {'help'}
        pattern = vim.list_extend(M.filetypes, { "help" }),
        group = M.wrap_group,
        command = 'setlocal wrap'
    })

    M.toggle_wrap = function()
        toggle_option("wrap", "nowrap", "Wrap")
    end

    -- Enable spell checking for specific filetypes
    vim.api.nvim_create_autocmd("FileType", {
        group = M.spell_group,
        pattern = M.spell_enabled_filetypes,
        callback = function()
            vim.opt_local.spell = true
            vim.opt_local.spelllang = "en_us"
        end,
        desc = "Enable spell checking for writing filetypes",
    })

    -- Disable spell checking for specific filetypes
    vim.api.nvim_create_autocmd("FileType", {
        group = M.spell_group,
        pattern = M.spell_disabled_filetypes,
        callback = function()
            vim.opt_local.spell = false
        end,
        desc = "Disable spell checking for UI and code filetypes",
    })

    -- Disable spell checking for floating windows (additional safety net)
    vim.api.nvim_create_autocmd("WinEnter", {
        group = M.spell_group,
        callback = function()
            local win_config = vim.api.nvim_win_get_config(0)
            if win_config.relative ~= "" then
                -- This is a floating window
                vim.opt_local.spell = false
            end
        end,
        desc = "Disable spell checking in floating windows",
    })

    -- Function to manually toggle spell checking
    function M.toggle_spell()
        toggle_option("spell", "nospell", "Spell checking")
    end

    -- Function to add filetypes to spell enabled list
    function M.add_spell_filetype(filetype)
        table.insert(M.spell_enabled_filetypes, filetype)
        vim.notify("Added " .. filetype .. " to spell enabled filetypes", vim.log.levels.INFO)
    end

    -- Function to add filetypes to spell disabled list
    function M.add_no_spell_filetype(filetype)
        table.insert(M.spell_disabled_filetypes, filetype)
        vim.notify("Added " .. filetype .. " to spell disabled filetypes", vim.log.levels.INFO)
    end
end

return M
