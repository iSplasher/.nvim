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
-- Track temporarily blocked keys
local blocked_keys = {}          -- { [key] = { modes = {...}, timer = timer_obj, original_maps = {...} } }
-- Track notification debouncing to prevent spam
local notification_debounce = {} -- { [key] = last_notification_time }

local config = require("hardtime.config")

local function disable_mouse()
   old_mouse_state = vim.o.mouse ~= "" and vim.o.mouse or old_mouse_state
   vim.o.mouse = ""
end

local function restore_mouse()
   vim.o.mouse = old_mouse_state
end

-- Handle notifications with debouncing to prevent spam
local function handle_debounced_notification(key, message_type)
   if not config.config.notification then
      return
   end
   
   local current_time = util.get_time()
   local debounce_key = key .. "_" .. message_type -- Separate debounce per message type
   local last_notification = notification_debounce[debounce_key] or 0
   local debounce_period = config.config.timeout or 1000 -- Use config timeout or 1 second
   
   -- Only notify if enough time has passed since last notification for this key+type
   if current_time - last_notification < debounce_period then
      return
   end
   
   notification_debounce[debounce_key] = current_time
   
   vim.schedule(function()
      local message, log_level
      if message_type == "blocked" then
         message = "Key " .. key .. " is temporarily blocked!"
         if config.config.message then
            message = config.config.message(key, key_count)
         end
         log_level = vim.log.levels.ERROR
      elseif message_type == "restricted" then
         message = "You pressed the " .. key .. " key too soon!"
         if config.config.message then
            message = config.config.message(key, key_count)
         end
         log_level = vim.log.levels.WARN
      elseif message_type == "disabled" then
         message = "The " .. key .. " key is disabled!"
         if config.config.disabled_message then
            message = config.config.disabled_message(key)
         end
         log_level = vim.log.levels.ERROR
      end
      
      if message then
         util.notify(message, log_level)
      end
   end)
end


-- Remove temporary block on a key and restore original mapping
local function unblock_key(key)
   if not blocked_keys[key] then
      return
   end

   -- Stop timer
   if blocked_keys[key].timer then
      blocked_keys[key].timer:stop()
   end

   -- Remove blocking keymaps and restore originals
   for _, mode in ipairs(blocked_keys[key].modes) do
      pcall(vim.keymap.del, mode, key)

      -- Restore original mapping if it existed
      local original = blocked_keys[key].original_maps[mode]
      if original then
         if original.callback then
            pcall(vim.keymap.set, mode, key, original.callback, {
               buffer = original.buffer == 1 and 0 or nil,
               noremap = original.noremap == 1,
               silent = original.silent == 1,
               expr = original.expr == 1,
               desc = original.desc,
            })
         elseif original.rhs then
            pcall(vim.keymap.set, mode, key, original.rhs, {
               buffer = original.buffer == 1 and 0 or nil,
               noremap = original.noremap == 1,
               silent = original.silent == 1,
               expr = original.expr == 1,
               desc = original.desc,
            })
         end
      end
   end

   blocked_keys[key] = nil
   -- Clear all debounce entries for this key (all message types)
   for debounce_key, _ in pairs(notification_debounce) do
      if debounce_key:match("^" .. key:gsub("[%-%^%$%(%)%%%.%[%]%*%+%?]", "%%%1") .. "_") then
         notification_debounce[debounce_key] = nil
      end
   end
end

-- Temporarily block a key by setting a keymap
local function block_key(key, modes)
   local block_data = blocked_keys[key]

   if block_data then
      -- Already blocked, just reset the timer
      if block_data.timer then
         block_data.timer:stop()
      end
   else
      -- Save original mappings before overriding
      block_data = { modes = {}, timer = nil, original_maps = {} }
      blocked_keys[key] = block_data

      for _, mode in ipairs(modes) do
         -- Save the original mapping
         local original_map = vim.fn.maparg(key, mode, false, true)
         if original_map and next(original_map) then
            block_data.original_maps[mode] = original_map
         end

         -- Set blocking keymap that notifies and returns <Ignore> when triggered
         vim.keymap.set(mode, key, function()
            handle_debounced_notification(key, "blocked")
            return "<Ignore>"
         end, {
            noremap = true,
            expr = true,
            desc = "hardtime: " .. key .. " temporary block",
         })
         table.insert(block_data.modes, mode)
      end
   end

   -- Set timer to unblock the key after restriction period
   block_data.timer = vim.defer_fn(function()
      unblock_key(key)
   end, config.config.max_time or 1000)
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
   -- Early exit: if key is already dynamically blocked, just return blocked result
   if blocked_keys[key] then
      return config.config.restriction_mode == "hint" and get_return_key(key) or ""
   end

   -- Early exit: plugin disabled for this context
   if should_disable_hardtime() then
      return get_return_key(key)
   end

   local curr_time = util.get_time()
   local should_reset_notification = require("hardtime.util").should_reset()

   if should_reset_notification then
      util.reset_notification()
   end

   -- Early exit: key is permanently disabled
   if config.config.disabled_keys[key] then
      if should_reset_notification then
         handle_debounced_notification(key, "disabled")
      end
      return ""
   end

   -- Reset counter for resetting keys
   if config.config.resetting_keys[key] then
      key_count = 0
   end

   -- Early exit: key is not restricted
   if config.config.restricted_keys[key] == nil then
      return get_return_key(key)
   end

   -- Check if restriction should apply
   local should_reset_key_count = curr_time - last_time > config.config.max_time
   local is_different_key = config.config.allow_different_key and key ~= last_key

   if key_count < config.config.max_count or should_reset_key_count or is_different_key then
      -- Key is allowed
      if should_reset_key_count or is_different_key then
         key_count = 1
         util.reset_notification()
      else
         key_count = key_count + 1
      end

      last_time = curr_time
      return get_return_key(key)
   end

   -- Key should be restricted - notify and potentially block
   handle_debounced_notification(key, "restricted")

   if config.config.restriction_mode == "hint" then
      return get_return_key(key)
   end
   -- Block mode: trigger dynamic blocking for future keypresses
   local modes_to_block = config.config.restricted_keys[key]
   if modes_to_block then
      vim.schedule(function()
         block_key(key, type(modes_to_block) == "table" and modes_to_block or { modes_to_block })
      end)
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

-- Set up keymaps for a specific buffer - hybrid approach
local function setup_buffer_keymaps(bufnr)
   if buffer_keymaps[bufnr] then
      return
   end

   buffer_keymaps[bufnr] = {}

   if should_disable_hardtime() then
      return
   end

   -- Only set permanent keymaps for disabled_keys (these should always be blocked)
   -- restricted_keys will use dynamic blocking
   for key, mode in pairs(config.config.disabled_keys) do
      if mode then
         local success, _ = pcall(vim.keymap.set, mode, key, function()
            return handler(key)
         end, {
            buffer = bufnr,
            noremap = true,
            expr = true,
            desc = "hardtime: " .. key .. " disabled",
         })

         if success then
            table.insert(buffer_keymaps[bufnr], { mode, key })
         end
      end
   end
end

-- Clean up keymaps for a specific buffer
local function cleanup_buffer_keymaps(bufnr)
   if not buffer_keymaps[bufnr] then
      return
   end

   -- Clean up permanent disabled key mappings
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
      vim.defer_fn(function()
         vim.notify(
         "⚡ Hardtime enabled!",
         vim.log.levels.INFO,
         {
            title = "⚡ Hardtime Training",
            icon = "⚡",
               timeout = 1000,
         }
      )
      end, 1500)
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

   -- Clean up any dynamically blocked keys
   for key, _ in pairs(blocked_keys) do
      unblock_key(key)
   end

   -- Clear the tracking tables
   buffer_keymaps = {}
   blocked_keys = {}
   notification_debounce = {}
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

   -- Cache commonly used values
   local hint_enabled = config.config.hint
   local hints_table = config.config.hints
   vim.on_key(function(_, k)
      -- Early exits for performance
      if k == "" then return end
      local mode = vim.fn.mode()
      if mode == "c" or mode == "R" then return end

      if mode == "i" then
         reset_timer()
         return
      end

      -- Skip mouse moves immediately
      if k == vim.keycode("<MouseMove>") then return end

      -- Check which-key state (only if available)
      local has_wk, wk = pcall(require, "which-key.state")
      if has_wk and wk.state ~= nil then return end

      -- Process key
      local key = k == "<" and "<" or vim.fn.keytrans(k)

      -- Update tracking variables
      last_keys = last_keys .. key
      last_key = key

      if #last_keys > max_keys_size then
         last_keys = last_keys:sub(-max_keys_size)
      end

      -- Early exit if hints disabled or plugin disabled
      if not hint_enabled or not M.is_plugin_enabled or should_disable_hardtime() then
         return
      end

      -- Process hints efficiently
      for pattern, hint in pairs(hints_table) do
         if hint then
            local len = hint.length or #pattern
            local found = string.find(last_keys, pattern, -len)
            if found then
               local keys = string.sub(last_keys, found, #last_keys)
               local text = hint.message(keys)
               if text ~= nil and text ~= "" then
                  util.notify(text, vim.log.levels.INFO)
                  break -- Only show first matching hint
               end
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
