local utility = require('gamma.utility')
local M = {
    installed = false, -- Whether lazy.nvim is installed
}

function M.install_lazy()
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

    if M.installed then
        print("lazy.nvim is already installed at: " .. lazypath)
        return -- lazy.nvim is already installed
    end
    -- Bootstrap lazy.nvim
    if not (vim.uv or vim.loop).fs_stat(lazypath) then
        local lazyrepo = "https://github.com/folke/lazy.nvim.git"
        local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
        if vim.v.shell_error ~= 0 then
            vim.api.nvim_echo({
                { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
                { out,                            "WarningMsg" },
                { "\nPress any key to exit..." },
            }, true, {})
            vim.fn.getchar()
            os.exit(1)
        end
    end
    vim.opt.rtp:prepend(lazypath)
    M.installed = true
end

function M.ensure_lazy()
    if not M.installed then
        M.install_lazy()
    end

    if not M.installed then
        error("Failed to install lazy.nvim")
    end
end

--- Setup lazy.nvim
--- @class config.lazy.LazySetupOpts
---@field editor_plugins string[] List of plugins to enable when running in VSCode, IDE, etc.
---@param opts config.lazy.LazySetupOpts|nil
function M.setup(opts)
    M.ensure_lazy() -- Ensure lazy.nvim is installed

    opts = opts or {}
    local editor_plugins = opts.editor_plugins or {}
    local diff = "git"


    if not vim.g.is_remote then
        if utility.shell({ "git", "config", "diff.tool" }) ~= "" and utility.shell({ "git", "config", "difftool.prompt" }) == "false" then
            diff = "terminal_git"
        end
    end


    require('lazy').setup {
        defaults = {
            lazy = false,  -- lazy load plugins by default
            version = "*", -- by default, only install stable versions
            cond = function(plugin)
                -- Check if plugin is disabled via debug system
                local debug_ok, debug_plugin = pcall(require, 'gamma.debug.plugin')
                if debug_ok and not debug_plugin.should_load_plugin(plugin.name) then
                    return false
                end
                
                -- When running in VSCode
                if vim.g.vscode then
                    for _, name in ipairs(editor_plugins) do
                        if plugin.name == name then
                            return true
                        end
                    end

                    return false
                end
                return true
            end
        },
        spec = {
            -- import your plugins
            { import = "plugins" },
        },
        -- Configure any other settings here. See the documentation for more details.
        -- colorscheme that will be used when installing plugins.
        install = { colorscheme = { vim.g.colors_name or "habamax" } },
        -- automatically check for plugin updates
        checker = {
            enabled = true,
            notify = false,
            check_pinned = true,
        },
        change_detection = {
            enabled = false, -- disabled to use custom config reloader
            notify = false,
        },

        performance = {
            reset_packpath = true, -- reset the package path to improve startup time
            rtp = {
                disabled_plugins = {
                    "matchit",
                    "netrwPlugin"
                },
            },
        },
        diff = {
            -- diff command <d> can be one of:
            -- * browser: opens the github compare view. Note that this is always mapped to <K> as well,
            --   so you can have a different command for diff <d>
            -- * git: will run git diff and open a buffer with filetype git
            -- * terminal_git: will open a pseudo terminal with git diff
            -- * diffview.nvim: will open Diffview to show the diff
            cmd = diff,
        },
        dev = {
            -- Directory where you store your local plugin projects. If a function is used,
            -- the plugin directory (e.g. `~/projects/plugin-name`) must be returned.
            path = utility.config_path() .. "/local-plugins",
            ---@type string[] plugins that match these patterns will use your local versions instead of being fetched from GitHub
            patterns = {},    -- For example {"folke"}
            fallback = false, -- Fallback to git when local plugin doesn't exist
        },
    }
end

return M
