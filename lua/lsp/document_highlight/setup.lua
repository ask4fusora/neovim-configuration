local DEBOUNCE_DELAY_MS = 100

local debounce_fn = require("neovim.util").debounce_fn

---@type integer?
local under_cursor_request_id = nil

local function document_highlight()
    local clients = vim.lsp.get_clients({ bufnr = 0 })

    for _, client in ipairs(clients) do
        local _, request_id = client:request(
            "textDocument/documentHighlight",
            vim.lsp.util.make_position_params(nil, client.offset_encoding),
            function(err, result, context, config)
                if context.request_id ~= under_cursor_request_id then
                    return
                end

                vim.lsp.buf.clear_references()

                if result then
                    vim.lsp.handlers["textDocument/documentHighlight"](
                        err,
                        result,
                        context,
                        config
                    )
                end
            end
        )

        -- Update `under_cursor_request_id` to the latest request ID.
        under_cursor_request_id = request_id
    end
end

vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = vim.api.nvim_create_augroup(
        "fsr.lsp.LspHighlightDocument",
        { clear = true }
    ),
    callback = debounce_fn(document_highlight, DEBOUNCE_DELAY_MS),
})
