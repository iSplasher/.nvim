-- Makes hlslens work with visual-multi
local M = {}
local config
local lensBak

local overrideLens = function(render, posList, nearest, idx, relIdx)
  local _ = relIdx
  local lnum, col = unpack(posList[idx])

  local text, chunks
  if nearest then
    text = ('[%d/%d]'):format(idx, #posList)
    chunks = { { ' ', 'Ignore' }, { text, 'VM_Extend' } }
  else
    text = ('[%d]'):format(idx)
    chunks = { { ' ', 'Ignore' }, { text, 'HlSearchLens' } }
  end
  render.setVirt(0, lnum - 1, col - 1, chunks, nearest)
end

function M.start()
  local hlslens = require('hlslens')
  if hlslens then
    config = require('hlslens.config')
    lensBak = config.override_lens
    config.override_lens = overrideLens
    hlslens.start()
  end
end

function M.exit()
  local hlslens = require('hlslens')
  if hlslens then
    config.override_lens = lensBak
    hlslens.start()
  end
end

return {
  {
    'kevinhwang91/nvim-hlslens',
    config = function()
      require('hlslens').setup {
        calm_down = true -- limit number of matches per pattern per buffer
      }

      local kopts = { noremap = true, silent = true }

      vim.api.nvim_set_keymap('n', 'n',
        [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
        kopts)
      vim.api.nvim_set_keymap('n', 'N',
        [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
        kopts)
      vim.api.nvim_set_keymap('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
      vim.api.nvim_set_keymap('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
      vim.api.nvim_set_keymap('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
      vim.api.nvim_set_keymap('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)

      -- visual-multi integration
      --vim.cmd([[
      --    aug VMlens
      --        au!
      --        au User visual_multi_start lua M.start()
      --        au User visual_multi_exit lua M.exit()
      --    aug END
      -- ]])
    end
  },

}
