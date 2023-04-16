-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'


  use {
	  'nvim-telescope/telescope.nvim', tag = '0.1.1',
	  -- or                            , branch = '0.1.x',
	  requires = { {'nvim-lua/plenary.nvim'} }
  }


  -- Highlight, edit, and navigate code
  use('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate' })

  -- Git related
  use 'tpope/vim-fugitive'
  use 'tpope/vim-rhubarb'

  -- Detect tabstop and shiftwidth automatically
  use 'tpope/vim-sleuth'

  -- Classics

  use 'folke/which-key.nvim'

  -- Collab

  use 'jbyuki/instant.nvim'

  -- Colorschemes

  use({
    'marko-cerovac/material.nvim',
    as = 'material',
    config = function()
      vim.cmd('colorscheme material')
    end
  })

  use({
    'sainnhe/sonokai',
    as = 'sonokai',
    config = function()
      vim.cmd('colorscheme sonokai')
    end
  })

 use({
    'elianiva/gruvy.nvim',
    as = 'gruvy',
    requires = {{'rktjmp/lush.nvim'}},
    config = function()
      vim.cmd('colorscheme gruvy')
    end
  })

  -- LSP
  use {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v2.x',
    requires = {
      -- LSP Support
      {'neovim/nvim-lspconfig'},             -- Required
      {'folke/neodev.nvim'},
      {                                      -- Optional
      'williamboman/mason.nvim',
      run = function()
	pcall(vim.cmd, 'MasonUpdate')
      end,
    },
    {'williamboman/mason-lspconfig.nvim'}, -- Optional

    -- Autocompletion
    {'hrsh7th/nvim-cmp'},     -- Required
    {'hrsh7th/cmp-nvim-lsp'}, -- Required
    {'L3MON4D3/LuaSnip'},     -- Required
  }
}


end)
