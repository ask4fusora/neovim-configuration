local M = {}

---@param text string
---@return string
function M.strip(text)
    return (text:gsub("\27%[[0-?]*[ -/]*[@-~]", ""))
end

return M
