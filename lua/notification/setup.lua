local success, mn = pcall(require, "mini.notify")
if not success then
    vim.notify(
        "`mini.notify` is either not installed or not available.",
        vim.log.levels.ERROR
    )
    return
end

mn.setup({
    window = {
        max_width_share = 0.618,
    },
})
