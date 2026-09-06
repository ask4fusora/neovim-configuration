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

---@param formatter fsr.formatter.Formatter.LanguageServer
local function format_with_language_server(formatter)
    vim.lsp.buf.format({
        filter = function(client)
            return client.name == formatter.language_server.name
        end,
    })
end

---@return integer start_linenr 0-indexed.
---@return integer end_linenr 0-indexed. Already is exclusive.
local function format_range()
    ---@type string
    local mode = vim.fn.mode()
    local mode_char = mode:sub(1, 1)

    -- If normal mode, range is the entire buffer.
    if mode_char == "n" then
        return 0, vim.api.nvim_buf_line_count(0)
    end

    -- If visual mode, range is the selected lines.
    if mode_char == "v" or mode_char == "V" or mode_char == "" then
        local cursor_linenr = vim.fn.line(".")
        local visual_end_linenr = vim.fn.line("v")

        -- Decrease by 1 to convert 1-indexed (line number) to 0-indexed.
        local start_linenr = math.min(cursor_linenr, visual_end_linenr) - 1
        -- Should be exclusive, so we do not need to reduce by 1 here.
        local end_linenr = math.max(cursor_linenr, visual_end_linenr)

        return start_linenr, end_linenr
    end

    -- Return nothing otherwise.
    return 0, 0
end

---@param formatter fsr.formatter.Formatter.External
local function format_with_external_command(formatter)
    local buffer_path = vim.api.nvim_buf_get_name(0)

    local command = { formatter.external.command }

    for _, argument in ipairs(formatter.external.arguments or {}) do
        argument = argument:gsub("{buffer_path}", buffer_path)
        command[#command + 1] = argument
    end

    local start_linenr, end_linenr = format_range()
    local stdin = vim.api.nvim_buf_get_lines(0, start_linenr, end_linenr, true)

    local format_result = vim.system(command, {
        text = true,
        stdin = stdin,
    }):wait()

    if format_result.code ~= 0 then
        vim.notify(format_result.stderr, vim.log.levels.ERROR)
        return
    end

    local stdout = format_result.stdout
    assert(type(stdout) == "string", "`stdout` should be text.")
    ---@cast stdout string

    -- `vim.system` normalize stdout line endings to `\n`.
    local formatted_lines = vim.split(stdout, "\n", {
        plain = true,
        trimempty = true,
    })

    vim.api.nvim_buf_set_lines(
        0,
        start_linenr,
        end_linenr,
        true,
        formatted_lines
    )
end

---@param formatter fsr.formatter.Formatter.CodeAction
local function format_with_code_action(formatter)
    require("lsp.code_action").code_action_sync({
        apply = true,
        context = {
            only = { formatter.code_action },
        },
    })
end

---@param formatters fsr.formatter.Formatter[]?
------
---Format document range.
function M.format(formatters)
    formatters = formatters or default_formatters()
    if not next(formatters) then
        return
    end

    vim.iter(formatters):each(function(formatter)
        ---@cast formatter fsr.formatter.Formatter

        if formatter.language_server then
            format_with_language_server(
                formatter --[[@as fsr.formatter.Formatter.LanguageServer]]
            )
        elseif formatter.external then
            format_with_external_command(
                formatter --[[@as fsr.formatter.Formatter.External]]
            )
        elseif formatter.code_action then
            format_with_code_action(
                formatter --[[@as fsr.formatter.Formatter.CodeAction]]
            )
        end
    end)
end

return M
