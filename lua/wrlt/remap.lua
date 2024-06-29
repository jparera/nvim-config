local util = require('wrlt.util')

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.keymap.set('n', 'Q', '<nop>')

vim.keymap.set('n', '<M-e>', vim.cmd.Ex)

--- Makes a |vim.keymap.set| options.
---
--- @param desc string Keymap description.
--- @param bufnr? integer Buffer number used for local buffer mappings.
---
--- @return vim.keymap.set.Opts
local function set_opts(desc, bufnr)
    return {
        desc = desc,
        buffer = bufnr,
    }
end

-- Mappings to move lines
vim.keymap.set('n', '<M-j>', ':m .+1<CR>==', set_opts('Move line down.'))
vim.keymap.set('n', '<M-k>', ':m .-2<CR>==', set_opts('Move line up.'))
vim.keymap.set('i', '<M-j>', '<Esc>:m .+1<CR>==gi', set_opts('Move line down.'))
vim.keymap.set('i', '<M-k>', '<Esc>:m .-2<CR>==gi', set_opts('Move line up.'))
vim.keymap.set('v', '<M-j>', ":m '>+1<CR>gv=gv", set_opts('Move selection down.'))
vim.keymap.set('v', '<M-k>', ":m '<-2<CR>gv=gv", set_opts('Move selection up.'))

local wrlt = vim.api.nvim_create_augroup('wrlt.remap', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
    desc = 'Map keys for java.',
    pattern = 'java',
    group = wrlt,
    callback = function(args)
        local jdtls = require('wrlt.jdtls')
        vim.keymap.set('n', '<M-B>', jdtls.build_workspace,
            set_opts('[JDTLS] Build workspace.', args.buf))
        vim.keymap.set('n', '<M-o>', jdtls.organize_imports,
            set_opts('[JDTLS] Organize file imports.', args.buf))
    end
})
vim.api.nvim_create_autocmd('LspAttach', {
    group = wrlt,
    desc = 'Map keys to vim.lsp.buf.*',
    callback = function(args)
        local methods = vim.lsp.protocol.Methods
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client.supports_method(methods.textDocument_codeAction) then
            vim.keymap.set('n', '<M-1>', vim.lsp.buf.code_action,
                set_opts('[LSP] Select a code action available at the current cursor position.', args.buf))
        end
        if client.supports_method(methods.textDocument_formatting) then
            vim.keymap.set('n', '<M-f>', vim.lsp.buf.format, set_opts('[LSP] Format buffer.', args.buf))
        end
        local ok, builtin = pcall(require, 'telescope.builtin')
        if ok then
            vim.keymap.set('n', 'gD', builtin.lsp_definitions,
                set_opts('[LSP] Select a symbol definition.', args.buff))
            vim.keymap.set('n', 'gd', builtin.lsp_definitions,
                set_opts('[LSP] Select a symbol definition.', args.buff))
            vim.keymap.set('n', '<LEADER>d', builtin.lsp_definitions,
                set_opts('[LSP] Select a symbol definition.', args.buff))
            vim.keymap.set('n', '<LEADER>i', function()
                    builtin.lsp_implementations {
                        preview = true,
                    }
                end,
                set_opts('[LSP] Select a symbol implementation.', args.buff))
            vim.keymap.set('n', '<LEADER>r', function()
                    builtin.lsp_references {
                        preview = true,
                    }
                end,
                set_opts('[LSP] Select a symbol reference.', args.buff))
        end
    end,
})
vim.api.nvim_create_autocmd('User', {
    desc = 'Map keys for plugins.',
    pattern = 'LazyLoad',
    group = wrlt,
    callback = function(args)
        if args.data == 'telescope.nvim' then
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<M-T>', vim.cmd.Telescope, set_opts('Open Telescope.'))
            vim.keymap.set('n', '<M-b>', builtin.buffers, set_opts('Select a buffer.'))
            vim.keymap.set('n', '<M-a>', builtin.find_files, set_opts('Select a file.'))
            vim.keymap.set('n', '<M-g>', builtin.git_files, set_opts('Select a git file.'))
            vim.keymap.set('n', '<M-x>', builtin.lsp_dynamic_workspace_symbols)
            vim.keymap.set('n', '<M-s>', function()
                    builtin.grep_string {
                        preview = true,
                        search = vim.fn.input('Grep > '),
                    }
                end,
                set_opts('Search file contains a string.'))
        elseif args.data == 'vim-fugitive' then
            vim.keymap.set('n', '<M-G>', function()
                    if util.is_buf_git_repository(0) then
                        vim.cmd.Git()
                    else
                        vim.notify('There is no Git repository.', vim.log.levels.WARN)
                    end
                end,
                set_opts('Open Fugitive'))
        end
    end,
})
