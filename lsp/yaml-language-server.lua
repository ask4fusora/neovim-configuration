---@type vim.lsp.Config
return {
    cmd = require("lsp.adapter.node_modules").cmd("yaml-language-server"),
    filetypes = {
        "yaml",
    },
    root_markers = { ".git" },
    settings = {
        -- https://github.com/redhat-developer/vscode-redhat-telemetry#how-to-disable-telemetry-reporting
        redhat = { telemetry = { enabled = false } },
        -- Formatting disabled by default in `yaml-language-server`.
        yaml = { format = { enable = true } },
    },
}
