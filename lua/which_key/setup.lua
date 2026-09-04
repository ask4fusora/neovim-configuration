local success, miniclue = pcall(require, "mini.clue")
if not success then
    vim.notify(
        "`mini.clue` is either not installed or not available.",
        vim.log.levels.ERROR
    )
    return
end

miniclue.setup({
    window = {
        delay = 200,
        config = {
            width = "auto",
        },
    },

    triggers = {
        { mode = "n", keys = "<Leader>" },
        { mode = "v", keys = "<Leader>" },
        { mode = "v", keys = "i" },
        { mode = "v", keys = "a" },
        { mode = "n", keys = "g" },
        { mode = "v", keys = "g" },
        { mode = "n", keys = "[" },
        { mode = "n", keys = "]" },
        { mode = "n", keys = "<C-G>" },
        { mode = "v", keys = "<C-G>" },
        { mode = "v", keys = "<C-K>" },
        { mode = "n", keys = "<C-W>" },
        { mode = "i", keys = "<C-X>" },
    },

    clues = {
        miniclue.gen_clues.builtin_completion(),
        miniclue.gen_clues.g(),
        miniclue.gen_clues.marks(),
        miniclue.gen_clues.registers(),
        miniclue.gen_clues.square_brackets(),
        miniclue.gen_clues.windows({ submode_resize = true }),
        miniclue.gen_clues.z(),
    },
})
