-- Change current working directory in a smart way.
local utility = require('gamma.utility')
local cmd = require('gamma.autocmd.cmd')

local M = {}

local markers = {
  -- Version control
  '.git', '.hg', '.svn', '.bzr',
  -- Project files
  'package.json', 'Cargo.toml', 'pyproject.toml', 'setup.py', 'requirements.txt',
  'go.mod', 'pom.xml', 'build.gradle', 'Makefile', 'CMakeLists.txt',
  -- Config files
  '.nvmrc', '.python-version', '.ruby-version', 'Dockerfile',
  -- IDE/Editor files
  '.vscode', '.idea', '.project'
}


-- Normalize path separators for cross-platform compatibility
local function normalize_path(path)
  if not path then return nil end
  -- Convert to forward slashes and resolve to absolute path
  local normalized = vim.loop.fs_realpath(path) or path
  normalized = vim.fn.fnamemodify(normalized, ':p')
  normalized = utility.normalize_path_sep(normalized)

  -- Remove trailing slash if present (except for root)
  if normalized:match('a/$') and #normalized > 1 then
    normalized = normalized:sub(1, -2)
  end
  return normalized
end

-- Find project root using various heuristics
local function find_project_root(start_path)
  local path = normalize_path(start_path)
  local root = normalize_path(vim.fn.fnamemodify('/', ':p'))
  local fallback_root, fallback_reason

  while path and path ~= root do
    -- Check for markers in current directory
    for _, marker in ipairs(markers) do
      local marker_path = path .. '/' .. marker
      local stat = vim.loop.fs_stat(marker_path)
      if stat then
        -- Prioritize git repos - return immediately
        if marker == '.git' then
          return path, 'git repository'
        end
        -- Store first non-git project marker as fallback
        if not fallback_root then
          fallback_root = path
          fallback_reason = marker .. ' project'
        end
      end
    end

    -- Move to parent directory
    local parent = vim.fn.fnamemodify(path, ':h')
    if parent == path then break end
    path = parent
  end

  -- Return fallback if no git repo found
  return fallback_root, fallback_reason
end
function M.auto_cwd()
  local bufname = vim.fn.bufname(vim.fn.bufnr('%'))
  if bufname == '' then
    -- If using Neovide and no valid buffer path, set to home directory
    if vim.g.neovide then
      local home_dir = vim.fn.expand('~')
      local current_cwd = vim.fn.getcwd()
      if home_dir ~= current_cwd then
        vim.api.nvim_set_current_dir(home_dir)
        vim.notify("Changed cwd to ~", vim.log.levels.INFO, {
          title = "Working Directory Changed",
          timeout = 2000,
          defer = 1000
        })
      end
    end
    return
  end

  local bufdir = normalize_path(vim.fn.fnamemodify(bufname, ':p:h')) or ""
  local current_cwd = normalize_path(vim.fn.getcwd())

  -- Check if file is inside Neovim config directory
  local config_dir = normalize_path(utility.config_path()) or ""
  if bufdir:find(config_dir, 1, true) == 1 then
    -- File is inside config directory - set to config root
    if config_dir ~= current_cwd then
      vim.api.nvim_set_current_dir(config_dir)
      utility.notify("Changed cwd to nvim config directory", vim.log.levels.INFO, {
        title = "Working Directory Changed",
        timeout = 2000,
        defer = 1000
      })
    end
    return
  end

  -- Skip if not the only file or if current buffer has no name
  local open_files = vim.fn.len(vim.fn.getbufinfo({ buflisted = 1 }))
  if open_files ~= 1 then
    utility.print_debug("Not changing cwd: multiple files open (" .. open_files .. ")")
    return
  end

  -- Try to find project root
  local project_root, reason = find_project_root(vim.fn.fnamemodify(bufname, ':p:h'))

  local target_dir
  local change_reason

  if project_root then
    target_dir = project_root
    change_reason = reason
  else
    -- Fallback to file directory
    target_dir = bufdir
    change_reason = 'current file directory'
  end

  -- Normalize target directory
  target_dir = normalize_path(target_dir) or ""

  -- Only change if different from current cwd
  if target_dir ~= current_cwd then
    vim.api.nvim_set_current_dir(target_dir)

    -- Show notification for project root changes
    if project_root then
      utility.notify("Changed cwd to " .. change_reason .. ": " .. target_dir, vim.log.levels.INFO, {
        title = "Working Directory Changed",
        timeout = 2000,
        defer = 1000
      })
    end
  end
end

function M.setup_autocmds()
  if vim.g.vscode then
    return
  end
  local g = vim.api.nvim_create_augroup("AutoWorkingDirectory", { clear = true })
  vim.api.nvim_create_autocmd(
    { "VimEnter" },
    {
      callback = function()
        M.auto_cwd()
      end,
      group = g,
      desc = "Automatically change working directory to project root or file directory"
    }
  )
end

cmd.add_cmd(M.setup_autocmds)

return M
