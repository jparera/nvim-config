local util = require('wrlt.util')

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.keymap.set('n', 'Q', '<nop>')

vim.keymap.set('n', '<A-e>', vim.cmd.Ex)

-- Mappings to move lines
vim.keymap.set('n', '<A-j>', ':m .+1<CR>==')
vim.keymap.set('n', '<A-k>', ':m .-2<CR>==')
vim.keymap.set('i', '<A-j>', '<Esc>:m .+1<CR>==gi')
vim.keymap.set('i', '<A-k>', '<Esc>:m .-2<CR>==gi')
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv")

local wrlt = vim.api.nvim_create_augroup('wrlt.remap', { clear = true })
vim.api.nvim_create_autocmd('LspAttach', {
    group = wrlt,
    desc = 'Map keys to vim.lsp.buf.*',
    callback = function(args)
        local opts = { buffer = args.buf }
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.hover, opts)
        --vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<Leader>f', vim.lsp.buf.format, opts)
    end,
})
vim.api.nvim_create_autocmd('User', {
    desc = 'Map keys for plugins.',
    pattern = 'LazyLoad',
    group = wrlt,
    callback = function(args)
        if args.data == 'telescope.nvim' then
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<A-S-t>', vim.cmd.Telescope)
            vim.keymap.set('n', '<A-b>', builtin.buffers)
            vim.keymap.set('n', '<A-a>', builtin.find_files)
            vim.keymap.set('n', '<A-g>', builtin.git_files)
            vim.keymap.set('n', '<A-x>', builtin.lsp_references)
            vim.keymap.set('n', '<A-s>', function()
                builtin.grep_string {
                    preview = true,
                    search = vim.fn.input('Grep > '),
                }
            end)
        elseif args.data == 'vim-fugitive' then
            vim.keymap.set('n', '<A-S-g>', function()
                if util.is_buf_git_repository(0) then
                    vim.cmd.Git()
                else
                    vim.notify('There is no Git repository.', vim.log.levels.WARN)
                end
            end)
        end
    end,
})
