local utility = require('gamma.utility')
local kmap = utility.kmap



-- From https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#dont-preview-binaries
-- Dont preview binaries
local buffer_preview_maker_cfg = function()
    local previewers = require("telescope.previewers")
    local Job = require("plenary.job")

    local new_maker = function(filepath, bufnr, opts)
        filepath = vim.fn.expand(filepath)
        Job:new({
            command = "file",
            args = { "--mime-type", "-b", filepath },
            on_exit = function(j)
                local mime_type = vim.split(j:result()[1], "/")[1]
                if mime_type == "text" then
                    previewers.buffer_previewer_maker(filepath, bufnr, opts)
                else
                    -- maybe we want to write something to the buffer here
                    vim.schedule(function()
                        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "BINARY" })
                    end)
                end
            end
        }):sync()
    end

    return new_maker
end


-- from https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#layouts
local telescope_ui_cfg = function()
    local Layout = require("nui.layout")
    local Popup = require("nui.popup")

    local TSLayout = require("telescope.pickers.layout")

    local function make_popup(options)
        local popup = Popup(options)
        function popup.border:change_title(title)
            popup.border.set_text(popup.border, "top", title)
        end

        return TSLayout.Window(popup)
    end

    return {
        defaults = {
            layout_strategy = "flex",
            layout_config = {
                horizontal = {
                    size = {
                        width = "90%",
                        height = "60%",
                    },
                },
                vertical = {
                    size = {
                        width = "90%",
                        height = "90%",
                    },
                },
            },
            create_layout = function(picker)
                local border = {
                    results = {
                        top_left = "┌",
                        top = "─",
                        top_right = "┬",
                        right = "│",
                        bottom_right = "",
                        bottom = "",
                        bottom_left = "",
                        left = "│",
                    },
                    results_patch = {
                        minimal = {
                            top_left = "┌",
                            top_right = "┐",
                        },
                        horizontal = {
                            top_left = "┌",
                            top_right = "┬",
                        },
                        vertical = {
                            top_left = "├",
                            top_right = "┤",
                        },
                    },
                    prompt = {
                        top_left = "├",
                        top = "─",
                        top_right = "┤",
                        right = "│",
                        bottom_right = "┘",
                        bottom = "─",
                        bottom_left = "└",
                        left = "│",
                    },
                    prompt_patch = {
                        minimal = {
                            bottom_right = "┘",
                        },
                        horizontal = {
                            bottom_right = "┴",
                        },
                        vertical = {
                            bottom_right = "┘",
                        },
                    },
                    preview = {
                        top_left = "┌",
                        top = "─",
                        top_right = "┐",
                        right = "│",
                        bottom_right = "┘",
                        bottom = "─",
                        bottom_left = "└",
                        left = "│",
                    },
                    preview_patch = {
                        minimal = {},
                        horizontal = {
                            bottom = "─",
                            bottom_left = "",
                            bottom_right = "┘",
                            left = "",
                            top_left = "",
                        },
                        vertical = {
                            bottom = "",
                            bottom_left = "",
                            bottom_right = "",
                            left = "│",
                            top_left = "┌",
                        },
                    },
                }

                local results = make_popup({
                    focusable = false,
                    border = {
                        style = border.results,
                        text = {
                            top = picker.results_title,
                            top_align = "center",
                        },
                    },
                    win_options = {
                        winhighlight = "Normal:Normal",
                    },
                })

                local prompt = make_popup({
                    enter = true,
                    border = {
                        style = border.prompt,
                        text = {
                            top = picker.prompt_title,
                            top_align = "center",
                        },
                    },
                    win_options = {
                        winhighlight = "Normal:Normal",
                    },
                })

                local preview = make_popup({
                    focusable = false,
                    border = {
                        style = border.preview,
                        text = {
                            top = picker.preview_title,
                            top_align = "center",
                        },
                    },
                })

                local box_by_kind = {
                    vertical = Layout.Box({
                        Layout.Box(preview, { grow = 1 }),
                        Layout.Box(results, { grow = 1 }),
                        Layout.Box(prompt, { size = 3 }),
                    }, { dir = "col" }),
                    horizontal = Layout.Box({
                        Layout.Box({
                            Layout.Box(results, { grow = 1 }),
                            Layout.Box(prompt, { size = 3 }),
                        }, { dir = "col", size = "50%" }),
                        Layout.Box(preview, { size = "50%" }),
                    }, { dir = "row" }),
                    minimal = Layout.Box({
                        Layout.Box(results, { grow = 1 }),
                        Layout.Box(prompt, { size = 3 }),
                    }, { dir = "col" }),
                }

                local function get_box()
                    local strategy = picker.layout_strategy
                    if strategy == "vertical" or strategy == "horizontal" then
                        return box_by_kind[strategy], strategy
                    end

                    local height, width = vim.o.lines, vim.o.columns
                    local box_kind = "horizontal"
                    if width < 100 then
                        box_kind = "vertical"
                        if height < 40 then
                            box_kind = "minimal"
                        end
                    end
                    return box_by_kind[box_kind], box_kind
                end

                local function prepare_layout_parts(layout, box_type)
                    layout.results = results
                    results.border:set_style(border.results_patch[box_type])

                    layout.prompt = prompt
                    prompt.border:set_style(border.prompt_patch[box_type])

                    if box_type == "minimal" then
                        layout.preview = nil
                    else
                        layout.preview = preview
                        preview.border:set_style(border.preview_patch[box_type])
                    end
                end

                local function get_layout_size(box_kind)
                    return picker.layout_config[box_kind == "minimal" and "vertical" or box_kind].size
                end

                local box, box_kind = get_box()
                local layout = Layout({
                    relative = "editor",
                    position = "50%",
                    size = get_layout_size(box_kind),
                }, box)

                layout.picker = picker
                prepare_layout_parts(layout, box_kind)

                local layout_update = layout.update
                function layout:update()
                    local box, box_kind = get_box()
                    prepare_layout_parts(layout, box_kind)
                    layout_update(self, { size = get_layout_size(box_kind) }, box)
                end

                return TSLayout(layout)
            end,
        },
    }
end

return {
    {
        {
            'nvim-telescope/telescope.nvim',
            branch = 'master',
            -- or                            , branch = '0.1.x',
            dependencies = {
                { 'nvim-lua/plenary.nvim' },
                'nvim-treesitter/nvim-treesitter',
                'nvim-telescope/telescope-ui-select.nvim',
                'MunifTanjim/nui.nvim',
                {
                    's1n7ax/nvim-window-picker',
                    name = 'window-picker',
                    event = 'VeryLazy',
                    version = '2.*',
                    config = function()
                        require 'window-picker'.setup()
                    end,
                }
            },
            opts = {
                defaults = {
                    previewer = true,
                    preview = {
                        filesize_limit = 10, -- MB
                    },
                    mappings = {
                        i = {
                            ["<C-/>"] = "which_key",
                        },
                        n = {
                            ["?"] = "which_key"
                        }
                    },
                },
            },
            config = function(_, opts)
                local actions = require("telescope.actions")

                require('telescope').setup { utility.merge_tables(opts, {
                    telescope_ui_cfg(),
                    {
                        defaults = {
                            buffer_previewer_maker = buffer_preview_maker_cfg(),
                            mappings = {
                                i = {
                                    ["<esc>"] = actions.close, -- Mapping <Esc> to quit in insert mode
                                    -- Using nvim-window-picker to choose a target window when opening a file from any picker.
                                    ['<C-g>'] = function(prompt_bufnr)
                                        -- Use nvim-window-picker to choose the window by dynamically attaching a function
                                        local action_set = require('telescope.actions.set')
                                        local action_state = require('telescope.actions.state')

                                        local picker = action_state.get_current_picker(prompt_bufnr)
                                        picker.get_selection_window = function(picker, entry)
                                            local picked_window_id = require('window-picker').pick_window() or
                                                vim.api.nvim_get_current_win()
                                            -- Unbind after using so next instance of the picker acts normally
                                            picker.get_selection_window = nil
                                            return picked_window_id
                                        end

                                        return action_set.edit(prompt_bufnr, 'edit')
                                    end,
                                }
                            }
                        }
                    }
                }) }

                -- Enable telescope fzf native, if installed
                pcall(require('telescope').load_extension, 'fzf')

                --   require('telescope').load_extension('ui-select')

                local builtin = require('telescope.builtin')

                kmap('n', '<leader>b/', function()
                    -- You can pass additional configuration to telescope to change theme, layout, etc.
                    builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                        winblend = 10,
                        previewer = false,
                    })
                end, '[/] Fuzzily search in current buffer', {})

                local grep_search = function()
                    local grep = builtin.grep_string
                    -- Check if rg command is available
                    if vim.fn.executable('rg') then
                        grep = builtin.live_grep -- live search results
                        return grep()
                    end

                    grep({ search = vim.fn.input("Grep > ") });
                end


                kmap('n', '<leader>ff', builtin.find_files, '[F]ind [f]ile')
                kmap('n', '<leader>fs', grep_search, '[S]earch in files',
                    { icon = { name = 'search', icon = '', color = 'green' } })

                kmap('n', '<leader>bf', builtin.buffers, '[F]ind [b]uffer', {})
                kmap('n', '<leader>cf', builtin.quickfix, 'List items in the [q]uick[f]ix list', {})
                kmap('n', '<leader>jf', builtin.jumplist, 'List [j]ump List entries', {})
                kmap('n', '<leader>@f', builtin.registers, 'List vim [r]egisters', {})
                kmap('n', "<leader>;f", builtin.commands, "List [c]ommands", {})
                kmap('n', "<leader>mf", builtin.marks, "List vim [m]arks and their value", {})
                kmap('n', "<leader>fh", builtin.oldfiles, "List most recently used files", {})


                kmap('n', '<leader>??', builtin.help_tags, '[F]ind [h]elp', {})
                kmap('n', '<leader>lw#', builtin.lsp_workspace_symbols, '[W]orkspace symbols', {})
            end
        },
    }
}
