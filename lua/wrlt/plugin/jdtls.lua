local function check_installed_package(name)
    local registry = require('mason-registry')
    local ok, pkg = pcall(registry.get_package, name)
    if ok then
        if not pkg:is_installed() then
            vim.notify(name .. ' is not installed.', vim.log.levels.WARN)
            return
        end
    else
        vim.notify(name .. ' is not found.', vim.log.levels.WARN)
        return
    end
    return pkg
end

local function try_launch_jdtls()
    if not check_installed_package('jdtls') then
        return
    end

    local config = {
        autostart = vim.fn.executable('jdtls') == 1,
        cmd = {
            -- https://github.com/neovim/nvim-lspconfig/issues/2032#issuecomment-1200413852
            vim.fn.exepath('jdtls'),
            '--jvm-arg=-Xlog:disable',
            '--jvm-arg=-Djava.import.generatesMetadataFilesAtProjectRoot=false',
        },
        filetypes = { 'java' },
        init_options = {
            bundles = {
            },
        },
        settings = {
            java = {
                autobuild = {
                    enabled = false,
                },
                configuration = {
                    updateBuildConfiguration = 'automatic',
                },
                eclipse = {
                    downloadSources = true,
                },
                implementationsCodeLens = {
                    enabled = true,
                },
                jdt = {
                    ls = {
                        protobufSupport = {
                            enabled = true,
                        },
                    },
                },
                maven = {
                    downloadSources = true,
                },
                referencesCodeLens = {
                    enabled = true,
                },
                references = {
                    includeDecompiledSources = false,
                },
                symbols = {
                    includeSourceMethodDeclarations = true,
                },
                signatureHelp = {
                    enabled = true,
                    description = {
                        enabled = true,
                    },
                },
            },
        },
    }

    if check_installed_package('java-debug-adapter') then
        local jda_plugin_path = vim.env.MASON .. '/share/java-debug-adapter/com.microsoft.java.debug.plugin.jar'
        table.insert(config.init_options.bundles, jda_plugin_path)
    end

    local jdtls = require('jdtls')
    jdtls.extendedClientCapabilities.actionableNotificationSupported = true
    config.handlers = {
        ['language/actionableNotification'] = function(err, result)
            if err then
                vim.notify(err, vim.log.levels.ERROR)
            end
            local opts = {
                prompt = result.message,
                format_item = function(item)
                    return item.title
                end
            }
            local function on_choice(item)
                if item then
                    vim.lsp.buf.execute_command(item)
                end
            end
            vim.ui.select(result.commands, opts, on_choice)
        end,
    }
    jdtls.start_or_attach(config)
end

local function try_attach_jdtls()
    require('mason-registry').refresh(vim.schedule_wrap(try_launch_jdtls))
end

local M = {
    setup = function()
        local wrlt = vim.api.nvim_create_augroup('wrlt.plugin.jdtls', { clear = true })
        vim.api.nvim_create_autocmd('FileType', {
            desc = 'Attaches JDT LS to java buffer.',
            pattern = { 'java' },
            group = wrlt,
            callback = try_attach_jdtls
        })
    end,
}

return M
