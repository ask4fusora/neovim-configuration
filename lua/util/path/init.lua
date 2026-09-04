local M = {}

---@param path string
---@param folder_name string
------
---Check if `path` contains `folder_name`.
---
---*Note:* Converts `path` to an absolute path. Expands tilde (~) at the beginning of
---the path to the user's home directory. Does not check if the path exists,
---normalize the path, resolve symlinks or hardlinks (including `.` and `..`),
---or expand environment variables. Also converts `\` path separators to `/`.
function M.contains_folder(path, folder_name)
    local abs_path = vim.fs.abspath(path)

    return abs_path:find("/" .. folder_name .. "/") ~= nil
        or abs_path:find("^" .. folder_name .. "/") ~= nil
        or abs_path:find("/" .. folder_name .. "$") ~= nil
end

return M
