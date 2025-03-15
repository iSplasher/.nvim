local utility = require('gamma.utility')
local kmap = utility.kmap

return {
  -- Session
  {
    'Shatur/neovim-session-manager',
    dependencies = {
      'nvim-lua/plenary.nvim'
    },
    init = function()
      -- choose what to save in session
      vim.g.sessionoptions = 'fold,resize,tabpages,winsize,resize,terminal'
    end,
    config = function()
      local cfg = require('session_manager.config')
      local Path = require('plenary.path')


      local path_replacer = '__'
      local colon_replacer = '++'

      --- Replaces symbols into separators and colons to transform filename into a session directory.
      local function session_filename_to_dir(filename)
        -- Get session filename.
        local dir = filename:sub(#tostring(cfg.sessions_dir) + 2)

        dir = dir:gsub(colon_replacer, ':')
        dir = dir:gsub(path_replacer, '/')
        dir = dir:gsub(path_replacer, '\\')
        return Path:new(dir)
      end

      --- Replaces separators and colons into special symbols to transform session directory into a filename.
      local function dir_to_session_filename(dir)
        local filename = dir:gsub(':', colon_replacer)
        filename = filename:gsub(Path.path.sep, path_replacer)
        return Path:new(cfg.sessions_dir):joinpath(filename)
      end

      require('session_manager').setup {
        dir_to_session_filename = dir_to_session_filename,
        session_filename_to_dir = session_filename_to_dir,
        autoload_mode = { cfg.AutoloadMode.GitSession, cfg.AutoloadMode.LastSession },
        autosave_last_session = true,
        autosave_ignore_not_normal = true, -- Plugin will not save a session when no buffers are opened, or all of them aren't writable or listed.
        autosave_ignore_dirs = {
          "D:/TEMP",
          "D:\\TEMP",
          "X:\\TEMP",
          "X:/TEMP",
          "C:/TEMP",
          "C:\\TEMP",
          "C:/WINDOWS",
          "C:\\WINDOWS",
          'C:/Program Files',
          'C:\\Program Files',
          vim.fn.stdpath('data'),
          vim.fn.stdpath('cache'),
        },
        autosave_ignore_filetypes = {
          'git',
          'gitcommit',
          'help',
          'gitrebase'
        },
        autosave_ignore_buftypes = {},
        autosave_only_in_session = false,
      }


      local config_group = vim.api.nvim_create_augroup('Session Settings', {}) -- A global group for all your config autocommands

      -- Session load
      vim.api.nvim_create_autocmd({ 'User' }, {
        pattern = "SessionLoadPost",
        group = config_group,
        callback = function()
          pcall(function()
            require('nvim-tree').toggle(false, true)
          end)
        end,
      })

      -- Save session on save buffer
      -- vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
      --  group = config_group,
      --  callback = function()
      --   local session_manager = require('session_manager')
      --    if vim.bo.filetype ~= 'git'
      --        and not vim.bo.filetype ~= 'gitcommit'
      --    then
      --      session_manager.autosave_session()
      --    end
      --  end
      --})
    end
  },
}
