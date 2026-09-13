---@meta

---@class fsr.initializer.Registration
---@field event string
---@field pattern string|string[]?
---@field once boolean?
---@field module_names string[]

---@class fsr.initializer.Module
---@field exec fun(args: vim.api.keyset.create_autocmd.callback_args)
