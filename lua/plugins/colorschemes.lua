return {
    {
        'marko-cerovac/material.nvim',
        name = 'material',
        lazy = true,
        
        priority = 1000,
    },

    {
        'sainnhe/sonokai',
        name = 'sonokai',
        lazy = true,
        
        priority = 1000,
    },

    {
        'elianiva/gruvy.nvim',
        name = 'gruvy',
        lazy = true,
        
        priority = 1000,
        dependencies = {{'rktjmp/lush.nvim'}},
    },
}
