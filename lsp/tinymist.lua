---@type vim.lsp.Config
return {
    cmd = { "tinymist", "lsp" },
    filetypes = { "typst" },
    root_markers = { ".git" },
    settings = {},
    before_init = function(params, config)
        if type(params.rootUri) == "string" then
            config.settings = vim.tbl_deep_extend("force", config.settings, {
                rootPath = vim.fs.abspath(
                    vim.uri_to_fname(params.rootUri --[[@as string]])
                ),
            })
        end

        if type(params.rootPath) == "string" then
            config.settings = vim.tbl_deep_extend("force", config.settings, {
                rootPath = vim.fs.abspath(params.rootPath --[[@as string]]),
            })
        end
    end,
}
