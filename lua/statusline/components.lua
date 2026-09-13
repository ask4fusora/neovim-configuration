local function hl_text(hl_group, text)
    return ("%%$%s$%s%%*"):format(hl_group, text)
end

vim.api.nvim_set_hl(0, "fsr.statusline.FileModified", { bold = true })
vim.api.nvim_set_hl(0, "fsr.statusline.VimMode", {
    fg = vim.api.nvim_get_hl(0, { name = "Title", link = false }).fg,
    bold = true,
    reverse = true,
})

---@type fsr.statusline.Component[]
return {
    {
        render = function(ctx)
            local abs_file_path = vim.api.nvim_buf_get_name(ctx.bufnr)
            if abs_file_path == "" then
                return "%F%m"
            end

            local file_name_esc_seq = not vim.bo[ctx.bufnr].modified and "%t"
                or hl_text("fsr.statusline.FileModified", "%t")

            local cwd = vim.fn.getcwd(ctx.winid)
            local rel_file_path = vim.fs.relpath(cwd, abs_file_path)
            local file_path = rel_file_path or abs_file_path
            local dirname = vim.fs.dirname(file_path)
            if dirname == "." then
                return file_name_esc_seq
            end

            return ("%s/%s"):format(dirname, file_name_esc_seq)
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

            return vim.iter(ipairs(diagnostic_counts))
                :map(function(level, count)
                    ---@cast level integer
                    ---@cast count integer

                    return hl_text(
                        hl_groups[level],
                        ("%s %d"):format(icons[level], count)
                    )
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
            local mode_name_by_code = {
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

            local mode_code = vim.api.nvim_get_mode().mode
            local mode_text = mode_name_by_code[mode_code:sub(1, 2)]
                or mode_name_by_code[mode_code:sub(1, 1)]
                or mode_code

            return hl_text("fsr.statusline.VimMode", (" %s "):format(mode_text))
        end,
    },
    {
        render = function(ctx)
            local line_ending_by_file_format = {
                unix = "LF",
                dos = "CRLF",
                mac = "CR",
            }

            return line_ending_by_file_format[vim.bo[ctx.bufnr].fileformat]
        end,
    },
    {
        render = function(ctx)
            return require("util.string").title_case(vim.bo[ctx.bufnr].filetype)
        end,
    },
    {
        render = function(ctx)
            return string.upper(vim.bo[ctx.bufnr].fileencoding)
        end,
    },
}
