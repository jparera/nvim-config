local lspconfig = require('lspconfig')
local util = require('lspconfig.util')
local lazy = require('lazy')

local function is_base_path(basepath, path)
    return (path .. '/'):sub(1, #(basepath) + 1) == basepath .. '/'
end

local function is_vim_path(root_dir)
    if root_dir == nil then
        return false
    end
    local configpath = vim.fs.normalize(vim.fn.stdpath('config'))
    local datapath = vim.fs.normalize(vim.fn.stdpath('data'))
    root_dir = vim.fs.normalize(root_dir)
    return is_base_path(configpath, root_dir) or is_base_path(datapath, root_dir)
end

local function on_new_lua_ls_config(config, root_dir)
    if is_vim_path(root_dir) then
        local library = {}
        table.insert(library, vim.fs.normalize(vim.env.VIMRUNTIME) .. '/lua')
        for _, plugin in pairs(lazy.plugins()) do
            table.insert(library, vim.fs.normalize(plugin.dir) .. '/lua')
        end
        config.settings.Lua = {
            runtime = {
                version = 'LuaJIT',
                pathStrict = true,
            },
            diagnostics = {
                globals = { 'vim' }
            },
            workspace = {
                checkThirdParty = false,
                library = library,
            },
        }
    end
end

local on_setups = {}

on_setups.lua_ls = function(config)
    config.root_dir = function(filename)
        local path = vim.fs.normalize(vim.fs.dirname(filename))
        if is_vim_path(path) then
            return vim.fs.normalize(vim.fn.stdpath('config')) .. '/lua'
        end
    end
    config.on_new_config = util.add_hook_after(config.on_new_config, on_new_lua_ls_config)
end

local M = {}

M.setup = function()
    util.on_setup = util.add_hook_after(util.on_setup, function(config)
        local on_setup = on_setups[config.name]
        if on_setup then
            on_setup(config)
        end
    end)
    lspconfig.lua_ls.setup {}
    lspconfig.rust_analyzer.setup {}
end

return M
