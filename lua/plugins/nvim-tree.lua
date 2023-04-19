return {
    {
        'nvim-tree/nvim-tree.lua',
        lazy = true,
        dependencies = {
            'nvim-tree/nvim-web-devicons'
        },
        config = function()
            local function on_attach(bufnr)
                local api = require('nvim-tree.api')

                local function opts(desc)
                    return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
                end

                api.config.mappings.default_on_attach(bufnr)

                vim.keymap.del('n', 'd', { buffer = bufnr })

                vim.keymap.set('n', '%', api.fs.create, opts('Create file'))
                vim.keymap.set('n', 'D', api.fs.remove, opts('Delete'))
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


            require('nvim-tree').setup({
                on_attach = on_attach,
                sort_by = function(nodes)
                    table.sort(nodes, natural_cmp)
                end,
                reload_on_bufenter = true,
                update_focused_file = {
                    enable = true,
                    update_root = true,
                },
                filters = {
                    dotfiles = true
                }
            })
        end
    },

}
