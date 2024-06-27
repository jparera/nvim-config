vim.opt.undofile = true

vim.opt.timeoutlen = 3000
vim.opt.ttimeoutlen = 100

vim.opt.scrolloff = 8

vim.opt.list = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.termguicolors = true
vim.cmd.colorscheme('rose-pine-wrlt')

local wrlt = vim.api.nvim_create_augroup('wrlt.set', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
    desc = 'Configures local options for programming languages.',
    pattern = 'c,cpp,bash,java,lua,python,rust,tmux,zsh',
    group = wrlt,
    callback = function()
        vim.opt_local.number = true
        vim.opt_local.relativenumber = false
        vim.opt_local.cursorline = true
        vim.opt_local.signcolumn = 'yes'
        vim.opt_local.colorcolumn = { '80', '100' }
    end
})
