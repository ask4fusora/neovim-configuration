local folder_name = require("project_settings").PROJECT_SETTINGS_FOLDER_NAME
local project_settings_dir = vim.fs.joinpath(vim.fn.getcwd(), folder_name)

if vim.fn.isdirectory(project_settings_dir) == 1 then
    -- `runtimepath` is a string, with `,` as separator.
    vim.o.runtimepath = table.concat({
        vim.o.runtimepath,
        project_settings_dir,
    }, ",")
end
