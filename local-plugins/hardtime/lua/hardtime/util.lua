local M = {}

local config = require("hardtime.config")

local logger = require("hardtime.log").new({
   plugin = "hardtime.nvim",
   level = "info",
   use_console = false,
})

function M.stopinsert()
   vim.cmd("stopinsert")
end

function M.get_time()
   return vim.fn.reltimefloat(vim.fn.reltime()) * 1000
end

function M.try_eval(expression)
   local success, result = pcall(vim.api.nvim_eval, expression)
   if success then
      return result
   end
   return expression
end

local last_notification_text
local last_notification_time = M.get_time()

function M.notify(text, log_level)
   if text ~= last_notification_text then
      log_level = log_level or vim.log.levels.INFO

      -- Use appropriate logger method based on level
      if log_level == vim.log.levels.ERROR then
         logger.error(text)
      elseif log_level == vim.log.levels.WARN then
         logger.warn(text)
      else
         logger.info(text)
      end

      config.config.callback(text, log_level)
   end
   last_notification_text = text
   last_notification_time = M.get_time()
end

function M.should_reset()
   return M.get_time() - last_notification_time > config.config.max_time
end

function M.reset_notification()
   last_notification_text = nil
end

function M.get_max_keys_size()
   local max_len = 0
   for pattern, hint in pairs(config.config.hints) do
      if hint then
         max_len = math.max(max_len, hint.length or #pattern)
      end
   end
   return max_len
end

return M
