local function create_hightlight_groups()
    -- Create custom highlight groups

    -- CharacterHint
    vim.api.nvim_set_hl(0, "CharacterHint", { fg = "#BC556D", bold = false })
    vim.api.nvim_set_hl(0, "CharacterHintSecondary", { fg = "#CB88FF", bold = false })
    vim.api.nvim_set_hl(0, "CharacterHintDimmed", { fg = "#B55262", bold = false })
    vim.api.nvim_set_hl(0, "CharacterHintLabel", { fg = "#BC556D", bg = "#1b1b1b", bold = true })
end


if vim.g.colors_name then
    -- Set up autocommand to run after colorscheme loads
    vim.api.nvim_create_autocmd('ColorScheme', {
        callback = create_hightlight_groups,
        desc = 'Reload custom highlight groups after colorscheme loads'
    })

    --
    create_hightlight_groups()
end
