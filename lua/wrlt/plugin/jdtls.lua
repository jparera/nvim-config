local function try_launch_jdtls()
    local registry = require('mason-registry')
    local ok, pkg = pcall(registry.get_package, 'jdtls')
    if ok then
        if pkg:is_installed() then
            local config = {
                cmd = {
                    -- https://github.com/neovim/nvim-lspconfig/issues/2032#issuecomment-1200413852
                    vim.fn.exepath('jdtls'),
                    '--jvm-arg=-Xlog:disable',
                    '--jvm-arg=-Djava.import.generatesMetadataFilesAtProjectRoot=false',
                },
                filetypes = { 'java' },
                autostart = vim.fn.executable('jdtls') == 1,
                settings = {
                    java = {
                        autobuild = {
                            enabled = false,
                        },
                        configuration = {
                            updateBuildConfiguration = 'disabled',
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
            require('jdtls').start_or_attach(config)
        else
            vim.notify('JDT LS is not installed.', vim.log.levels.WARN)
        end
    else
        vim.notify('JDT LS is not found: ' .. pkg, vim.log.levels.WARN)
    end
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
