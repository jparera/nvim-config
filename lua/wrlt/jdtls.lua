local function buffer_root_dir(bufnr)
    if vim.bo[bufnr].buftype == 'nofile' then
        return assert(vim.uv.cwd())
    else
        local markers = { 'gradlew', 'mvnw' }
        return vim.fs.root(bufnr, markers) or assert(vim.uv.cwd())
    end
end

--- Check if package exists in mason registry and it is installed.
---
--- @param name string Package name.
--- @return Package? pkg, string? err
local function check_installed_package(name)
    local registry = require('mason-registry')
    local ok, pkg = pcall(registry.get_package, name)
    if ok then
        if not pkg:is_installed() then
            return nil, name .. ' is not installed.'
        end
    else
        return nil, name .. ' is not found.'
    end
    return pkg
end

local function try_start_ls(event)
    local jdtls, err_jdtls = check_installed_package('jdtls')
    if not jdtls and err_jdtls then
        vim.notify(err_jdtls, vim.log.levels.WARN)
        return
    end

    local root_dir = buffer_root_dir(event.buf)
    ---@type vim.lsp.ClientConfig
    local config = {
        cmd = {
            -- https://github.com/neovim/nvim-lspconfig/issues/2032#issuecomment-1200413852
            vim.fn.exepath('jdtls'),
            '--jvm-arg=-Xlog:disable',
            '--jvm-arg=-Djava.import.generatesMetadataFilesAtProjectRoot=false',
        },
        cmd_cwd = root_dir,
    }
    config.name = 'jdtls'
    config.root_dir = root_dir
    -- Client capabilities
    config.capabilities = vim.lsp.protocol.make_client_capabilities()
    -- Initialize options
    config.init_options = {
        bundles = {
        },
        extendedClientCapabilities = {
            actionableNotificationSupported = true,
            advancedOrganizeImportsSupport = true,
            classFileContentsSupport = true,
        },
    }
    local jda, err_jda = check_installed_package('java-debug-adapter')
    if jda then
        local jda_plugin_path = vim.env.MASON .. '/share/java-debug-adapter/com.microsoft.java.debug.plugin.jar'
        table.insert(config.init_options.bundles, jda_plugin_path)
    elseif err_jda then
        vim.notify(err_jda, vim.log.levels.WARN)
    end
    -- Settings
    config.settings = {
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
    }
    -- Handlers
    config.handlers = {}
    --- Handles language/actionableNotification method.
    ---
    --- Ask the client to display a particular message in the UI, and
    --- possible commands to execute.
    local function actionableNotificationHandler(err, result)
        if err then
            vim.notify(err, vim.log.levels.ERROR)
        end
        local opts = {
            prompt = result.message,
            format_item = function(item)
                return item.title
            end
        }
        local function on_choice(choice)
            if choice then
                vim.lsp.buf.execute_command(choice)
            end
        end
        vim.ui.select(result.commands, opts, on_choice)
    end
    config.handlers['language/actionableNotification'] = actionableNotificationHandler
    --- Handles language/status method.
    ---
    --- Sends a status to the client to be presented to users.
    local function statusHandler(err, result)
        if err then
            vim.notify(err, vim.log.levels.ERROR)
        end
        if result.type == 'Message' then
            vim.notify(result.message, vim.log.levels.WARN)
        end
    end
    config.handlers['language/status'] = statusHandler
    vim.lsp.start(config)
end

--- Returns a LSP client attached to requested buffer.
---
--- @param bufnr? number Buffer number (0 for current).
--- @return vim.lsp.Client | nil
local function get_client(bufnr)
    local filter = { name = 'jdtls' }
    bufnr = bufnr ~= 0 and bufnr or vim.api.nvim_get_current_buf()
    if bufnr then
        filter.bufnr = bufnr
    end
    local clients = vim.lsp.get_clients(filter)
    if #clients == 0 then
        return nil
    elseif #clients > 1 then
        vim.notify(#clients .. ' JDT LS instances are attached to buffer ' .. bufnr .. '.', vim.log.levels.WARN)
    end
    return clients[1]
end

--- Sends a request to the server and synchronously waits for the response.
---
--- This is a wrapper around {vim.jsp.client.request_sync}.
---
--- @param method string LS method name.
--- @param params table LSP request params.
--- @param timeout_ms? integer Maximum time in milliseconds to wait for a result. Defaults to 1000.
--- @param bufnr integer Buffer number (0 for current).
--- @param client? vim.lsp.Client LSP client.
---
--- @return any result, string? err, vim.lsp.Client client #Request result or assertable error.
local function request_sync(method, params, timeout_ms, bufnr, client)
    client = client or assert(get_client(bufnr), 'No JDT LS client attached to buffer ' .. bufnr .. '.')
    local response, err = client.request_sync(method, params, timeout_ms, bufnr or 0)
    if not response then
        return nil, err, client
    end
    if response.err then
        err = response.err.code .. ((': ' .. response.err.message) or '')
        return nil, err, client
    end
    return response.result, nil, client
end

local M = {}

local buildWorkspaceStatus = {
    FAILED = 0,
    SUCCEED = 1,
    WITH_ERROR = 2,
    CANCELLED = 3,
    [0] = {
        name = 'FAILED',
        description = 'Build workspace command failed. Check the fixlist for errors.',
    },
    [1] = {
        name = 'SUCCEED',
        description = 'Build workspace command succeed.',
    },
    [2] = {
        name = 'WITH_ERROR',
        description = 'Build workspace command completed with error. Check the fixlist for errors.',
    },
    [3] = {
        name = 'CANCELLED',
        description = 'Build workspace command was cancelled.',
    },
}

--- Executes text/buildWorkspace command for the current buffer.
local function build_workspace()
    local params = {
        true,
    }
    local function handler(err, result)
        if err then
            vim.notify(err, vim.log.levels.ERROR)
            return
        end
        vim.diagnostic.setqflist({
            open = (vim.diagnostic.count()[vim.diagnostic.severity.ERROR] or 0) > 0
        })
        local status = buildWorkspaceStatus[result]
        if status then
            vim.notify(status.description, status.logLevel or vim.log.levels.WARN)
        else
            vim.notify('Build workspace command exited with an unknown return code (' .. result .. ')',
                vim.log.levels.WARN)
        end
    end
    local client = get_client(0)
    if not client then
        vim.notify('The current buffer is not attached to a JDT LS server.', vim.log.levels.WARN)
        return
    end
    client.request('java/buildWorkspace', params, handler)
end

M.build_workspace = build_workspace

--- Executes java/organizeImports command for the current buffer.
local function organize_imports()
    local params = vim.lsp.util.make_range_params()
    local result, err, client = request_sync('java/organizeImports', params, nil, 0)
    if not result and err then
        vim.notify(err, vim.log.levels.WARN)
        return
    end
    if result then
        vim.lsp.util.apply_workspace_edit(result, client.offset_encoding)
    end
end

M.organize_imports = organize_imports

local function setup()
    local wrlt = vim.api.nvim_create_augroup('wrlt.jdtls', { clear = true })

    vim.api.nvim_create_autocmd('FileType', {
        desc = 'Attach JDT LS to java buffer.',
        pattern = { 'java' },
        group = wrlt,
        callback = function(args)
            local function callback()
                try_start_ls(args)
            end
            require('mason-registry').refresh(vim.schedule_wrap(callback))
        end
    })

    vim.api.nvim_create_autocmd('BufReadCmd', {
        desc = 'Read a file managed by JDT LS into a buffer.',
        pattern = { 'jdt://*' },
        group = wrlt,
        callback = function(args)
            --- @return integer | nil
            local function tagstack_peek_from_bufnr()
                local stack = vim.fn.gettagstack()
                local last = stack.items[stack.length]
                if last then
                    return last.from[1]
                end
            end

            local filter = { name = 'jdtls' }
            local from_bufnr = tagstack_peek_from_bufnr()
            if from_bufnr then
                filter.bufnr = from_bufnr
            end
            local timeout_ms = 5000
            local params = {
                uri = args.file,
            }
            local clients = vim.lsp.get_clients(filter)
            local result, err
            for _, client in ipairs(clients) do
                result, err = request_sync('java/classFileContents', params, timeout_ms, args.buf, client)
                if result then
                    break
                end
            end
            if not result then
                vim.notify('Cannot load class file contents: ' .. err, vim.log.levels.WARN)
                return
            end

            local lines = vim.split(result, '\r?\n')
            vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, lines)

            local options = vim.bo[args.buf]
            options.buftype = 'nofile'
            options.modifiable = false
            options.filetype = 'java'
            options.readonly = true
        end,
    })
end

M.setup = setup

return M
