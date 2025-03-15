local utility = require("gamma.utility")
local api = vim.api
local fn = vim.fn
local oprint = print
local print = utility.print
local print_error = utility.print_error

local M = {}

-- cmd is string[]
local function powershell_cmd(cmd)
  local base = {"powershell", "-noprofile", "-executionpolicy", "bypass"}
  return vim.list_extend(base, cmd)
end

-- Configure paths
local function get_paths()
  local data_dir = fn.stdpath("data")
  local rocks_dir = data_dir .. "/lazy-rocks/hererocks"
  local bin_dir = rocks_dir .. "/bin"
  local luarocks_bin = bin_dir .. "/luarocks"
  local temp_dir = fn.tempname()
  
  return {
    data_dir = data_dir,
    rocks_dir = rocks_dir,
    bin_dir = bin_dir,
    luarocks_bin = luarocks_bin,
    temp_dir = temp_dir
  }
end

-- Check if luarocks is already installed
local function is_luarocks_installed()
  local paths = get_paths()
  return fn.filereadable(paths.luarocks_bin) == 1
end

-- Create required directories
local function create_dirs()
  local paths = get_paths()
  
  if fn.isdirectory(paths.rocks_dir) == 0 then
    fn.mkdir(paths.rocks_dir, "p")
  end
  
  if fn.isdirectory(paths.bin_dir) == 0 then
    fn.mkdir(paths.bin_dir, "p")
  end
  
  if fn.isdirectory(paths.temp_dir) == 0 then
    fn.mkdir(paths.temp_dir, "p")
  end
end

-- Download file using curl or wget
local function download_file(url, output_path)
  local cmd
  if utility.is_windows() then
    cmd = powershell_cmd( {"-command", "Invoke-WebRequest", "-Uri", url, "-OutFile", output_path})
  else
    cmd = {"curl", "-L", "-s" ,"-o", output_path, url}
  end
  
  local result = utility.shell(cmd, {verbose = true})
  return result.code == 0
end

-- Extract zip archive
local function extract_zip(zip_file, extract_dir)
  local cmd
  if utility.is_windows() then
    -- Using PowerShell's Expand-Archive
    cmd = powershell_cmd( {"-command", "Expand-Archive", "-Path", zip_file, "-DestinationPath", extract_dir, "-Force"})
  else
    -- Using unzip
    cmd = {"unzip", "-o", zip_file, "-d", extract_dir}
  end
  
  local result = utility.shell(cmd, {verbose = true})
  return result.code == 0
end

-- Install luarocks on Windows
local function install_luarocks_windows()
  local paths = get_paths()
  local zip_url = "https://luarocks.github.io/luarocks/releases/luarocks-3.11.1-win32.zip"
  local zip_file = paths.temp_dir .. "/luarocks.zip"
  
  -- Download zip
  print("Downloading luarocks for Windows...")
  if not download_file(zip_url, zip_file) then
    print_error("Failed to download luarocks")
    return false
  end
  
  -- Extract zip
  print("Extracting luarocks...")
  if not extract_zip(zip_file, paths.temp_dir) then
    print_error("Failed to extract luarocks")
    return false
  end
  
  -- Find install.bat
  local install_bat
  local found = false
  local files = fn.readdir(paths.temp_dir)
  for _, file in ipairs(files) do
    if fn.isdirectory(paths.temp_dir .. "/" .. file) == 1 then
      local subdir = paths.temp_dir .. "/" .. file
      local subfiles = fn.readdir(subdir)
      for _, subfile in ipairs(subfiles) do
        if subfile == "install.bat" then
          install_bat = subdir .. "/" .. subfile
          found = true
          break
        end
      end
    end
    if found then break end
  end
  
  if not found then
    print_error("Could not find install.bat in the extracted files")
    return false
  end
  
  -- Run install.bat
  print("Installing luarocks...")
  local install_dir = fn.fnamemodify(paths.rocks_dir, ":p")
  local cmd = {fn.fnamemodify(install_bat, ":t"), "/NOREG", "/P", install_dir}
  
  local result = utility.shell(cmd, {cwd = fn.fnamemodify(install_bat, ":h")}, {verbose = true})
  if result.code ~= 0 then
    print_error("Failed to install luarocks: " .. (result.stderr or ""))
    return false
  end
  
  -- Cleanup
  fn.delete(zip_file)
  fn.delete(paths.temp_dir, "rf")
  
  return is_luarocks_installed()
end

-- Install luarocks on Linux
local function install_luarocks_linux()
  local paths = get_paths()
  local zip_url = "https://luarocks.github.io/luarocks/releases/luarocks-3.11.0-linux-x86_64.zip"
  local zip_file = paths.temp_dir .. "/luarocks.zip"
  
  -- Download zip
  print("Downloading luarocks for Linux...")
  if not download_file(zip_url, zip_file) then
    print_error("Failed to download luarocks")
    return false
  end
  
  -- Extract zip
  print("Extracting luarocks...")
  if not extract_zip(zip_file, paths.temp_dir) then
    print("Failed to extract luarocks")
    return false
  end
  
  -- Find luarocks binary
  local luarocks_binary
  local found = false
  local function find_luarocks(dir)
    local files = fn.readdir(dir)
    for _, file in ipairs(files) do
      local path = dir .. "/" .. file
      if file == "luarocks" and fn.filereadable(path) == 1 then
        luarocks_binary = path
        found = true
        return true
      elseif fn.isdirectory(path) == 1 then
        if find_luarocks(path) then return true end
      end
    end
    return false
  end
  
  find_luarocks(paths.temp_dir)
  
  if not found then
    print_error("Could not find luarocks binary in the extracted files")
    return false
  end
  
  -- Make executable and copy to bin directory
  utility.shell({"chmod", "+x", luarocks_binary})
  
  local result = utility.shell({"cp", luarocks_binary, paths.luarocks_bin})
  
  if result.code ~= 0 then
    print_error("Failed to copy luarocks binary: " .. (result.stderr or ""))
    return false
  end
  
  -- Cleanup
  fn.delete(zip_file)
  fn.delete(paths.temp_dir, "rf")
  
  return is_luarocks_installed()
end

-- Install luarocks based on the current OS
function M.install_luarocks()
  if is_luarocks_installed() then
    oprint("Luarocks is already installed at: " .. get_paths().luarocks_bin)
    return true
  end
  
  -- Create necessary directories
  create_dirs()
  
  local success
  if utility.is_windows() then
    success = install_luarocks_windows()
  elseif utility.is_linux() or utility.is_macos() then
    -- For macOS, we'll use the Linux version for now
    success = install_luarocks_linux()
  else
    print_error("Unsupported operating system")
    return false
  end
  
  if success then
    print("Luarocks installation successful!")
    return true
  else
    print_error("Luarocks installation failed")
    return false
  end
end

-- Ensure luarocks is installed (can be called directly)
function M.ensure_luarocks()
  return M.install_luarocks()
end

-- Initialize module
function M.setup()
  M.ensure_luarocks()
end

return M
