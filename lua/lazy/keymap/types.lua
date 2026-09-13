---@meta

---@class fsr.lazy.keymap.Keymap
---@field modes string|string[] Mode "short-name" (see |nvim_set_keymap()|), or a list thereof.
---@field lhs string            Left-hand side |{lhs}| of the mapping.
---@field rhs string|function   Right-hand side |{rhs}| of the mapping, can be a Lua function.
---@field opts? vim.keymap.set.Opts
