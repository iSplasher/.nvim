local utility = require("gamma.utility")
utility.require_dir("before/_init", true, true)

require("gamma.set")
require("gamma.lazy")

utility.require_dir("gamma/remap", true, true)

require("gamma.wrap")
require("gamma.writing")
require("gamma.session")
