vim.opt.undofile = true

vim.opt.timeoutlen = 3000
vim.opt.ttimeoutlen = 100

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true

vim.opt.scrolloff = 8

vim.opt.list = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.termguicolors = true

local wrlt = vim.api.nvim_create_augroup('wrlt.set', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
    desc = 'Configures local options for programming languages.',
    group = wrlt,
    callback = function()
        vim.opt_local.signcolumn = 'yes'
        vim.opt_local.colorcolumn = { '80', '100' }
    end
})
