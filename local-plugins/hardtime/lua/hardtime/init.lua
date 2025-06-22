local util = require("hardtime.util")

local key_count = 0
local last_key = ""
local last_keys = ""
local last_time = util.get_time()
local mappings
local old_mouse_state = vim.o.mouse
local timer = nil
local hardtime_group = vim.api.nvim_create_augroup("HardtimeGroup", {})

-- Track buffer-specific keymaps that we've set
local buffer_keymaps = {} -- { [bufnr] = { { mode, key }, ... } }

local config = require("hardtime.config")

local function disable_mouse()
   old_mouse_state = vim.o.mouse ~= "" and vim.o.mouse or old_mouse_state
   vim.o.mouse = ""
end

local function restore_mouse()
   vim.o.mouse = old_mouse_state
end

local function get_return_key(key)
   for _, mapping in ipairs(mappings) do
      if mapping.lhs == key then
         if mapping.callback then
            local success, result = pcall(mapping.callback)
            if success then
               return result
            end

            return vim.schedule(mapping.callback)
         end
         return util.try_eval(mapping.rhs)
      end
   end
   return key
end

local function match_filetype(ft)
   for filetype, is_disabled in pairs(config.config.disabled_filetypes) do
      if filetype == ft and is_disabled then
         return true
      end
      local matcher = "^" .. filetype .. (filetype:sub(-1) == "*" and "" or "$")
      if ft:match(matcher) and is_disabled then
         return true
      end
   end

   return false
end

local function should_disable_hardtime()
   return match_filetype(vim.bo.ft)
       or vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "terminal"
       or vim.fn.reg_executing() ~= ""
       or vim.fn.reg_recording() ~= ""
end

local function handler(key)
   if should_disable_hardtime() then
      return get_return_key(key)
   end

   local curr_time = util.get_time()
   local should_reset_notification = require("hardtime.util").should_reset()

   if should_reset_notification then
      util.reset_notification()
   end

   -- key disabled
   if config.config.disabled_keys[key] then
      if config.config.notification and should_reset_notification then
         vim.schedule(function()
            util.notify("The " .. key .. " key is disabled!")
         end)
      end
      return ""
   end

   -- reset
   if config.config.resetting_keys[key] then
      key_count = 0
   end

   if config.config.restricted_keys[key] == nil then
      return get_return_key(key)
   end

   -- restrict
   local should_reset_key_count = curr_time - last_time > config.config.max_time
   local is_different_key = config.config.allow_different_key
       and key ~= last_key
   if
       key_count < config.config.max_count
       or should_reset_key_count
       or is_different_key
   then
      if should_reset_key_count or is_different_key then
         key_count = 1
         util.reset_notification()
      else
         key_count = key_count + 1
      end

      last_time = util.get_time()
      return get_return_key(key)
   end

   if config.config.notification then
      vim.schedule(function()
         local message = "You pressed the " .. key .. " key too soon!"
         if config.config.message then
            message = config.config.message(key, key_count)
         end
         util.notify(message)
      end)
   end

   if config.config.restriction_mode == "hint" then
      return get_return_key(key)
   end
   return ""
end

local function reset_timer()
   if timer then
      timer:stop()
   end

   if
       not should_disable_hardtime() and config.config.force_exit_insert_mode
   then
      timer = vim.defer_fn(util.stopinsert, config.config.max_insert_idle_ms)
   end
end

local M = {}
M.is_plugin_enabled = false

-- Set up keymaps for a specific buffer
local function setup_buffer_keymaps(bufnr)
   if buffer_keymaps[bufnr] then
      return -- Already set up for this buffer
   end

   buffer_keymaps[bufnr] = {}

   if should_disable_hardtime() then
      return
   end

   local keys_groups = {
      config.config.resetting_keys,
      config.config.restricted_keys,
      config.config.disabled_keys,
   }

   for _, keys in ipairs(keys_groups) do
      for key, mode in pairs(keys) do
         if mode then
            local success, _ = pcall(vim.keymap.set, mode, key, function()
               return handler(key)
            end, {
               buffer = bufnr,
               noremap = true,
               expr = true,
               desc = "hardtime: " .. key .. " restriction", -- Custom description instead of which_key_ignore
            })

            if success then
               table.insert(buffer_keymaps[bufnr], { mode, key })
            end
         end
      end
   end
end

-- Clean up keymaps for a specific buffer
local function cleanup_buffer_keymaps(bufnr)
   if not buffer_keymaps[bufnr] then
      return
   end

   for _, keymap_info in ipairs(buffer_keymaps[bufnr]) do
      local mode, key = keymap_info[1], keymap_info[2]
      pcall(vim.keymap.del, mode, key, { buffer = bufnr })
   end

   buffer_keymaps[bufnr] = nil
end

local function setup_autocmds()
   vim.api.nvim_create_autocmd("InsertEnter", {
      group = hardtime_group,
      callback = function()
         reset_timer()
      end,
   })

   -- Set up buffer-specific keymaps on BufReadPost
   vim.api.nvim_create_autocmd("BufReadPost", {
      group = hardtime_group,
      callback = function(event)
         if M.is_plugin_enabled then
            setup_buffer_keymaps(event.buf)
         end
      end,
   })

   -- Also set up for already loaded buffers when plugin is enabled
   vim.api.nvim_create_autocmd("BufEnter", {
      group = hardtime_group,
      callback = function(event)
         if M.is_plugin_enabled then
            setup_buffer_keymaps(event.buf)
         end
      end,
   })

   -- Clean up when buffer is deleted
   vim.api.nvim_create_autocmd("BufDelete", {
      group = hardtime_group,
      callback = function(event)
         cleanup_buffer_keymaps(event.buf)
      end,
   })

   if config.config.disable_mouse then
      vim.api.nvim_create_autocmd({ "BufEnter", "TermEnter" }, {
         group = hardtime_group,
         callback = function()
            if should_disable_hardtime() then
               restore_mouse()
               return
            end
            disable_mouse()
         end,
      })
   end
end

local clear_autocmds = function()
   vim.api.nvim_clear_autocmds({ group = hardtime_group })
end

function M.enable()
   if M.is_plugin_enabled then
      return
   end

   M.is_plugin_enabled = true
   mappings = vim.api.nvim_get_keymap("n")

   setup_autocmds()

   if config.config.disable_mouse then
      disable_mouse()
   end

   -- Set up keymaps for all currently loaded buffers
   for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(bufnr) then
         setup_buffer_keymaps(bufnr)
      end
   end

   -- Send notification that hardtime is enabled (if enabled in config)
   if config.config.start_notification then
      vim.notify(
         "⚡ Hardtime enabled!",
         vim.log.levels.INFO,
         {
            title = "⚡ Hardtime Training",
            icon = "⚡",
            timeout = 3000,
         }
      )
   end
end

function M.disable()
   if not M.is_plugin_enabled then
      return
   end

   M.is_plugin_enabled = false
   restore_mouse()
   clear_autocmds()

   -- Clean up buffer-specific keymaps for all buffers
   for bufnr, _ in pairs(buffer_keymaps) do
      cleanup_buffer_keymaps(bufnr)
   end

   -- Clear the tracking table
   buffer_keymaps = {}
end

function M.toggle()
   (M.is_plugin_enabled and M.disable or M.enable)()
end

local function setup(user_config)
   if vim.fn.has("nvim-0.10.0") == 0 then
      return vim.notify("hardtime.nvim requires Neovim >= v0.10.0")
   end

   user_config = user_config or {}
   config.migrate_old_config(user_config)
   config.config = vim.tbl_deep_extend("force", config.config, user_config)

   if config.config.enabled then
      M.enable()
   end

   local max_keys_size = util.get_max_keys_size()

   vim.on_key(function(_, k)
      local mode = vim.fn.mode()
      if k == "" or mode == "c" or mode == "R" then
         return
      end

      if mode == "i" then
         reset_timer()
         return
      end

      -- ignore key if it is triggering which-key.nvim
      local has_wk, wk = pcall(require, "which-key.state")
      if has_wk and wk.state ~= nil then
         return
      end

      local key = vim.fn.keytrans(k)
      if key == "<MouseMove>" then
         return
      end

      if k == "<" then
         key = "<"
      end

      last_keys = last_keys .. key
      last_key = key

      if #last_keys > max_keys_size then
         last_keys = last_keys:sub(-max_keys_size)
      end

      if
          not config.config.hint
          or not M.is_plugin_enabled
          or should_disable_hardtime()
      then
         return
      end

      for pattern, hint in pairs(config.config.hints) do
         if hint then
            local len = hint.length or #pattern
            local found = string.find(last_keys, pattern, -len)
            if found then
               local keys = string.sub(last_keys, found, #last_keys)
               local text = hint.message(keys)
               util.notify(text)
            end
         end
      end
   end)

   require("hardtime.command").setup()
end

function M.setup(user_config)
   local setup_timer = (vim.uv or vim.loop).new_timer()
   if setup_timer then
      setup_timer:start(
         500,
         0,
         vim.schedule_wrap(function()
            setup(user_config)
         end)
      )
   end
end

return M
