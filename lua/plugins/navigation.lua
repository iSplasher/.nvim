local utility = require('gamma.utility')
local kmap = utility.kmap

return {
  -- Improved file navigation with harpoon
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
    config = function()
      local harpoon = require("harpoon")

      -- REQUIRED
      harpoon:setup()

      -- Basic keymaps
      kmap("n", "<leader>ba", function()
        harpoon:list():add()
        vim.notify("Buffer added to Harpoon", vim.log.levels.INFO, { title = "Harpoon" })
      end, "Add buffer to Harpoon")

      -- Navigate So specific marked buffers
      kmap("n", "<leader>bh1", function() harpoon:list():select(1) end, "Harpoon buffer 1", { group = "Harpoon" })
      kmap("n", "<leader>bh2", function() harpoon:list():select(2) end, "Harpoon buffer 2", { group = "Harpoon" })
      kmap("n", "<leader>bh3", function() harpoon:list():select(3) end, "Harpoon buffer 3", { group = "Harpoon" })
      kmap("n", "<leader>bh4", function() harpoon:list():select(4) end, "Harpoon buffer 4", { group = "Harpoon" })
      kmap("n", "<leader>bh5", function() harpoon:list():select(5) end, "Harpoon buffer 5", { group = "Harpoon" })

      -- Quick navigation between marked buffers
      kmap({ "n", 'v', 'i', 'x', }, "<C-S-P>", function() harpoon:list():prev() end, "Previous Harpoon mark",
        { force = true })
      kmap({ "n", 'v', 'i', 'x', }, "<C-S-N>", function() harpoon:list():next() end, "Next Harpoon mark",
        { force = true })

      -- Basic telescope configuration
      local conf = require("telescope.config").values
      local function toggle_telescope(harpoon_files)
        local file_paths = {}
        for _, item in ipairs(harpoon_files.items) do
          table.insert(file_paths, item.value)
        end

        require("telescope.pickers").new({}, {
          prompt_title = "Harpoon",
          finder = require("telescope.finders").new_table({
            results = file_paths,
          }),
          previewer = conf.file_previewer({}),
          sorter = conf.generic_sorter({}),
        }):find()
      end

      kmap("n", "<leader>bl", function()
        toggle_telescope(harpoon:list())
      end, "Open Harpoon Window")
    end,
  },

  -- Powerful structural search and replace
  {
    "cshuaimin/ssr.nvim",
    event = "VeryLazy",
    config = function()
      require("ssr").setup {
        border = "rounded",
        min_width = 50,
        min_height = 5,
        max_width = 120,
        max_height = 25,
        adjust_window = true,
        keymaps = {
          close = "<esc>",
          next_match = "n",
          prev_match = "N",
          replace_all = "<leader>r",
        },
      }

      kmap({ "n", "x" }, "<leader>\\r", function() require("ssr").open() end, "Structural Search & Replace")
    end
  },
}
