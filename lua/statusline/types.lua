---@meta

---@class fsr.statusline.Context
---@field winid integer
---@field bufnr integer

---@class fsr.statusline.Component
---@field rerender_event string|nil
---@field render fun(ctx: fsr.statusline.Context): string
