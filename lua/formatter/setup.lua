local M = {}

fsr.formatter = {}

---@type table<string, fsr.formatter.Formatter[]?>
fsr.formatter.formatters_by_filetype = {}

---@param filetypes string[]
---@param formatters fsr.formatter.Formatter[]
function M.register_formatters(filetypes, formatters)
    vim.iter(filetypes):each(function(ft)
        fsr.formatter.formatters_by_filetype[ft] = formatters
    end)
end

M.register_formatters({ "typst" }, {
    { language_server = { name = "tinymist" } },
})

M.register_formatters({ "nu" }, {
    { external = { command = "nufmt", arguments = { "--stdin" } } },
})

M.register_formatters({ "yaml" }, {
    { language_server = { name = "yaml-language-server" } },
})

M.register_formatters({ "moonbit" }, {
    { language_server = { name = "moon-lsp" } },
})

M.register_formatters({ "lua" }, {
    {
        external = {
            command = "stylua",
            arguments = {
                "--syntax=LuaJit",
                "--stdin-filepath={buffer_path}",
                "-",
            },
        },
    },
})

M.register_formatters({ "typescriptreact", "typescript" }, {
    { language_server = { name = "vtsls" } },
    { language_server = { name = "biome" } },
    { code_action = "source.fixAll.biome" },
})

M.register_formatters({ "json", "jsonc" }, {
    { language_server = { name = "json-language-server" } },
})

M.register_formatters({ "markdown" }, {
    {
        external = {
            command = "dprint",
            arguments = {
                "fmt",
                "--stdin=md",
            },
        },
    },
})

return M
