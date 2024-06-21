local datapath = vim.fs.normalize(vim.fn.stdpath('data') --[[@as string]])
local lazypath = datapath .. '/lazy/lazy.nvim'
local uv = vim.uv or vim.loop

if not uv.fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable',
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

local lazy = require('lazy')
lazy.setup({
    {
        'tpope/vim-fugitive',
    },
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        opts = {
            ensure_installed = {
                'markdown',
                'markdown_inline',
                'vim',
                'vimdoc',
                'lua',
                'c',
                'java',
                'javascript',
                'typescript',
                'html',
                'css',
                'json',
                'go',
                'rust',
                'python',
            },
            ignore_install = {},
            sync_install = false,
            auto_install = true,
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            indent = {
                enable = true,
            },
        },
        config = function(_, opts)
            require('nvim-treesitter.configs').setup(opts)
        end,
    },
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.8',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-treesitter/nvim-treesitter',
        },
        opts = {
            defaults = {
                preview = false,
            },
        },
    },
    {
        'williamboman/mason.nvim',
        config = true,
    },
    {
        'williamboman/mason-lspconfig.nvim',
        dependendencies = {
            'williamboman/mason.nvim',
        },
        opts = {
            ensure_installed = {
                'jdtls',
                'pyright',
                'lua_ls',
                'rust_analyzer',
            },
        },
    },
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            'williamboman/mason-lspconfig.nvim',
        },
        config = function()
            require('wrlt.plugin.lspconfig').setup()
        end
    },
    {
        'mfussenegger/nvim-jdtls',
        dependencies = {
            'williamboman/mason-lspconfig.nvim',
        },
        config = function()
            require('wrlt.plugin.jdtls').setup()
        end
    },
})
