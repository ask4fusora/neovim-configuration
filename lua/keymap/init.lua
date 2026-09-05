local M = {}

---@param lhs string
---@param rhs string
------
---Add Command-line abbreviation for `lhs` to `rhs`. Abbreviation replacement
---for `lhs` only happens when `lhs` is a command (no-space word, as the first
---argument of the Command-line).
---`rhs` may contain spaces.
function M.set_cabbrev(lhs, rhs)
    assert(lhs:find(" ") == nil, "`lhs` cannot contain spaces.")

    vim.keymap.set("ca", lhs, function()
        if vim.fn.getcmdtype() == ":" and vim.fn.getcmdline() == lhs then
            return rhs
        end

        return lhs
    end, { expr = true })
end

return M
