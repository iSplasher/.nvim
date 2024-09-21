-- install lazy.nvim if not already installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local vscode = require('gamma/vscode')
local utility = require('gamma/utility')
utility.require_dir("before/plugin", true, true)

require('lazy').setup("plugins", {
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    enabled = true,
    notify = vim.g.vscode == nil
  },
  defaults = {
    version = "*", -- by default, only install stable versions
    cond = function(plugin)
      -- When running in VSCode
      if vim.g.vscode then
        for _, name in ipairs(vscode.enabled) do
          if plugin.name == name then
            return true
          end
        end

        return false
      end
      return true
    end
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "matchit",
      },  
    },
  },
})
