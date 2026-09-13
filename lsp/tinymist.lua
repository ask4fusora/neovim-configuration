---@type vim.lsp.Config
return {
    cmd = { "tinymist", "lsp" },
    filetypes = { "typst" },
    root_markers = { ".git" },
    settings = {},
    before_init = function(params, config)
        if type(vim.env.TYPST_ROOT) == "string" then
            config.settings.rootPath =
                vim.fs.abspath(vim.env.TYPST_ROOT --[[@as string]])
        end

        if type(params.rootUri) == "string" then
            config.settings.rootPath = vim.fs.abspath(
                vim.uri_to_fname(params.rootUri --[[@as string]])
            )
        end

        if type(params.rootPath) == "string" then
            config.settings.rootPath =
                vim.fs.abspath(params.rootPath --[[@as string]])
        end
    end,
}
