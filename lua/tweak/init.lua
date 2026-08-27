local M = {}

local NU_START_TIMEOUT_MS = 3000

---Opens `path` with Nushell's `start` method, or returns (but does not show)
---an error message on failure.
---
---Can also be invoked with `:Open`.
---
---Expands "~/" and environment variables in filesystem paths.
---
---Examples:
---
---```lua
----- Asynchronous.
---vim.ui.open("https://neovim.io/")
---vim.ui.open("~/path/to/file")
----- Use the "osurl" command to handle the path or URL.
---vim.ui.open("gh#neovim/neovim!29490", { cmd = { 'osurl' } })
----- Synchronous (wait until the process exits).
---local cmd, err = vim.ui.open("$VIMRUNTIME")
---if cmd then
---  cmd:wait()
---end
---```
------
---@param path string Path or URL to open.
---@param opts? vim.ui.open.Opts Options.
---@return vim.SystemObj|nil # Command object, or nil if not found.
---@return nil|string # Error message on failure, or nil on success.
function M.nu_start(path, opts)
    opts = opts or {}

    if not opts.cmd and vim.fn.executable("nu") == 0 then
        return nil, "`nu` is not an executable."
    end

    local is_uri = path:match("%w+:")
    if not is_uri then
        path = vim.fs.normalize(path)
    end

    ---@type string[]
    local cmd
    ---@type vim.SystemOpts
    local job_opts = {
        text = true,
        detach = true,
        timeout = NU_START_TIMEOUT_MS,
    }

    if opts.cmd then
        cmd = vim.list_extend(opts.cmd --[[@as string[] ]], { path })

        if cmd[1] == "xdg-open" then
            job_opts.stdout = false
            job_opts.stderr = false
        end
    else
        cmd = {
            "nu",
            "--no-config-file",
            "--no-std-lib",
            "--no-history",
            "-c",
            ("start '%s'"):format(path),
        }
    end

    return vim.system(cmd, job_opts), nil
end

return M
