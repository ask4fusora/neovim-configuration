local success, tp = pcall(require, "typst-preview")
if not success then
    vim.notify(
        "`typst-preview` is either not installed or not available.",
        vim.log.levels.ERROR
    )
    return
end

tp.setup({
    dependencies_bin = {
        tinymist = "tinymist",
        websocat = "websocat",
    },
})
