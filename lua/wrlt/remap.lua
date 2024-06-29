local util = require('wrlt.util')
local jdtls = require('wrlt.jdtls')

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
--- @field desc string Human-readable description.
--- @field mode string|string[] Mode short-name.
--- @field lhs string Left-hand-side {lhs} of the mapping.
--- @field rhs string|function Right-hand-side {rhs} of the mapping.
--- @field guard? KeymapConfigGuard Guard mapping register behind this check function.
--- @field global? boolean Global mapping.

--- Create a buffer-local key mapping.
--- @param desc string Human-readable description.
--- @param mode string|string[] Mode short-name.
--- @param lhs string Left-hand-side {lhs} of the mapping.
--- @param rhs string|function Right-hand-side {rhs} of the mapping.
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
--- @return vim.keymap.set.Opts
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

vim.api.nvim_create_autocmd('FileType', {
    desc = 'Map keys for java files.',
    pattern = 'java',
    group = wrlt,
    callback = callback_set_keymap_configs {
        map('n', '<M-B>', jdtls.build_workspace, '[JDTLS] Build buffer workspace.'),
        map('n', '<M-o>', jdtls.organize_imports, '[JDTLS] Organize buffer imports.'),
    },
})


--- Checks if LSP client supports the given protocol method.
--- @param method string LSP protocol method.
--- @return KeymapConfigGuard # Guard function.
local function check_client_supports(method)
    return function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
        return client.supports_method(method)
    end
end

local function telescope_builtin()
    return setmetatable({}, {
        __index = function(_, index)
            return function(...)
                local ok, builtin = pcall(require, 'telescope.builtin')
                if ok then
                    builtin[index](...)
                else
                    vim.notify('Telescope is not installed.')
                end
            end
        end,
    })
end

local methods = vim.lsp.protocol.Methods
local lsp_implementations = telescope_builtin().lsp_implementations
local lsp_references = telescope_builtin().references

local function lsp_definitions()
    local rhs = telescope_builtin().lsp_definitions
    return rhs, '[LSP] Select a symbol definition.'
end

local function lsp_code_action()
    local desc = '[LSP] Select a code action available at the current cursor position.'
    local guard = check_client_supports(methods.textDocument_codeAction)
    return vim.lsp.buf.code_action, desc, guard
end

local function lsp_formatting()
    local desc = '[LSP] Format buffer.'
    local guard = check_client_supports(methods.textDocument_formatting)
    return vim.lsp.buf.format, desc, guard
end

vim.api.nvim_create_autocmd('LspAttach', {
    group = wrlt,
    desc = 'Map keys to vim.lsp.buf.*',
    callback = callback_set_keymap_configs {
        map('n', '<M-1>', lsp_code_action()),
        map('n', '<M-f>', lsp_formatting()),
        map('n', 'gD', lsp_definitions()),
        map('n', 'gd', lsp_definitions()),
        map('n', '<LEADER>d', lsp_definitions()),
        map('n', '<LEADER>i', lsp_implementations, '[LSP] Select a symbol implementation.'),
        map('n', '<LEADER>r', lsp_references, '[LSP] Select a symbol reference.'),
    }
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
