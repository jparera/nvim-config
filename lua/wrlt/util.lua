---Utilities module
local M = {}

--- Checks if the given buffer file is in a git repository.
--- If that buffer is not backed by a file then it checks if
--- the current working directory is in a git repository.
---
--- @param  bufnr integer Buffer number. 0 for current buffer.
--- @return boolean #`true` if the buffer is in a git repository, `false` otherwise.
function M.is_buf_git_repository(bufnr)
    local path = vim.api.nvim_buf_get_name(bufnr)
    if path == '' then
        path = vim.fn.getcwd()
    end
    return vim.fn.finddir('.git', path .. ';') ~= ''
end

return M
