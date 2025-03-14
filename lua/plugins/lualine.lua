return {
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons', lazy = true },
        config = function()
            local cfg = require('lualine').get_config()

            cfg.options.theme = 'horizon'
            cfg.options.icons_enabled = true
            cfg.options.component_separators = { left = '', right = '' }
            cfg.options.section_separators = { left = '', right = '' }

            cfg.extensions = { 'nvim-tree', 'lazy', 'fugitive' }

            -- Show the current keymap in the statusline
            local function keymap()
                if vim.opt.iminsert:get() > 0 and vim.b.keymap_name then
                    return '⌨ ' .. vim.b.keymap_name
                end
                return ''
            end

            -- Change filename color based on modified status
            local custom_fname = require('lualine.components.filename'):extend()
            local highlight = require 'lualine.highlight'


            local hl_color = vim.api.nvim_get_hl_by_name('Debug', true).foreground

            local default_status_colors = { saved = nil, modified = string.format("#%06x", hl_color) }

            function custom_fname:init(options)
                custom_fname.super.init(self, options)
                self.status_colors = {
                    saved = highlight.create_component_highlight_group(
                        { fg = default_status_colors.saved }, 'filename_status_saved', self.options),
                    modified = highlight.create_component_highlight_group(
                        { fg = default_status_colors.modified }, 'filename_status_modified', self.options),
                }
                if self.options.color == nil then self.options.color = '' end
            end

            function custom_fname:update_status()
                local data = custom_fname.super.update_status(self)
                data = highlight.component_format_highlight(vim.bo.modified
                        and self.status_colors.modified
                        or self.status_colors.saved) .. data
                return data
            end

            local function word_count()
                local counts = vim.fn['wordcount']()
                local w = counts['visual_words'] or counts['words']
                local c = counts['visual_chars'] or counts['chars']
                return 'W: ' .. w .. '｜' .. c
            end

            ------------

            cfg.sections.lualine_c = {
                '%=', -- centers file name
                {
                    custom_fname,
                    path = 3,
                    symbols = {
                        modified = ' ',
                        saved = ' ',
                        unnamed = ' ',
                        newfile = ' ',
                    },
                }
            }
            cfg.sections.lualine_x = {
                keymap,
                'encoding',
                {
                    'fileformat',
                    icons_enabled = true,
                    symbols = {
                        unix = 'LF',
                        dos = 'CRLF',
                        mac = 'CR',
                    },
                },
                'filetype',
            }

            cfg.sections.lualine_z = { word_count, 'location' }

            require('lualine').setup(cfg)
        end
    }
}
