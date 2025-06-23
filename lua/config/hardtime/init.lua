local base = require('config.hardtime.base')
local restricted = require('config.hardtime.restricted')
local disabled = require('config.hardtime.disabled')
local hints = require('config.hardtime.hints')

local M = {
    -- Complete the configuration
    opts = vim.tbl_extend('keep', base.opts, restricted, disabled, hints)
}

return M
