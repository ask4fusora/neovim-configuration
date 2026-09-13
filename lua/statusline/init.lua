local M = {}

local components = require("statusline.components")

function M.render()
    -- NOTE: Yes, `:help statusline_winid`.
    local winid = tonumber(vim.g.statusline_winid)
        or vim.api.nvim_get_current_win()

    ---@type fsr.statusline.Context
    local ctx = {
        winid = winid,
        bufnr = vim.api.nvim_win_get_buf(winid),
    }

    return vim.iter(components)
        :map(function(c)
            return c.render(ctx)
        end)
        :filter(function(res)
            return type(res) == "string" and res ~= ""
        end)
        :join("  ")
end

return M
