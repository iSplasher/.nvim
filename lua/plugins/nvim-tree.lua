local utility = require('gamma.utility')
local kmap = utility.kmap

local system_open_cmd = ""
if utility.is_windows() then
    system_open_cmd = "explorer"
elseif utility.is_mac() then
    system_open_cmd = "open"
else
    system_open_cmd = "xdg-open"
end

return {
    {
        'nvim-tree/nvim-tree.lua',
        event = 'VeryLazy',
        dependencies = {
        },
        opts = {
            respect_buf_cwd = true,
            view = {
                adaptive_size = true,
                side = "left",
            },
            reload_on_bufenter = true,
            update_focused_file = {
                enable = true,
                update_root = true,
            },
            filters = {
                dotfiles = true
            },
            system_open = {
                cmd = system_open_cmd,
                args = {}
            },
        },
        init = function()
            -- disable netrw
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1
        end,
        config = function(_, opts)
            local function open_project_tree()
                -- Set to cwd
                local api = require("nvim-tree.api")
                local global_cwd = vim.fn.getcwd(-1, -1)
                api.tree.change_root(global_cwd)

                vim.cmd.NvimTreeToggle()
            end

            kmap("n", "<leader><tab>", open_project_tree, "Toggle file browser")


            local function on_attach(bufnr)
                local api = require('nvim-tree.api')

                local function opts(desc, force)
                    if force == nil then
                        force = true
                    end
                    return {
                        desc = 'nvim-tree: ' .. desc,
                        buffer = bufnr,
                        force = force,
                        silent = true,
                        nowait = true
                    }
                end


                api.config.mappings.default_on_attach(bufnr)

                -- Close tree when opening a file
                local function open_and_close()
                    api.node.open.edit(nil, { quit_on_open = true })
                end
                --
                -- kmap('n', 'h', function()
                --     api.node.navigate.parent()
                --     utility.keypress('<CR>')
                -- end, opts('Navigate to parent'))
                -- kmap('n', 'l', open_and_close, opts('Open'))
                --
                -- close on esc
                kmap('n', '<Esc>', api.tree.close, opts('Close', false))

                vim.keymap.del('n', 'd', { buffer = bufnr })

                kmap('n', '%', api.fs.create, opts('Create file'))
                kmap('n', 'D', api.fs.remove, opts('Delete'))
                kmap('n', '?', api.tree.toggle_help, opts('Help'))


                kmap('n', '<CR>', open_and_close, opts('Open file', false))
            end

            -- Automatically open file upon creation
            local api = require("nvim-tree.api")
            api.events.subscribe(api.events.Event.FileCreated, function(file)
                vim.cmd("edit " .. file.fname)
            end)

            -- Sorting files naturally (respecting numbers within files names)
            local function natural_cmp(left, right)
                left = left.name:lower()
                right = right.name:lower()

                if left == right then
                    return false
                end

                for i = 1, math.max(string.len(left), string.len(right)), 1 do
                    local l = string.sub(left, i, -1)
                    local r = string.sub(right, i, -1)

                    if type(tonumber(string.sub(l, 1, 1))) == "number" and type(tonumber(string.sub(r, 1, 1))) == "number" then
                        local l_number = tonumber(string.match(l, "^[0-9]+"))
                        local r_number = tonumber(string.match(r, "^[0-9]+"))

                        if l_number ~= r_number then
                            return l_number < r_number
                        end
                    elseif string.sub(l, 1, 1) ~= string.sub(r, 1, 1) then
                        return l < r
                    end
                end
            end


            require('nvim-tree').setup(utility.merge_table(opts, {
                on_attach = on_attach,
                sort_by = function(nodes)
                    table.sort(nodes, natural_cmp)
                end,
            }))
        end
    },

}
