require('compat')

-- Load all utility modules
local table_utils = require('gamma.utility.table')
local keymap_utils = require('gamma.utility.keymap')
local system_utils = require('gamma.utility.system')
local shell_utils = require('gamma.utility.shell')
local logging_utils = require('gamma.utility.logging')
local input_utils = require('gamma.utility.input')
local M = {}

-- Export all functions from table utilities
M.table_to_string = table_utils.table_to_string
M.format_table = table_utils.format_table
M.print_table = table_utils.print_table
M.merge_table = table_utils.merge_table
M.merge_tables = table_utils.merge_tables

-- Export all functions from keymap utilities
M.saved_maps = keymap_utils.saved_maps
M.saved_maps_d = keymap_utils.saved_maps_d

M.kmap = keymap_utils.kmap
M.get_saved_maps = keymap_utils.get_saved_maps
M.keymap_exists = keymap_utils.keymap_exists
M.type_keymap = keymap_utils.type_keymap

-- Export all functions from system utilities
M.get_os = system_utils.get_os
M.is_macos = system_utils.is_macos
M.is_mac = system_utils.is_mac
M.is_linux = system_utils.is_linux
M.is_windows = system_utils.is_windows
M.normalize_path_sep = system_utils.normalize_path_sep
M.create_cmd = system_utils.create_cmd
M.get_env = system_utils.get_env
M.env = system_utils.env
M.config_path = system_utils.config_path
M.data_path = system_utils.data_path
M.require_dir = system_utils.require_dir

-- Export all functions from shell utilities
M.shell = shell_utils.shell
M.which = shell_utils.which

-- Export all functions from logging utilities
M._print = logging_utils._print
M.print = logging_utils.print
M.print_error = logging_utils.print_error
M.print_warn = logging_utils.print_warn
M.print_debug = logging_utils.print_debug
M.notify = logging_utils.notify

-- Export all functions from input utilities
M.get_termcodes = input_utils.get_termcodes
M.transkey = input_utils.transkey
M.get_key = input_utils.get_key
M.canonicalize_key = input_utils.canonicalize_key

return M
