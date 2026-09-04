local PROJECT_SETTINGS_FOLDER_NAME = ".nvim"
local project_settings_dir =
    vim.fs.joinpath(vim.fn.getcwd(), PROJECT_SETTINGS_FOLDER_NAME)

if vim.fn.isdirectory(project_settings_dir) == 1 then
    -- `runtimepath` is a string, with `,` as separator.
    vim.o.runtimepath = table.concat({
        vim.o.runtimepath,
        project_settings_dir,
    }, ",")
end
