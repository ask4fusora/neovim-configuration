local M = {}

---@return fsr.formatter.Formatter.LanguageServer[]
local function default_formatters()
    return vim.iter(vim.lsp.get_clients({ bufnr = 0 }))
        :map(function(client)
            ---@cast client vim.lsp.Client
            ---@type fsr.formatter.Formatter.LanguageServer
            return { language_server = { name = client.name } }
        end)
        :totable()
end

---@return string[] lines
---@return integer start_linenr 0-indexed.
---@return integer end_linenr 0-indexed.
local function stdin_lines()
    ---@type string
    local mode = vim.fn.mode()
    local first_level_mode = mode:sub(1, 1)

    -- If normal mode, return the entire buffer.

    if first_level_mode == "n" then
        local line_count = vim.api.nvim_buf_line_count(0)
        return vim.api.nvim_buf_get_lines(0, 0, line_count, true), 0, line_count
    end

    -- If visual mode, return only the selected lines.

    if
        first_level_mode == "v"
        or first_level_mode == "V"
        or first_level_mode == ""
    then
        local cursor_linenr = vim.fn.line(".")
        local visual_end_linenr = vim.fn.line("v")
        -- Convert 1-indexed (line number) to 0-index.
        local start_linenr = math.min(cursor_linenr, visual_end_linenr) - 1
        -- Exclusive, also converting 1-indexed to 0-indexed.
        local end_linenr = math.max(cursor_linenr, visual_end_linenr)

        return vim.api.nvim_buf_get_lines(0, start_linenr, end_linenr, true),
            start_linenr,
            end_linenr
    end

    -- Return nothing otherwise.

    return {}, 0, 0
end

---@param formatters fsr.formatter.Formatter[]?
------
---Format document range.
function M.format(formatters)
    formatters = formatters or default_formatters()

    local buffer_path = vim.api.nvim_buf_get_name(0)

    vim.iter(formatters):each(function(formatter)
        if formatter.language_server then
            vim.lsp.buf.format({
                filter = function(client)
                    return client.name == formatter.language_server.name
                end,
            })
        elseif formatter.external then
            local command = { formatter.external.command }

            for _, argument in ipairs(formatter.external.arguments or {}) do
                argument = argument:gsub("{buffer_path}", buffer_path)
                command[#command + 1] = argument
            end

            local stdin, start_linenr, end_linenr = stdin_lines()

            local sys_obj = vim.system(command, {
                text = true,
                stdin = stdin,
            }):wait()

            if sys_obj.code ~= 0 then
                vim.notify(sys_obj.stderr, vim.log.levels.ERROR)
                return
            end

            local stdout = sys_obj.stdout
            assert(type(stdout) == "string", "`stdout` should be text.")
            ---@cast stdout string

            local stdout_lines = vim.split(stdout, "\n", { plain = true })

            if stdout_lines[#stdout_lines] == "" then
                table.remove(stdout_lines, #stdout_lines)
            end

            vim.api.nvim_buf_set_lines(
                0,
                start_linenr,
                end_linenr,
                true,
                stdout_lines
            )
        elseif formatter.code_action then
            require("lsp.code_action").code_action_sync({
                apply = true,
                context = {
                    only = { formatter.code_action },
                },
            })
        end
    end)
end

return M
