local ui_buftypes = {
    "startify",
    "dashboard",
    "neo-tree",
    "qf",
    "netrw",
    "NvimTree",
    "oil",
    "lazy",
    "mason",
    "terminal",
    "Neogit",
    "mason",
    "fugitive",
    "TelescopePrompt",
    "noice",
    "Trouble",
    "trouble",
    "undotree",
    "TelescopeResults",
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

local auxiliary_buftypes = {
    "lspinfo",
    "log",
    "Diffview.*",
    table.unpack(ui_buftypes),
}

local lsp_disabled_buftypes = {
    table.unpack(ui_buftypes),
    table.unpack(auxiliary_buftypes),
}

local equivalence_classes = {
    ' \t\r\n',
    '([{<',
    ')]}>',
    '\'"`',
}

local M = {
    ui_buftypes = ui_buftypes,
    auxiliary_buftypes = auxiliary_buftypes,
    lsp_disabled_buftypes = lsp_disabled_buftypes,
    equivalence_classes = equivalence_classes,
}

return M
