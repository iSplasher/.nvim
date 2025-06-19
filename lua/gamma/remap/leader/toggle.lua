local utility = require('gamma.utility')

local kmap = utility.kmap

-- Spell checking toggle
kmap("n", "<leader>ts", function()
    require("config.writing").toggle_spell()
end, "Toggle spell checking")

-- Toggle word wrapping
kmap('n', '<leader>tw', function()
    require("config.writing").toggle_wrap()
end, "Toggle word wrap")

-- Plugin manager for debugging
kmap('n', '<leader>?p', function()
    require('gamma.debug.plugin').show_plugin_manager()
end, "Plugin debugger")
