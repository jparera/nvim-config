local wrlt = vim.api.nvim_create_augroup('wrlt.highlight', { clear = true })
vim.api.nvim_create_autocmd('ColorScheme', {
    desc = 'Clears CursorLine highlight.',
    group = wrlt,
    callback = function()
        vim.api.nvim_set_hl(0, 'CursorLine', {})
    end,
})

