local utility = require("gamma.utility")
utility.require_dir("before/_init", true, true)
-- utility.require_dir("before/_init", true, true)

require("gamma.set")
require("gamma.ui")
require("gamma.lazy")

utility.require_dir("gamma/remap", true, true)

require("gamma.wrap")
require("gamma.writing")
require("gamma.session")

utility.require_dir("gamma/autocmd", true, true)
local cmd = require("gamma.autocmd.cmd")
cmd.execute_cmds()
