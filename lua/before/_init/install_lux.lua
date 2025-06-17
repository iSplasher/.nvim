require('compat')
local lux = require('config.lux')

if not vim.g.is_remote then
    lux.setup()
end
