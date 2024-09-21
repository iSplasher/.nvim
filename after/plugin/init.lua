local utility = require('gamma.utility')

if package.loaded.leaderf then
	if not vim.g.vscode then
        if not vim.g.Lf_fuzzyEngine_C then
            utility.print_error("LeaderF: Performant Fuzzy engine not found. Install with :LeaderfInstallCExtension")
        end
    end
end
