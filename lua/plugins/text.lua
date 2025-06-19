local utility = require('gamma.utility')
local kmap = utility.kmap

return {

    {
        "gbprod/yanky.nvim",
        opts = {
            ring = { storage = "sqlite" },
        },
        cmd = {
            "YankyRingHistory",
            "Telescope yank_history",
        },
        dependencies = {
            "kkharji/sqlite.lua",
            "nvim-telescope/telescope.nvim",
        },
        config = function(opts)
            require("yanky").setup({
                picker = {
                    select = {
                        action = nil, -- nil to use default put action
                    },
                    telescope = {
                        mappings = nil, -- nil to use default mappings
                    },
                },
            })

            require("telescope").load_extension("yank_history")

            -- Yanky keymaps
            local yanky_keymaps = {
                { "y",     "<Plug>(YankyYank)",                      mode = { "n", "x" },                                desc = "Yank text" },
                { "p",     "<Plug>(YankyPutAfter)",                  mode = { "n", "x" },                                desc = "Put yanked text after cursor" },
                { "P",     "<Plug>(YankyPutBefore)",                 mode = { "n", "x" },                                desc = "Put yanked text before cursor" },
                { "gp",    "<Plug>(YankyGPutAfter)",                 mode = { "n", "x" },                                desc = "Put yanked text after selection" },
                { "gP",    "<Plug>(YankyGPutBefore)",                mode = { "n", "x" },                                desc = "Put yanked text before selection" },
                { "<c-p>", "<Plug>(YankyPreviousEntry)",             desc = "Select previous entry through yank history" },
                { "<c-n>", "<Plug>(YankyNextEntry)",                 desc = "Select next entry through yank history" },
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
        event = 'BufEnter',
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
                { noremap = true })
            kmap('n', { '<C-S-l>', '<C-S-right' }, "<Cmd>lua MiniMove.move_line('right')<CR>", 'Move line right',
                { noremap = true })
            kmap('n', { '<C-S-k>', '<C-S-up' }, "<Cmd>lua MiniMove.move_line('up')<CR>", 'Move line up',
                { noremap = true })
            kmap('n', { '<C-S-j>', '<C-S-down' }, "<Cmd>lua MiniMove.move_line('down')<CR>", 'Move line down',
                { noremap = true })
        end
    },

    ---Text objects for Lua
    {
        'echasnovski/mini.ai',
        version = '*',
        event = 'LSPAttach',
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
    }
}
