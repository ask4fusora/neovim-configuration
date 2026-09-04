local root_markers = {
    "moon.mod",
    "moon.mod.json",
    "moon.work",
}

---@type vim.lsp.Config
return {
    cmd = { "moon-lsp", "--stdio" },
    filetypes = { "moonbit" },
    root_markers = { root_markers, { ".git" } },
}
