local utility = require('gamma.utility')
local popup = require('gamma.popup')

local kmap = utility.kmap

if not vim.g.vscode and not vim.g.ide then
    kmap('n', '<leader>?l', function()
        -- if Noice cmd is available, use it
        if vim.fn.exists(':Noice') > 0 then
            vim.cmd('Noice log')
        else
            local messages = vim.fn.execute('messages', 'silent')
            popup.floating_content({
                title = "Log Messages",
                content = messages,
            }, {
                filetype = "log",
                modifiable = false,
            })
        end
    end, "Show log messages", { silent = true })

    -- Show guide
    local guide_path = utility.config_path() .. "/help.txt"
    kmap("n", "<leader>?g", function()
        popup.floating_content({
            title = "Gamma Help - Advanced Neovim Techniques",
            path = guide_path,
        }, { filetype = "help",
        })
    end, "Show guide")

    -- Quick navigation to specific help sections
    kmap("n", "<leader>?m", function()
        popup.floating_content({
            title = "Gamma Help - Movement & Navigation",
            path = guide_path,
        }, { filetype = "help",
        })
        -- Jump to navigation section after opening
        vim.defer_fn(function()
            vim.cmd('normal! /NAVIGATION & MOVEMENT\r')
            vim.cmd('normal! zz')
        end, 50)
    end, "Show movement help")

    kmap("n", "<leader>?t", function()
        popup.floating_content({
            title = "Gamma Help - Text Selection & Editing",
            path = guide_path,
        }, { filetype = "help",
        })
        -- Jump to text selection section after opening
        vim.defer_fn(function()
            vim.cmd('normal! /TEXT SELECTION\r')
            vim.cmd('normal! zz')
        end, 50)
    end, "Show text editing help")

    kmap("n", "<leader>?f", function()
        popup.floating_content({
            title = "Gamma Help - File & Project Navigation",
            path = guide_path,
        }, { filetype = "help",
        })
        -- Jump to project navigation section after opening
        vim.defer_fn(function()
            vim.cmd('normal! /MULTI-FILE & PROJECT\r')
            vim.cmd('normal! zz')
        end, 50)
    end, "Show file navigation help")

    kmap("n", "<leader>?s", function()
        popup.floating_content({
            title = "Gamma Help - Search & History",
            path = guide_path,
        }, { filetype = "help",
        })
        -- Jump to search section after opening
        vim.defer_fn(function()
            vim.cmd('normal! /SEARCH & HISTORY\r')
            vim.cmd('normal! zz')
        end, 50)
    end, "Show search help")

    kmap("n", "<leader>?r", function()
        popup.floating_content({
            title = "Gamma Help - Registers & Advanced Commands",
            path = guide_path,
        }, { filetype = "help",
        })
        -- Jump to advanced section after opening
        vim.defer_fn(function()
            vim.cmd('normal! /ADVANCED TECHNIQUES\r')
            vim.cmd('normal! zz')
        end, 50)
    end, "Show advanced help")

    -- Open help in a split instead of popup
    kmap("n", "<leader>?h", function()
        local help_path = utility.config_path() .. "/help.txt"
        if vim.fn.filereadable(help_path) == 1 then
            vim.cmd("vsplit " .. help_path)
            vim.bo.filetype = "help"
            vim.wo.wrap = false
            vim.wo.number = false
            vim.wo.relativenumber = false
            vim.wo.signcolumn = "no"
        else
            vim.notify("Help file not found: " .. help_path, vim.log.levels.ERROR)
        end
    end, "Open help in split")
end
