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
    cond = function(plugin)
      if vim.g.vscode then
        -- list of plugin names that should not be disabled in vscode
        local whitelist = {
          "kevinhwang91/nvim-hlslens",
          "tpope/vim-sleuth",
          -- colorschemes
          'gruvy',
          'rktjmp/lush.nvim',
          'lush.nvim',
        }
        for _, name in ipairs(whitelist) do
          if plugin.name == name then
            return true
          end
        end

        return false
      end
      return true
    end
  }
})
