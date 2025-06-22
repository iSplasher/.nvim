local ui_filetypes = {
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
}

local auxiliary_filetypes = {
    "lspinfo",
    "log",
    "Diffview.*",
    table.unpack(ui_filetypes),
}


local equivalence_classes = {
    ' \t\r\n',
    '([{<',
    ')]}>',
    '\'"`',
}
local M = {
    ui_filetypes = ui_filetypes,
    auxiliary_filetypes = auxiliary_filetypes,
    equivalence_classes = equivalence_classes,
}

return M
