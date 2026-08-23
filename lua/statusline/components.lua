vim.api.nvim_set_hl(0, "fsr.statusline.StlFilenameModified", { bold = true })
vim.api.nvim_set_hl(0, "fsr.statusline.StlVimMode", {
    fg = vim.api.nvim_get_hl(0, { name = "Title", link = false }).fg,
    bold = true,
    reverse = true,
})

---@type fsr.statusline.Component[]
return {
    {
        render = function(ctx)
            local file_path = vim.api.nvim_buf_get_name(ctx.bufnr)
            if file_path == "" then
                return "%t%m"
            end

            local cwd = vim.fn.getcwd(ctx.winid)
            local relative_file_path = vim.fs.relpath(cwd, file_path)
                or file_path
            local dir = vim.fs.dirname(relative_file_path)
            local prefix = ""

            if dir and dir ~= "." then
                prefix = dir .. "/"
            end

            local hl_group = vim.bo[ctx.bufnr].modified
                    and "%$fsr.statusline.StlFilenameModified$"
                or ""

            return prefix .. hl_group .. "%t%*"
        end,
    },
    {
        rerender_event = "DiagnosticChanged",
        render = function(ctx)
            ---`diagnostic_counts[level]` where `level` (**1**-**4**) is the number of
            ---a diagnostic count.
            ---- **1** is error count.
            ---- **2** is warning count.
            ---- **3** is information count.
            ---- **4** is hint count.
            local diagnostic_counts = vim.diagnostic.count(ctx.bufnr)
            local icons = { "", "", "", "" }
            local hl_groups = {
                "DiagnosticError",
                "DiagnosticWarn",
                "DiagnosticInfo",
                "DiagnosticHint",
            }

            return vim.iter(diagnostic_counts)
                :map(function(level, count)
                    ---@cast level integer
                    ---@cast count integer
                    return "%$"
                        .. hl_groups[level]
                        .. "$"
                        .. icons[level]
                        .. " "
                        .. tostring(count)
                        .. "%*"
                end)
                :join(" ")
        end,
    },
    {
        render = function()
            return "%="
        end,
    },
    {
        render = function()
            return "%l:%c"
        end,
    },
    {
        render = function()
            local mode_name_by_key_code = {
                n = "NORMAL",
                no = "OPERATOR-PENDING",
                nt = "TERMINAL NORMAL",

                v = "VISUAL",
                V = "VISUAL LINE",
                [vim.keycode("<C-V>")] = "VISUAL BLOCK",

                s = "SELECT",
                S = "SELECT LINE",
                [vim.keycode("<C-S>")] = "SELECT BLOCK",

                i = "INSERT",
                R = "REPLACE",
                Rv = "VIRTUAL REPLACE",

                c = "COMMAND",
                r = "PROMPT",
                ["!"] = "SHELL",
                t = "TERMINAL",
            }

            local mode_key_code = vim.api.nvim_get_mode().mode
            local mode_name = mode_name_by_key_code[mode_key_code:sub(1, 2)]
                or mode_name_by_key_code[mode_key_code:sub(1, 1)]
                or mode_key_code

            return ("%%$fsr.statusline.StlVimMode$ %s %%*"):format(mode_name)
        end,
    },
    {
        render = function(ctx)
            return string.upper(vim.bo[ctx.bufnr].fileformat)
        end,
    },
    {
        render = function(ctx)
            return vim.bo[ctx.bufnr].filetype
        end,
    },
    {
        render = function(ctx)
            return string.upper(vim.bo[ctx.bufnr].fileencoding)
        end,
    },
}
