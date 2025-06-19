local M = {}

M.group = vim.api.nvim_create_augroup("Spell Settings", { clear = true })

-- Filetypes where spell checking should be enabled
local spell_enabled_filetypes = {
    "markdown",
    "text",
    "gitcommit",
    "NeogitCommitMessage",
    "tex",
    "plaintex",
    "rst",
    "asciidoc",
    "org",
}

-- Filetypes where spell checking should be explicitly disabled
local spell_disabled_filetypes = {
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
}

-- Enable spell checking for specific filetypes
vim.api.nvim_create_autocmd("FileType", {
    group = M.group,
    pattern = spell_enabled_filetypes,
    callback = function()
        vim.opt_local.spell = true
        vim.opt_local.spelllang = "en_us"
    end,
    desc = "Enable spell checking for writing filetypes",
})

-- Disable spell checking for specific filetypes
vim.api.nvim_create_autocmd("FileType", {
    group = M.group,
    pattern = spell_disabled_filetypes,
    callback = function()
        vim.opt_local.spell = false
    end,
    desc = "Disable spell checking for UI and code filetypes",
})

-- Disable spell checking for floating windows (additional safety net)
vim.api.nvim_create_autocmd("WinEnter", {
    group = M.group,
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
    vim.opt_local.spell = not vim.opt_local.spell
    local status = vim.opt_local.spell and "enabled" or "disabled"
    vim.notify("Spell checking " .. status, vim.log.levels.INFO)
end

-- Function to add filetypes to spell enabled list
function M.add_spell_filetype(filetype)
    table.insert(spell_enabled_filetypes, filetype)
    vim.notify("Added " .. filetype .. " to spell enabled filetypes", vim.log.levels.INFO)
end

-- Function to add filetypes to spell disabled list
function M.add_no_spell_filetype(filetype)
    table.insert(spell_disabled_filetypes, filetype)
    vim.notify("Added " .. filetype .. " to spell disabled filetypes", vim.log.levels.INFO)
end

return M
