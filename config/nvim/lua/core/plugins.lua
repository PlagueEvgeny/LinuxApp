local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", "--branch=stable", -- latest stable release
        lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{'lewis6991/gitsigns.nvim'},
    {'akinsho/toggleterm.nvim'},
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.1',
        dependencies = {
            'nvim-lua/plenary.nvim'
        }
    },
    {
        "folke/which-key.nvim",
        branch = "v3"
    },
    {'phaazon/hop.nvim'},
	{'nvim-treesitter/nvim-treesitter'},
	{'joshdick/onedark.vim'},
	{'projekt0n/github-nvim-theme'},
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v2.x",
        dependencies = {
            "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim", "s1n7ax/nvim-window-picker"
        }
    },
    {'neovim/nvim-lspconfig'},
    {'hrsh7th/cmp-nvim-lsp'},
    {'hrsh7th/cmp-buffer'}, 
    {'hrsh7th/cmp-path'},
    {'hrsh7th/cmp-cmdline'},
    {'hrsh7th/nvim-cmp'},
    {'windwp/nvim-autopairs'},
    {'windwp/nvim-ts-autotag'},
    {'Djancyp/outline'},
    {
        "williamboman/mason.nvim", 
        build = ":MasonUpdate"
    },
    {
        "akinsho/bufferline.nvim", 
        dependencies = {'nvim-tree/nvim-web-devicons'}
    },
    {'terrortylor/nvim-comment'},
    {
        'glepnir/dashboard-nvim',
        event = 'VimEnter', 
        dependencies = {
            'nvim-tree/nvim-web-devicons'
        } 
    },
    {
        'nvim-lualine/lualine.nvim',
        dependencies = {
            'nvim-tree/nvim-web-devicons', 'linrongbin16/lsp-progress.nvim'
        }
    },
})
