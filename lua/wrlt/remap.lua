local util = require('wrlt.util')

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

--- Autocommand callback args.
--- @class AutocommandCallbackArgs
--- @field id number Autocommand id.
--- @field event string Name of the triggered event.
--- @field group? number Autocommand group id if any.
--- @field match string Expanded value of <amatch>.
--- @field buf number Expanded value of <abuf>.
--- @field file string Expanded value of <afile>.
--- @field data any Arbitrary data passed from `nvim_exec_autocmds()`.

--- @alias AutocommandCallback fun(args: AutocommandCallbackArgs): any
--- @alias KeymapConfigGuard fun(args: AutocommandCallbackArgs): boolean

--- Key mapping config.
--- @class KeymapConfig
--- @field mode string|string[] Mode short-name.
--- @field lhs string Left-hand-side {lhs} of the mapping.
--- @field rhs string|function Right-hand-side {rhs} of the mapping.
--- @field desc string Human-readable description.
--- @field guard? KeymapConfigGuard Guard mapping register behind this check function.
--- @field global? boolean Global mapping.

--- Create a buffer-local key mapping.
--- @param mode string|string[] Mode short-name.
--- @param lhs string Left-hand-side {lhs} of the mapping.
--- @param rhs string|function Right-hand-side {rhs} of the mapping.
--- @param desc string Human-readable description.
--- @param guard? KeymapConfigGuard Guard mapping register behind this check function.
--- @return KeymapConfig
local function map(mode, lhs, rhs, desc, guard)
    return {
        mode = mode,
        lhs = lhs,
        rhs = rhs,
        desc = desc,
        guard = guard,
    }
end

--- Makes a |vim.keymap.set| options.
---
--- @param desc string Keymap description.
--- @param bufnr? integer Buffer number used for local buffer mappings.
---
--- @return vim.keymap.set.Opts #Options.
local function set_opts(desc, bufnr)
    return {
        desc = desc,
        buffer = bufnr,
    }
end

--- Creates `autocommand` callback function that set key mapping configs.
--- @param configs KeymapConfig[] Key map configs.
--- @return fun(args: AutocommandCallbackArgs): boolean|nil # Callback function.
local function callback_set_keymap_configs(configs)
    return function(args)
        for _, config in ipairs(configs) do
            if not config.guard or config.guard(args) then
                vim.keymap.set(config.mode, config.lhs, config.rhs,
                    set_opts(config.desc, config.global and nil or args.buf))
            end
        end
    end
end

vim.keymap.set('n', 'Q', '<nop>')
vim.keymap.set('n', '<M-e>', vim.cmd.Ex)

-- Global mappings to move lines
vim.keymap.set('n', '<M-j>', ':m .+1<CR>==', set_opts('Move line down.'))
vim.keymap.set('n', '<M-k>', ':m .-2<CR>==', set_opts('Move line up.'))
vim.keymap.set('i', '<M-j>', '<Esc>:m .+1<CR>==gi', set_opts('Move line down.'))
vim.keymap.set('i', '<M-k>', '<Esc>:m .-2<CR>==gi', set_opts('Move line up.'))
vim.keymap.set('v', '<M-j>', ":m '>+1<CR>gv=gv", set_opts('Move selection down.'))
vim.keymap.set('v', '<M-k>', ":m '<-2<CR>gv=gv", set_opts('Move selection up.'))

local wrlt = vim.api.nvim_create_augroup('wrlt.remap', { clear = true })

local jdtls = require('wrlt.jdtls')
vim.api.nvim_create_autocmd('FileType', {
    desc = 'Map keys for java files.',
    pattern = 'java',
    group = wrlt,
    callback = callback_set_keymap_configs {
        map('n', '<M-B>', jdtls.build_workspace, '[JDTLS] Build buffer workspace.'),
        map('n', '<M-o>', jdtls.organize_imports, '[JDTLS] Organize buffer imports.'),
    },
})

--- Lazy load of an optional module.
---
--- @param module string module name.
local function optional(module)
    return setmetatable({}, {
        __index = function(_, key)
            return function(...)
                local ok, m = pcall(require, module)
                if ok then
                    local v = m[key]
                    if type(v) == 'function' then
                        return v(...)
                    else
                        return v
                    end
                else
                    vim.notify(module .. ' is not found.')
                end
            end
        end,
    })
end

--- @module 'telescope.builtin'
local builtin = optional('telescope.builtin')

--- @return string|function rhs, string desc, KeymapConfigGuard? guard, boolean? global
local function lsp_definitions()
    local rhs = builtin.lsp_definitions
    return rhs, '[LSP] Select a symbol definition.'
end

vim.api.nvim_create_autocmd('LspAttach', {
    group = wrlt,
    desc = 'Map keys to vim.lsp.buf.*',
    callback = callback_set_keymap_configs {
        map('n', '<M-1>', vim.lsp.buf.code_action, '[LSP] Select a code action available at the current cursor position.'),
        map('n', '<M-2>', vim.lsp.buf.rename, '[LSP] Rename all references to the symbol under cursor.'),
        map('n', '<M-f>', vim.lsp.buf.format, '[LSP] Format buffer.'),
        map('n', 'gD', lsp_definitions()),
        map('n', 'gd', lsp_definitions()),
        map('n', '<LEADER>d', lsp_definitions()),
        map('n', '<LEADER>i', builtin.lsp_implementations, '[LSP] Select a symbol implementation.'),
        map('n', '<LEADER>r', builtin.lsp_references, '[LSP] Select a symbol reference.'),
    }
})

vim.api.nvim_create_autocmd('User', {
    desc = 'Map keys for plugins.',
    pattern = 'LazyLoad',
    group = wrlt,
    callback = function(args)
        if args.data == 'telescope.nvim' then
            vim.keymap.set('n', '<M-T>', vim.cmd.Telescope, set_opts('Open Telescope.'))
            vim.keymap.set('n', '<M-b>', builtin.buffers, set_opts('Select a buffer.'))
            vim.keymap.set('n', '<M-a>', builtin.find_files, set_opts('Select a file.'))
            vim.keymap.set('n', '<M-g>', builtin.git_files, set_opts('Select a git file.'))
            vim.keymap.set('n', '<M-x>', builtin.lsp_dynamic_workspace_symbols, set_opts('Search for a symbol.'))
            vim.keymap.set('n', '<M-s>', builtin.grep_string, set_opts('Search file contains a string.'))
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
