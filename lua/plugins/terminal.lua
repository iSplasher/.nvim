local utility = require('gamma.utility')
local kmap = utility.kmap
local default_direction = 'horizontal'
return {
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    event = "VeryLazy",
    priority = 10,
    opts = {
      size = 10,
      close_on_exit = true,
      shell = vim.o.shell,
      -- <leader>// to toggle the terminal
      open_mapping = [[<leader>//]],
      direction = default_direction,
      float_opts = {
        border = 'double',
        winblend = 3,
        highlights = {
          border = "NoiceCmdlinePopupBorder",
        },
      },
    },
    config = function(_, opts)
      local tt = require('toggleterm')
      tt.setup(opts)
      local function prev_window()
        vim.cmd('stopinsert')
        -- Move to previous window
        vim.cmd('wincmd p')
      end
      local function close_terminal()
        vim.cmd('stopinsert')
        vim.cmd('q')
      end
      -- Terminal keybindings
      function _G.set_terminal_keymaps()
        local opts = { buffer = 0, force = false }
        kmap('n', '<esc>', prev_window, "Focus previous window", opts)
        kmap('n', '<tab>', prev_window, "Focus previous window", opts)
        kmap({ 'n', 'v' }, 'q', close_terminal, "Close terminal", opts)

        -- Terminal mode keybindings
        kmap('t', '<esc>', [[<C-\><C-n>]], "Exit terminal mode", opts)
        kmap('t', '<C-h>', [[<Cmd>wincmd h<CR>]], "Move left", opts)
        kmap('t', '<C-j>', [[<Cmd>wincmd j<CR>]], "Move down", opts)
        kmap('t', '<C-k>', [[<Cmd>wincmd k<CR>]], "Move up", opts)
        kmap('t', '<C-l>', [[<Cmd>wincmd l<CR>]], "Move right", opts)
        kmap('t', '<C-w>', [[<C-\><C-n><C-w>w]], "Move to next window", opts)
      end

      vim.cmd('autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()')

      local term = require("toggleterm.terminal")
      local Terminal = term.Terminal

      local function new_terminal_v()
        Terminal:new({
          direction = 'vertical',
        }):toggle()
      end

      local function new_terminal_h()
        Terminal:new({
          direction = 'horizontal',
        }):toggle()
      end

      local function switch_to_terminal()
        local t = term.get_last_focused()
        if t == nil then
          local f = term.find(function(ft)
            if ft:is_open() then
              return true
            end
            return false
          end)
          local id = 1
          if f then
            id = f.id
          end
          t = term.get_or_create_term(id, nil, default_direction)
        end
        if not t:is_open() then
          t:open()
        end
        t:focus()
        t:scroll_bottom()
        t:set_mode(term.mode.INSERT)
      end

      --- Send !shell in command mode to terminal
      local function switch_to_terminal_on_shebang()
        local cr = vim.api.nvim_replace_termcodes('<CR>', true, false, true)
        -- get text of currently focused buffer
        local current_text = vim.fn.getcmdline()
        -- if text is empty
        if not current_text or current_text == "" then
          vim.api.nvim_feedkeys(cr, 'n', false)
          switch_to_terminal()
        else
          return vim.api.nvim_feedkeys('!', 'n', false)
        end
      end

      kmap('c', "!", switch_to_terminal_on_shebang, "Run shell command", { force = true })

      kmap('n', "<leader>//", switch_to_terminal, "Open terminal", { force = true })
      kmap('n', "<leader>/f", "<cmd>ToggleTerm direction=float<CR>", "Toggle terminal (floating)")
      kmap('n', "<leader>/h", new_terminal_h, "Create terminal (horizontal)")

      kmap('n', "<leader>/v", new_terminal_v, "Create terminal (vertical)")

      local lazygit = Terminal:new({
        cmd = "lazygit",
        hidden = true,
        direction = "float",
        float_opts = {
          border = "double",
        },
      })

      function _G._lazygit_toggle()
        if vim.fn.executable("lazygit") == 0 then
          utility.print_error("lazygit is not installed")
          return
        end
        lazygit:toggle()
      end

      kmap('n', "<leader>gg", "<cmd>lua _lazygit_toggle()<CR>", "Toggle lazygit", { silent = true })
    end,
  }

}
