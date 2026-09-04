local M = {}

---@param orig_str string
---@param pattern string
---@return boolean
function M.starts_with(orig_str, pattern)
    return orig_str:sub(1, #pattern) == pattern
end

return M
