local utility = require("gamma.utility")
local cargo = require("gamma.utility.cargo")

local fn = vim.fn
local oprint = print
local print = utility.print
local print_error = utility.print_error

local M = {}

-- Configure paths
local function get_paths()
    local data_dir = fn.stdpath("data")
    local temp_dir = fn.tempname()

    return {
        data_dir = data_dir,
        temp_dir = temp_dir
    }
end

--- Check if lux is already installed
function M.is_lux_installed()
    return utility.which("lx") ~= nil
end

-- Create required directories
local function create_dirs()
    local paths = get_paths()
    -- if fn.isdirectory(paths.rocks_dir) == 0 then
    --     fn.mkdir(paths.rocks_dir, "p")
    -- end

    -- if fn.isdirectory(paths.bin_dir) == 0 then
    --     fn.mkdir(paths.bin_dir, "p")
    -- end

    -- if fn.isdirectory(paths.temp_dir) == 0 then
    --     fn.mkdir(paths.temp_dir, "p")
    -- end
end

-- Install lux
function M.install_lux()
    if M.is_lux_installed() then
        oprint("Lux is already installed at: " .. get_paths().lux_bin)
        return true
    end
    print("Installing Lux...")

    -- Create necessary directories
    create_dirs()

    local success = cargo.install("lux-cli", { verbose = true })

    if success then
        print("Lux installation successful!")
    else
        print_error("Lux installation failed")
    end
    return success
end

-- Ensure lux is installed (can be called directly)
function M.ensure_lux()
    if not M.is_lux_installed() then
        return M.install_lux()
    end

    if not M.is_lux_installed() then
        error("Failed to install Lux CLI")
    end
end

-- Initialize module
function M.setup()
    if not M.is_lux_installed() then
        M.install_lux()
    end
end

return M
