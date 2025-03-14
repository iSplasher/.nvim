return {
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    keys = {
      { "<leader>/",  "<cmd>ToggleTerm<CR>",                      desc = "Toggle terminal" },
      { "<leader>tf", "<cmd>ToggleTerm direction=float<CR>",      desc = "Toggle terminal (floating)" },
      { "<leader>tt", "<cmd>ToggleTerm direction=horizontal<CR>", desc = "Toggle terminal (horizontal)" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical<CR>",   desc = "Toggle terminal (vertical)" },
    },
    opts = {
      size = 10,
      -- <leader>/ to toggle the terminal
      open_mapping = [[<leader>/]],
      direction = 'float',
      float_opts = {
        border = 'single',
        winblend = 3,
      }
    }
  }

}
