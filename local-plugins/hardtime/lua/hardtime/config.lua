local M = {}

M.config = {
   max_time = 1000,
   max_count = 3,
   disable_mouse = true,
   hint = true,
   timeout = 3000,
   notification = true,
   start_notification = true, -- Show notification when hardtime is enabled
   allow_different_key = true,
   enabled = true,
   force_exit_insert_mode = false,
   max_insert_idle_ms = 5000,
   resetting_keys = {
      ["1"] = { "n", "x" },
      ["2"] = { "n", "x" },
      ["3"] = { "n", "x" },
      ["4"] = { "n", "x" },
      ["5"] = { "n", "x" },
      ["6"] = { "n", "x" },
      ["7"] = { "n", "x" },
      ["8"] = { "n", "x" },
      ["9"] = { "n", "x" },
      ["c"] = { "n" },
      ["C"] = { "n" },
      ["d"] = { "n" },
      ["x"] = { "n" },
      ["X"] = { "n" },
      ["y"] = { "n" },
      ["Y"] = { "n" },
      ["p"] = { "n" },
      ["P"] = { "n" },
      ["gp"] = { "n" },
      ["gP"] = { "n" },
      ["."] = { "n" },
      ["="] = { "n" },
      ["<"] = { "n" },
      [">"] = { "n" },
      ["J"] = { "n" },
      ["gJ"] = { "n" },
      ["~"] = { "n" },
      ["g~"] = { "n" },
      ["gu"] = { "n" },
      ["gU"] = { "n" },
      ["gq"] = { "n" },
      ["gw"] = { "n" },
      ["g?"] = { "n" },
   },
   restriction_mode = "block", -- block or hint
   restricted_keys = {
      ["h"] = { "n", "x" },
      ["j"] = { "n", "x" },
      ["k"] = { "n", "x" },
      ["l"] = { "n", "x" },
      ["+"] = { "n", "x" },
      ["gj"] = { "n", "x" },
      ["gk"] = { "n", "x" },
      ["<C-M>"] = { "n", "x" },
      ["<C-N>"] = { "n", "x" },
      ["<C-P>"] = { "n", "x" },
   },
   disabled_keys = {
      ["<Up>"] = { "", "i" },
      ["<Down>"] = { "", "i" },
      ["<Left>"] = { "", "i" },
      ["<Right>"] = { "", "i" },
   },
   disabled_filetypes = {
      ["aerial"] = true,
      ["alpha"] = true,
      ["Avante"] = true,
      ["checkhealth"] = true,
      ["copilot-chat"] = true,
      ["dapui.*"] = true,
      ["db.*"] = true,
      ["Diffview.*"] = true,
      ["Dressing.*"] = true,
      ["fugitive"] = true,
      ["help"] = true,
      ["httpResult"] = true,
      ["lazy"] = true,
      ["lspinfo"] = true,
      ["man"] = true,
      ["mason"] = true,
      ["minifiles"] = true,
      ["Neogit.*"] = true,
      ["neo%-tree.*"] = true,
      ["neotest%-summary"] = true,
      ["netrw"] = true,
      ["noice"] = true,
      ["notify"] = true,
      ["NvimTree"] = true,
      ["oil"] = true,
      ["prompt"] = true,
      ["qf"] = true,
      ["query"] = true,
      ["snacks_dashboard"] = true,
      ["TelescopePrompt"] = true,
      ["Trouble"] = true,
      ["trouble"] = true,
      ["VoltWindow"] = true,
      ["undotree"] = true,
   },
   message = function(key, key_count)
      local message = "You pressed the " .. key .. " key too soon!"
      if key == "k" then
         message = message .. " Use [count]k or CTRL-U to scroll up."
      elseif key == "j" then
         message = message .. " Use [count]j or CTRL-D to scroll down."
      elseif key == "h" then
         message = message .. " Use b/B/ge/gE/F/T/0 to move left."
      elseif key == "l" then
         message = message .. " Use w/W/e/E/f/t/$ to move right."
      end
      return message
   end,
   disabled_message = function(key)
      return "The " .. key .. " key is disabled!"
   end,
   ui = {
      enter = true,
      focusable = true,
      border = {
         style = "rounded",
         text = {
            top = "Hardtime Report",
            top_align = "center",
         },
      },
      position = "50%",
      size = {
         width = "40%",
         height = "60%",
      },
   },
   hints = {
      ["%D1[hjkl]"] = {
         message = function(keys)
            return "Use " .. keys:sub(3, 3) .. " instead of " .. keys:sub(2, 3)
         end,
         length = 3,
      },
      ["[kj][%^_]"] = {
         message = function(key)
            return "Use "
                .. (key:sub(1, 1) == "k" and "-" or "<CR> or +")
                .. " instead of "
                .. key
         end,
         length = 2,
      },
      ["%$a"] = {
         message = function()
            return "Use A instead of $a"
         end,
         length = 2,
      },
      ["d%$"] = {
         message = function()
            return "Use D instead of d$"
         end,
         length = 2,
      },
      ["y%$"] = {
         message = function()
            return "Use Y instead of y$"
         end,
         length = 2,
      },
      ["c%$"] = {
         message = function()
            return "Use C instead of c$"
         end,
         length = 2,
      },
      ["%^i"] = {
         message = function()
            return "Use I instead of ^i"
         end,
         length = 2,
      },
      ["%D[j+]O"] = {
         message = function(keys)
            return "Use o instead of " .. keys:sub(2)
         end,
         length = 3,
      },
      ["[^fFtT]li"] = {
         message = function()
            return "Use a instead of li"
         end,
         length = 3,
      },
      ["2([dcy=<>])%1"] = {
         message = function(key)
            return "Use " .. key:sub(3) .. "j instead of " .. key
         end,
         length = 3,
      },

      -- hints for f/F/t/T
      ["[^dcy=]f.h"] = {
         message = function(keys)
            return "Use t" .. keys:sub(3, 3) .. " instead of " .. keys:sub(2)
         end,
         length = 4,
      },
      ["[^dcy=]F.l"] = {
         message = function(keys)
            return "Use T" .. keys:sub(3, 3) .. " instead of " .. keys:sub(2)
         end,
         length = 4,
      },
      ["[^dcy=]T.h"] = {
         message = function(keys)
            return "Use F" .. keys:sub(3, 3) .. " instead of " .. keys:sub(2)
         end,
         length = 4,
      },
      ["[^dcy=]t.l"] = {
         message = function(keys)
            return "Use f" .. keys:sub(3, 3) .. " instead of " .. keys:sub(2)
         end,
         length = 4,
      },

      -- iquote and aquote
      ["[^dcy]F[{%[(][dcy]f[}%])]"] = {
         message = function(keys)
            return "Use "
                .. keys:sub(4, 4)
                .. "a"
                .. keys:sub(3, 3)
                .. " instead of "
                .. keys:sub(2)
         end,
         length = 6,
      },
      ["[^dcy]T[{%[('\"`][dcy]t[}%])'\"]"] = {
         message = function(keys)
            return "Use "
                .. keys:sub(4, 4)
                .. "i"
                .. keys:sub(3, 3)
                .. " instead of "
                .. keys:sub(2)
         end,
         length = 6,
      },
      ["[^dcy]f[}%])'\"`][dcy]T[{%[('\"]"] = {
         message = function(keys)
            return "Use "
                .. keys:sub(4, 4)
                .. "i"
                .. keys:sub(6, 6)
                .. " instead of "
                .. keys:sub(2)
         end,
         length = 6,
      },

      -- hints for delete + insert
      ["d[bBwWeE%^%$]i"] = {
         message = function(keys)
            return "Use " .. "c" .. keys:sub(2, 2) .. " instead of " .. keys
         end,
         length = 3,
      },
      ["dg[eE]i"] = {
         message = function(keys)
            return "Use " .. "c" .. keys:sub(2, 3) .. " instead of " .. keys
         end,
         length = 4,
      },
      ["d[tTfF].i"] = {
         message = function(keys)
            return "Use " .. "c" .. keys:sub(2, 3) .. " instead of " .. keys
         end,
         length = 4,
      },
      ["d[ia][\"'`{}%[%]()<>bBwWspt]i"] = {
         message = function(keys)
            return "Use " .. "c" .. keys:sub(2, 3) .. " instead of " .. keys
         end,
         length = 4,
      },

      -- hints for unnecessary visual mode
      ["Vgg[dcy=<>]"] = {
         message = function(keys)
            return "Use " .. keys:sub(4, 4) .. "gg instead of " .. keys
         end,
         length = 4,
      },
      ['Vgg".[dy]'] = {
         message = function(keys)
            return "Use " .. keys:sub(4, 6) .. "gg instead of " .. keys
         end,
         length = 6,
      },
      ["VG[dcy=<>]"] = {
         message = function(keys)
            return "Use " .. keys:sub(3, 3) .. "G instead of " .. keys
         end,
         length = 3,
      },
      ['VG".[dy]'] = {
         message = function(keys)
            return "Use " .. keys:sub(3, 5) .. "G instead of " .. keys
         end,
         length = 5,
      },
      ["V%d[kj][dcy=<>]"] = {
         message = function(keys)
            return "Use "
                .. keys:sub(4, 4)
                .. keys:sub(2, 3)
                .. " instead of "
                .. keys
         end,
         length = 4,
      },
      ['V%d[kj]".[dy]'] = {
         message = function(keys)
            return "Use "
                .. keys:sub(4, 6)
                .. keys:sub(2, 3)
                .. " instead of "
                .. keys
         end,
         length = 6,
      },
      ["V%d%d[kj][dcy=<>]"] = {
         message = function(keys)
            return "Use "
                .. keys:sub(5, 5)
                .. keys:sub(2, 4)
                .. " instead of "
                .. keys
         end,
         length = 5,
      },
      ['V%d%d[kj]".[dy]'] = {
         message = function(keys)
            return "Use "
                .. keys:sub(5, 7)
                .. keys:sub(2, 4)
                .. " instead of "
                .. keys
         end,
         length = 7,
      },
      ["[vV][eE][dcy]"] = {
         message = function(keys)
            return "Use "
                .. keys:sub(3, 3)
                .. keys:sub(2, 2)
                .. " instead of "
                .. keys
         end,
         length = 3,
      },
      ['[vV][eE]".[dy]'] = {
         message = function(keys)
            return "Use "
                .. keys:sub(3, 5)
                .. keys:sub(2, 2)
                .. " instead of "
                .. keys
         end,
         length = 5,
      },
      ["[vV]g[eE][dcy]"] = {
         message = function(keys)
            return "Use "
                .. keys:sub(4, 4)
                .. keys:sub(2, 3)
                .. " instead of "
                .. keys
         end,
         length = 4,
      },
      ['[vV]g[eE]".[dy]'] = {
         message = function(keys)
            return "Use "
                .. keys:sub(4, 6)
                .. keys:sub(2, 3)
                .. " instead of "
                .. keys
         end,
         length = 6,
      },
      ["[vV][tTfF].[dcy]"] = {
         message = function(keys)
            return "Use "
                .. keys:sub(4, 4)
                .. keys:sub(2, 3)
                .. " instead of "
                .. keys
         end,
         length = 4,
      },
      ['[vV][tTfF].".[dy]'] = {
         message = function(keys)
            return "Use "
                .. keys:sub(4, 6)
                .. keys:sub(2, 3)
                .. " instead of "
                .. keys
         end,
         length = 6,
      },
      ["[vV][ia][\"'`{}%[%]()<>bBwWspt][dcy=<>]"] = {
         message = function(keys)
            return "Use "
                .. keys:sub(4, 4)
                .. keys:sub(2, 3)
                .. " instead of "
                .. keys
         end,
         length = 4,
      },
      ['[vV][ia]["\'`{}%[%]()<>bBwWspt]".[dy]'] = {
         message = function(keys)
            return "Use "
                .. keys:sub(4, 6)
                .. keys:sub(2, 3)
                .. " instead of "
                .. keys
         end,
         length = 6,
      },
   },
   ---@type function
   callback = function(text)
      vim.notify(
         text,
         vim.log.levels.WARN,
         {
            title = "⚡ Hardtime Training",
            timeout = M.config.timeout,
            icon = "⚡",
         }
      )
   end,
}

function M.migrate_old_config(config)
   -- Convert array elements in disabled_filetypes to key-value pairs
   if
       config.disabled_filetypes
       and type(config.disabled_filetypes) == "table"
   then
      local new_filetypes = {}
      for k, v in pairs(config.disabled_filetypes) do
         if
             type(k) == "number"
             and math.floor(k) == k
             and k >= 1
             and type(v) == "string"
         then
            new_filetypes[v] = true
         else
            new_filetypes[k] = v
         end
      end
      config.disabled_filetypes = new_filetypes
   end

   -- Replace empty tables with false for specific options
   local function replace_empty_with_false(t)
      for k, v in pairs(t) do
         if type(v) == "table" and next(v) == nil then
            t[k] = false
         end
      end
   end

   local options_to_process =
   { "resetting_keys", "restricted_keys", "disabled_keys", "hints" }
   for _, option in ipairs(options_to_process) do
      if config[option] and type(config[option]) == "table" then
         replace_empty_with_false(config[option])
      end
   end
end

return M
