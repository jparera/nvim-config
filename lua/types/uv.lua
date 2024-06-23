---@meta
---
-- Pseudo-Types
---@alias callable function | table | userdata
---@alias buffer string | table<integer,string>

---Exposes the luv Lua bindings for the libUV library
---that Nvim uses for networking, filesystem, and process management.
---@class uv
local M = {}

---Retrieve information about the file pointed to by path.
---Equivalent to stat(2).
---@param path string File path.
---@param callback? callable Enables async mode.
---@return table | nil, string, string #Returns information about the file or an assertable fail.
function M.fs_stat(path, callback) end

return M
