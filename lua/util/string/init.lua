local M = {}

---@param orig_str string
---@param pattern string
---@return boolean
function M.starts_with(orig_str, pattern)
    return orig_str:sub(1, #pattern) == pattern
end

---@param str string
---@return string
function M.title_case(str)
    return (
        str:gsub("(%a)([%w]*)", function(first, rest)
            return first:upper() .. rest:lower()
        end)
    )
end

return M
