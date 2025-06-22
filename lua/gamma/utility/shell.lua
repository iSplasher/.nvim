local M = {}

---@class gamma.utility.shell_opts
---@field async? boolean Whether or not to execute the command asynchronously.
---@field cwd? string The current working directory to execute the command in.
---@field env? table The environment variables to execute the command with.
---@field timeout? number The timeout to execute the command with.
---@field input? string The input to execute the command with.
---@field text? boolean Whether or not to return the output as text. (default: true)
---@field verbose? boolean Print the command before executing it, and print the output.
---@field silent? boolean Do not print the output, or command.
---@field on_exit? function The function to execute when the command exits. (optional)

---A helper function to execute shell commands.
---@param cmd string[] @The command to execute.
---@param opts? gamma.utility.shell_opts The options to execute the command with.
---@return vim.SystemObj | vim.SystemCompleted
function M.shell(cmd, opts)
  local logging_utils = require('gamma.utility.logging')
  local table_utils = require('gamma.utility.table')
  
  opts = opts or {}
  
  local async = opts.async or false
  opts.async = nil
  local on_exit = opts.on_exit or nil
  opts.on_exit = nil
  if opts.text == nil then
    opts.text = true
  end
  local verbose = opts.verbose
  opts.silent = opts.silent
  if verbose then
    verbose = true
    opts.silent = false
    logging_utils.print(string.format("shell: %s", table.concat(cmd, " ")))
  end

  local function _on_exit(obj)
    if not opts.silent or opts.silent == nil then
      if obj.code == 0 then
        if verbose then
          logging_utils.print(obj.stdout)
          if obj.stderr and obj.stderr ~= "" then
            logging_utils.print(obj.stderr)
          end
        end
      else
        logging_utils.print_error(table_utils.print_table(obj))
      end
    end
    
    if on_exit then
      on_exit(obj)
    end
    return obj
  end

  ---@type vim.SystemOpts
  ---@diagnostic disable-next-line: assign-type-mismatch
  local _opts = opts
  if async then
    return vim.system(cmd, _opts, _on_exit)
  else
    return vim.system(cmd, _opts, _on_exit):wait()
  end
end

---Check if a command exists and is executable and returns its abspath
---@param cmd string @The command to check.
---@return string | nil @The absolute path to the command if it exists, otherwise nil.
function M.which(cmd)
  local p = vim.fn.resolve(vim.fn.exepath(cmd))
  if p ~= "" then
    return p
  else
    return nil
  end
end

return M