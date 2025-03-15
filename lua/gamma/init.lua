local utility = require("gamma.utility")
utility.require_dir("before/_init", true, true)

utility.require_dir("gamma/set", true, true)
require("gamma.lazy")

utility.require_dir("gamma/remap", true, true)

require("gamma.wrap")
require("gamma.writing")

utility.require_dir("gamma/autocmd", true, true)
local cmd = require("gamma.autocmd.cmd")
cmd.execute_cmds()
