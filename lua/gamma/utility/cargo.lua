local utility = require("gamma.utility")

local M = {}

---@class gamma.utility.cargo.InstallOpts
---@field verbose boolean Whether to print verbose output
---@field locked boolean Whether to use the --locked flag if available
---@field cwd? string The current working directory to run the command in. Defaults to nvim config path.
---Install a cargo package
---@param package string
---@param opts? gamma.utility.cargo.InstallOpts
---@return boolean
function M.install(package, opts)
    opts = opts or {}
    opts.verbose = opts.verbose == nil or opts.verbose

    if opts.cwd == nil then
        opts.cwd = utility.config_path()
    end

    local package_name = package

    local success = false
    if utility.which("cargo") then
        local out = utility.shell({
            "cargo",
            "binstall", "--locked", "-y", package_name,
        }, {
            verbose = opts.verbose,
            cwd = opts.cwd,
        })

        -- binstall is too old and doesn't have --locked, so try without
        if out.code ~= 0 and out.stdout and out.stdout:find("--locked is not found") then
            out = utility.shell({
                "cargo",
                "binstall", "-y", package_name
            }, {
                verbose = opts.verbose,
                cwd = opts.cwd,
            })
        end

        -- doesn't have binstall, try normal
        if out.code ~= 0 then
            out = utility.shell({
                "cargo",
                "install", "--locked", package_name,
            }, {
                verbose = opts.verbose,
                cwd = opts.cwd,
            })
        end


        -- install is too old and doesn't have --locked, so try without
        if out.code ~= 0 and out.stdout and out.stdout:find("--locked is not found") then
            out = utility.shell({
                "cargo",
                "install", package_name
            }, {
                verbose = opts.verbose,
                cwd = opts.cwd,
            })
        end


        if out.code == 0 then
            success = true
        else
            utility.print_error("Failed to install cargo package " ..
                package_name .. ": \n" .. utility.print_table(out))
        end
    end
    return success
end

return M
