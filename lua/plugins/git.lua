local utility = require('gamma.utility')
local kmap = utility.kmap

return {
   'tpope/vim-fugitive',
   'tpope/vim-rhubarb',
   'lewis6991/gitsigns.nvim',

   {
      "sindrets/diffview.nvim",
      dependencies = "nvim-lua/plenary.nvim",
      cmd = { "DiffviewOpen", "DiffviewFileHistory" },
      config = function()
         require("diffview").setup({
            enhanced_diff_hl = true,
            view = {
               merge_tool = {
                  layout = "diff3_mixed",
               },
            },
         })


         kmap("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", "Open diff viewer")
         kmap("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>",
            "File history of current buffer")
      end,
   },
   {
      "NeogitOrg/neogit",
      event = "VeryLazy",
      dependencies = {
         "nvim-lua/plenary.nvim",
         "sindrets/diffview.nvim",
         "nvim-telescope/telescope.nvim"
      },
      cmd = "Neogit",
      opts = {
         kind = "floating",
         commit_editor = {
            kind = "floating",
         },
         commit_select_view = {
            kind = "floating",
         },
         commit_view = {
            kind = "floating",
         },
         log_view = {
            kind = "floating",
         },
         tag_editor = {
            kind = "floating",
         },
         stash = {
            kind = "floating",
         },
         refs_view = {
            kind = "floating",
         },
         reflog_view = {
            kind = "floating",
         },
         description_editor = {
            kind = "floating",
         },
         integrations = {
            telescope = true,
            diffview = true,
         },
      },
      config = function(_, opts)
         require("neogit").setup(opts)

         kmap("n", "<leader>gs", "<cmd>Neogit<cr>", "Open git window")
         kmap('n', '<leader>gc', '<cmd>Neogit commit<cr>', "Commit")
         kmap('n', '<leader>gp', '<cmd>Neogit push<cr>', "Push")
         kmap('n', '<leader>gP', '<cmd>Neogit pull<cr>', "Pull")
         kmap('n', '<leader>gf', '<cmd>Neogit fetch<cr>', "Fetch")
         kmap('n', '<leader>gm', '<cmd>Neogit merge<cr>', "Merge")
         kmap('n', '<leader>gS', '<cmd>Neogit stash<cr>', "Stash")
         kmap('n', '<leader>gR', '<cmd>Neogit rebase<cr>', "Rebase")
         kmap('n', '<leader>gC', '<cmd>Neogit commit --amend<cr>', "Amend")
         kmap('n', '<leader>gt', '<cmd>Neogit tag<cr>', "Tag")
         kmap('n', '<leader>gb', '<cmd>Neogit branch<cr>', "Branch")
         kmap('n', '<leader>gl', '<cmd>Neogit log<cr>', "Log")
      end,
   }


}
