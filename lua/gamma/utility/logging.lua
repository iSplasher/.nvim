local M = {}

M._print = vim.schedule_wrap(function(obj, endstr, level)
  endstr = endstr or "\n"
  local msg = vim.inspect(obj) .. endstr
  local p = print
  if level == vim.log.levels.ERROR then
    p = error
  elseif level == vim.log.levels.WARN then
    msg = "WARN: " .. msg
  elseif level == vim.log.levels.DEBUG then
    msg = "DEBUG: " .. msg
  end
  if vim.g.vscode then
    p(msg)
  else
    local ok, _ = pcall(vim.notify, msg, level)
    if not ok then
      -- Fallback to print if notify fails
      p(msg)
    end
  end
end)

---A helper function to print something to the console.
---@param obj any @The object to print.
---@param endstr? string The string to print at the end. (default: "\n")
function M.print(obj, endstr)
  M._print(obj, endstr, vim.log.levels.INFO)
end

---A helper function to print error messages to the console.
---@param obj any @The object to print.
function M.print_error(obj)
  M._print(obj, nil, vim.log.levels.ERROR)
end

---A helper function to print warning messages to the console.
---@param obj any @The object to print.
function M.print_warn(obj)
  M._print(obj, nil, vim.log.levels.WARN)
end

---A helper function to print debug messages to the console.
---@param obj any @The object to print.
function M.print_debug(obj)
  M._print(obj, nil, vim.log.levels.DEBUG)
end

---@class gamma.utility.notify_opts
---@field title? string The title of the notification
---@field timeout? number The timeout in milliseconds before the notification disappears
---@field icon? string The icon to display with the notification
---@field defer? number Delay in milliseconds before showing the notification

---Notify with optional deferred execution
---@param message string The notification message
---@param level? number The log level (default: vim.log.levels.INFO)
---@param opts? gamma.utility.notify_opts Notification options (can include defer field for delayed execution)
function M.notify(message, level, opts)
  level = level or vim.log.levels.INFO
  opts = opts or {}
  
  -- Extract defer option and remove it from opts before passing to vim.notify
  local defer_ms = opts.defer or 0
  local notify_opts = vim.tbl_deep_extend("force", {}, opts)
  notify_opts.defer = nil
  
  if defer_ms > 0 then
    vim.defer_fn(function()
      vim.notify(message, level, notify_opts)
    end, defer_ms)
  else
    vim.notify(message, level, notify_opts)
  end
end

return M