local cmd = require('gamma.autocmd.cmd')
local utility = require('gamma.utility')
local M = {}

function M.setup_autocmds()
  -- Skip in VSCode
  if vim.g.vscode then
    return
  end

  local augroup = vim.api.nvim_create_augroup('ConfigWatch', { clear = true })

  vim.api.nvim_create_autocmd('BufWritePost', {
    group = augroup,
    pattern = {
      utility.config_path() .. '/lua/**/*.lua',
      utility.config_path() .. '/local-plugins/**/*.lua',
      utility.config_path() .. '/init.lua',
    },
    callback = function()
      -- Prompt user for reload vs restart
      local choice = vim.fn.confirm('Config changed. Choose action:', '&Reload\n&Restart\n&Nothing', 1)

      if choice == 1 then
        vim.notify('Reloading config...', vim.log.levels.INFO)

        -- Clear module cache
        for name, _ in pairs(package.loaded) do
          if name:match('^gamma') or name:match('^plugins') then
            package.loaded[name] = nil
          end
        end

        dofile(utility.config_path() .. '/init.lua')
        vim.notify('Config reloaded! (Consider restart if issues occur)', vim.log.levels.WARN)
      elseif choice == 2 then
        vim.notify('Restarting Neovim...', vim.log.levels.INFO)
        vim.cmd('qa')
      end
    end,
  })
end

cmd.add_cmd(M.setup_autocmds)
return M
