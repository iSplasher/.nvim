local utility = require('gamma.utility')
local kmap = utility.kmap

return {

    {
        "gbprod/yanky.nvim",
        opts = {
            ring = {
                history_length = 100,
                storage = "sqlite",
                storage_path = vim.fn.stdpath("data") .. "/databases/yanky.db", -- Only for sqlite storage
                sync_with_numbered_registers = true,
                cancel_event = "update",
                ignore_registers = { "_" },
                update_register_on_cycle = false,
                permanent_wrapper = nil,
            },
            picker = {
                select = {
                    action = nil, -- nil to use default put action
                },
                telescope = {
                    use_default_mappings = true, -- if default mappings should be used
                    mappings = nil,              -- nil to use default mappings or no mappings (see `use_default_mappings`)
                },
            },
            system_clipboard = {
                sync_with_ring = true,
                clipboard_register = nil,
            },
            highlight = {
                on_put = true,
                on_yank = true,
                timer = 500,
            },
            preserve_cursor_position = {
                enabled = true,
            },
            textobj = {
                enabled = false,
            },
        },
        cmd = {
            "YankyRingHistory",
            "Telescope yank_history",
        },
        dependencies = {
            "kkharji/sqlite.lua",
            "nvim-telescope/telescope.nvim",
        },
        config = function(_, opts)
            require("yanky").setup(opts)

            require("telescope").load_extension("yank_history")

            -- Yanky keymaps
            local yanky_keymaps = {
                { "y",     "<Plug>(YankyYank)",                      mode = { "n", "x" },                                desc = "Yank text" },
                { "p",     "<Plug>(YankyPutAfter)",                  mode = { "n", "x" },                                desc = "Put yanked text after cursor" },
                { "P",     "<Plug>(YankyPutBefore)",                 mode = { "n", "x" },                                desc = "Put yanked text before cursor" },
                { "gp",    "<Plug>(YankyGPutAfter)",                 mode = { "n", "x" },                                desc = "Put yanked text after selection" },
                { "gP",    "<Plug>(YankyGPutBefore)",                mode = { "n", "x" },                                desc = "Put yanked text before selection" },
                -- { "<c-p>", "<Plug>(YankyPreviousEntry)",             desc = "Select previous entry through yank history" },
                -- { "<c-n>", "<Plug>(YankyNextEntry)",                 desc = "Select next entry through yank history" },
                { "]p",    "<Plug>(YankyPutIndentAfterLinewise)",    desc = "Put indented after cursor (linewise)" },
                { "[p",    "<Plug>(YankyPutIndentBeforeLinewise)",   desc = "Put indented before cursor (linewise)" },
                { "]P",    "<Plug>(YankyPutIndentAfterLinewise)",    desc = "Put indented after cursor (linewise)" },
                { "[P",    "<Plug>(YankyPutIndentBeforeLinewise)",   desc = "Put indented before cursor (linewise)" },
                { ">p",    "<Plug>(YankyPutIndentAfterShiftRight)",  desc = "Put and indent right" },
                { "<p",    "<Plug>(YankyPutIndentAfterShiftLeft)",   desc = "Put and indent left" },
                { ">P",    "<Plug>(YankyPutIndentBeforeShiftRight)", desc = "Put before and indent right" },
                { "<P",    "<Plug>(YankyPutIndentBeforeShiftLeft)",  desc = "Put before and indent left" },
                { "=p",    "<Plug>(YankyPutAfterFilter)",            desc = "Put after applying a filter" },
                { "=P",    "<Plug>(YankyPutBeforeFilter)",           desc = "Put before applying a filter" },
            }

            for _, keymap in ipairs(yanky_keymaps) do
                kmap(keymap.mode or "n", keymap[1], keymap[2], keymap.desc)
            end

            kmap(
                { "n", "x" },
                "<leader>y",
                utility.create_cmd("Telescope", { "yank_history" }),
                "Open Yank History",
                { silent = true }
            )
        end,
    },
    ---Comment and uncomment code
    {
        'numToStr/Comment.nvim',
        event = "BufReadPost",
        config = function()
            local comment = require('Comment')
            comment.setup {
                --     ---Add a space b/w comment and the line
                --     padding = true,
                --     ---Whether the cursor should stay at its position
                --     sticky = true,
                --     ---Lines to be ignored while (un)comment
                ignore = function()
                    local ft = vim.bo.filetype
                    local ignored = {
                        'startify', 'dashboard', 'NvimTree'
                    }
                    if vim.tbl_contains(ignored, ft) then
                        return '.*'
                    end

                    if vim.tbl_contains({ 'lua' }, ft) then
                        return '(^\\s*$ | ^\\s*--\\s*)' -- empty line or lua comments
                    end

                    return '^\\s*$' -- empty line
                end,
                --     ---LHS of toggle mappings in NORMAL mode
                --     toggler = {
                --         ---Line-comment toggle keymap
                --         line = 'gcc',
                --         ---Block-comment toggle keymap
                --         block = 'gbc',
                --     },
                --     ---LHS of operator-pending mappings in NORMAL and VISUAL mode
                --     opleader = {
                --         ---Line-comment keymap
                --         line = 'gc',
                --         ---Block-comment keymap
                --         block = 'gb',
                --     },
                --     ---LHS of extra mappings
                --     extra = {
                --         ---Add comment on the line above
                --         above = 'gcO',
                --         ---Add comment on the line below
                --         below = 'gco',
                --         ---Add comment at the end of line
                --         eol = 'gcA',
                --     },
                --     ---Enable keybindings
                --     ---NOTE: If given `false` then the plugin won't create any mappings
                --     mappings = {
                --         ---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
                --         basic = true,
                --         ---Extra mapping; `gco`, `gcO`, `gcA`
                --         extra = true,
                --     },
                --     ---Function to call before (un)comment
                --     pre_hook = nil,
                --     ---Function to call after (un)comment
                --     post_hook = nil,
            }

            -- Use block if more than one line is selected
            function smart_toggle_comment(prefix, suffix)
                prefix = prefix or ''
                if prefix then
                    prefix = prefix .. ' '
                end
                suffix = suffix or ''

                local mode = vim.api.nvim_get_mode().mode
                if mode == 'v' then
                    local line1 = vim.fn.line("'<")
                    local line2 = vim.fn.line("'>")
                    if line1 ~= line2 then
                        return prefix .. 'gbc' .. suffix
                    end
                end
                return prefix .. 'gcc' .. suffix
            end

            function smart_toggle_comment_cmd(keys, mode)
                return function()
                    utility.exec_keymap(keys, mode)
                end
            end

            -- Toggle comment the whole file
            kmap({ 'n', 'v', 'x', 'o' }, '<leader>cc', function()
                -- save current cursor position
                local cursor = vim.api.nvim_win_get_cursor(0)
                -- select the whole file
                utility.type_keymap('ggVG')

                utility.exec_keymap(smart_toggle_comment(), 'v')
                -- restore cursor position
                vim.api.nvim_win_set_cursor(0, cursor)
            end, "Toggle comment on the whole file", { silent = true })

            -- kmap({'n', 'v', 'o'}, '//', smart_toggle_comment_cmd(smart_toggle_comment()), "Toggle comment line(s)", { silent = true })
            -- kmap({'n', 'v', 'o'}, '<C-k>c', smart_toggle_comment_cmd(smart_toggle_comment()), "Toggle comment line(s)", { silent = true })
        end
    },

    ---Move text in any direction
    {
        'echasnovski/mini.move',
        version = '*',
        event = 'BufReadPost',
        config = function()
            require('mini.move').setup(
                {
                    -- Module mappings. Use `''` (empty string) to disable one.
                    mappings = {
                        -- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
                        left = '',
                        right = '',
                        down = '',
                        up = '',
                        -- Move current line in Normal mode
                        line_left = '',
                        line_right = '',
                        line_down = '',
                        line_up = '',
                    },
                    -- Options which control moving behavior
                    options = {
                        -- Automatically reindent selection during linewise vertical move
                        reindent_linewise = true,
                    },
                })

            kmap('x', { '<C-S-h>', '<C-S-left' }, "<Cmd>lua MiniMove.move_selection('left')<CR>", 'Move selection left')
            kmap('x', { '<C-S-l>', '<C-S-right' }, "<Cmd>lua MiniMove.move_selection('right')<CR>",
                'Move selection right')
            kmap('x', { '<C-S-k>', '<C-S-up' }, "<Cmd>lua MiniMove.move_selection('up')<CR>", 'Move selection up')
            kmap('x', { '<C-S-j>', '<C-S-down' }, "<Cmd>lua MiniMove.move_selection('down')<CR>", 'Move selection down')

            kmap('n', { '<C-S-h>', '<C-S-left' }, "<Cmd>lua MiniMove.move_line('left')<CR>", 'Move line left',
                { force = false })
            kmap('n', { '<C-S-l>', '<C-S-right' }, "<Cmd>lua MiniMove.move_line('right')<CR>", 'Move line right',
                { force = false })
            kmap('n', { '<C-S-k>', '<C-S-up' }, "<Cmd>lua MiniMove.move_line('up')<CR>", 'Move line up',
                { force = false })
            kmap('n', { '<C-S-j>', '<C-S-down' }, "<Cmd>lua MiniMove.move_line('down')<CR>", 'Move line down',
                { force = false })
        end
    },

    ---Text objects for Lua
    {
        'echasnovski/mini.ai',
        version = '*',
        event = 'BufReadPost',
        opts = {
            custom_textobjects = {
                -- Whole buffer
                B = function()
                    return {
                        from = { line = 1, col = 1 },
                        to = { line = vim.fn.line('$'), col = math.max(vim.fn.getline('$'):len(), 1) }
                    }
                end,
            }
        }
    },

    -- Surround text objects
    {
        'echasnovski/mini.surround',
        version = '*',
        event = 'BufReadPost',
        opts = {
            -- Add custom surroundings to be used on top of builtin ones. For more
            -- information with examples, see `:h MiniSurround.config`.
            custom_surroundings = nil,

            -- Duration (in ms) of highlight when calling `MiniSurround.highlight()`
            highlight_duration = 500,

            -- Module mappings. Use `''` (empty string) to disable one.
            mappings = {
                add = "sa",          -- Add surrounding in Normal and Visual modes
                delete = "sd",       -- Delete surrounding
                find = "sf",         -- Find surrounding (to the right)
                find_left = "Sf",    -- Find surrounding (to the left)
                highlight = "sv",    -- Highlight surrounding
                replace = "sr",      -- Replace surrounding
                update_n_lines = '', -- Update `n_lines`

                suffix_last = ',',   -- Suffix to search with "prev" method
                suffix_next = ';',   -- Suffix to search with "next" method
            },

            -- Number of lines within which surrounding is searched
            n_lines = 20,

            -- Whether to respect selection type:
            -- - Place surroundings on separate lines in linewise mode.
            -- - Place surroundings on each line in blockwise mode.
            respect_selection_type = false,

            -- How to search for surrounding (first inside current line, then inside
            -- neighborhood). One of 'cover', 'cover_or_next', 'cover_or_prev',
            -- 'cover_or_nearest', 'next', 'prev', 'nearest'. For more details,
            -- see `:h MiniSurround.config`.
            search_method = 'cover',

            -- Whether to disable showing non-error feedback
            -- This also affects (purely informational) helper messages shown after
            -- idle time if user input is required.
            silent = false,
        },
        config = function(_, opts)
            require('mini.surround').setup(opts)

            -- Backwards
            kmap({ 'n' }, "Sa", [[:lua MiniSurround.add()<CR>]], "Add surrounding (backwards)", {})
            kmap({ 'v' }, "Sa", [[:lua MiniSurround.add('visual')<CR>]], "Add surrounding (backwards)", {})
            kmap({ 'n', 'v' }, "Sr", [[:lua MiniSurround.replace()<CR>]], "Replace surrounding (backwards)",
                {})
            kmap({ 'n', 'v' }, "Sd", [[:lua MiniSurround.delete()<CR>]], "Delete surrounding (backwards)",
                {})
            kmap({ 'n', 'v' }, "Sv", [[:lua MiniSurround.highlight()<CR>]], "Highlight surrounding (backwards)",
                {})

            -- Disable default 's/S' behavior and map to surround operations
            kmap({ 'n' }, "s", "<nop>", "Surround operations", {})
            kmap({ 'n' }, "S", "<nop>", "Surround operations", {})

            -- Operator pending mapping for 's' after operators
            -- TODO: fix this
            -- kmap({ 'o' }, "s", function()
            --     -- Check if we're in operator pending mode and map to appropriate surround operation
            --     local mode = vim.api.nvim_get_mode()
            --     if mode.mode == 'no' then
            --         local operator = vim.v.operator


            --         local surround_cmd = nil
            --         local keys = ""
            --         if operator == 'y' then
            --             local m = vim.v.insertmode == 'v' and "visual" or "normal"
            --             surround_cmd = [[:lua MiniSurround.add(']] .. m .. [[')<CR>]]
            --             keys = "sa"
            --         elseif operator == 'd' then
            --             surround_cmd = [[:lua MiniSurround.delete()<CR>]]
            --             keys = "sd"
            --         elseif operator == 'c' then
            --             surround_cmd = [[:lua MiniSurround.replace()<CR>]]
            --             keys = "sc"
            --         elseif operator == 'r' then
            --             surround_cmd = [[:lua MiniSurround.replace()<CR>]]
            --             keys = "sr"
            --         end

            --         if utility.is_which_key_enabled() then
            --             local wk = require("which-key")
            --             -- show which-key menu for surround operations
            --             wk.show({ keys = keys, mode = vim.v.insertmode == 'v' and "v" or "n", expand = true })
            --         end

            --         if surround_cmd then
            --             return surround_cmd
            --         end
            --     end
            --     return "<nop>"
            -- end, "Surround operations in operator mode", {})

            -- Aliases
            kmap({ 'v' }, "s", "sv", "Select surrounding", {})
            kmap({ 'n', 'v', 'o' }, "ds", "sd", "Delete surrounding", {})
            kmap({ 'n', 'v', 'o' }, "cs", "sr", "Replace surrounding", {})

            -- Yank
            -- TODO: implement this
            -- kmap({ 'n', 'v', 'o' }, "ys", "", "Yank surrounding", {})
        end,
    },
}
