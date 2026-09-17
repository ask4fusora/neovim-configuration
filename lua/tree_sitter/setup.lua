local success, arborist = pcall(require, "arborist")
if not success then
    vim.notify(
        "`arborist` is either not installed or not available.",
        vim.log.levels.ERROR
    )
    return
end

arborist.setup({
    update_cadence = "weekly",
    install_popular = true,
    ensure_installed = {
        "moonbit",
        "moonbit_mbtp",
        "markdown",
        "markdown_inline",
        "typst",
        "mermaid",
        "astro",
        "zig",
        "rust",
        "c",
        "cpp",
        "php",
        "ruby",
        "odin",
        "sql",
        "lua",
        "luap",
        "luadoc",
        "luau",
        "typescript",
        "tsx",
        "toml",
        "json",
        "nu",
        "powershell",
        "bash",
    },
    overrides = {
        moonbit = {
            url = "https://github.com/moonbitlang/tree-sitter-moonbit",
        },
        moonbit_mbtp = {
            url = "https://github.com/moonbitlang/tree-sitter-moonbit",
            location = "grammars/mbtp",
        },
        nuon = {
            url = "https://github.com/melMass/tree-sitter-nuon",
        },
    },
})
