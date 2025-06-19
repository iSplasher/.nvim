local function is_active_colorscheme(plugin)
    -- Extract potential colorscheme names
    local url_name = plugin.url:match("([^/]+)%.?n?vim$") or plugin.url:match("([^/]+)$")
    local explicit_name = plugin.name

    return vim.g.colors_name == explicit_name or
        vim.g.colors_name == url_name or
        vim.g.colors_name == url_name:gsub("%.nvim$", "")
end

local function is_not_active_colorscheme(plugin)
    return not is_active_colorscheme(plugin)
end
-- theme
return {
    {
        'sainnhe/gruvbox-material',
        lazy = is_not_active_colorscheme,
        priority = 1000,
        config = function()
            -- Optionally configure and load the colorscheme
            -- directly inside the plugin declaration.
            vim.g.gruvbox_material_enable_italic = true
            vim.g.gruvbox_material_foreground = 'material' -- 'material', 'mix', 'original'
            vim.g.gruvbox_material_background = 'medium'   -- or 'soft', 'hard', 'medium'
            -- If you want more ui components to be transparent (for example, status line
            -- background), set this option to `2`.
            vim.g.gruvbox_material_transparent_background = 2 -- 0, 1, or 2, default is 0
            vim.g.gruvbox_material_enable_bold = 1
            vim.g.airline_theme = 'gruvbox_material'
            vim.g.gruvbox_material_menu_selection_background = 'aqua'
            -- vim.g.gruvbox_material_sign_column_background = 'grey'
            vim.g.gruvbox_material_ui_contrast = 'high'
            vim.g.gruvbox_material_inlay_hints_background = 'dimmed'
        end
    },
    {
        'marko-cerovac/material.nvim',
        name = 'material',
        lazy = is_not_active_colorscheme,
        priority = 1000,
    },

    {
        'sainnhe/sonokai',
        name = 'sonokai',
        lazy = is_not_active_colorscheme,
        priority = 1000,
    },

    {
        'elianiva/gruvy.nvim',
        name = 'gruvy',
        lazy = is_not_active_colorscheme,
        priority = 1000,
        dependencies = { { 'rktjmp/lush.nvim' } },
    },
}
