local success, mini_ai = pcall(require, "mini.ai")
if not success then
    vim.notify(
        "`mini.ai` is either not installed or not available.",
        vim.log.levels.ERROR
    )
    return
end

mini_ai.setup()
