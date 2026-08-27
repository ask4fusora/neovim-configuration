local M = {}

local MAX_BUFFER_PICKER_LINES = 15

local api = vim.api

---@return integer[]
local function list_buffers()
    return vim.iter(vim.api.nvim_list_bufs())
        :filter(function(bufnr)
            return api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted
        end)
        :totable()
end

---@param bufnrs integer[]
---@return string[]
local function buffer_names(bufnrs)
    return vim.tbl_map(function(bufnr)
        local buf_name = api.nvim_buf_get_name(bufnr)

        if vim.bo[bufnr].buftype == "quickfix" then
            local winid = vim.fn.bufwinid(bufnr)
            local buftype = vim.api.nvim_eval_statusline("%q", {
                winid = winid,
            }).str
            local title = vim.w[winid].quickfix_title ---@type string

            buf_name = ("%s %s"):format(buftype, title)
        elseif buf_name == "" then
            buf_name = "untitled"
        else
            buf_name = vim.fn.fnamemodify(buf_name, ":~:.")
        end

        local modified_marker = vim.bo[bufnr].modified and " [+]" or ""

        return ("%s%s"):format(buf_name, modified_marker)
    end, bufnrs)
end

---@param buffer_paths string[]
---@return integer bufnr
local function create_picker_buffer(buffer_paths)
    local bufnr = api.nvim_create_buf(false, true)

    api.nvim_buf_set_lines(bufnr, 0, -1, false, buffer_paths)
    vim.bo[bufnr].modifiable = false
    vim.bo[bufnr].bufhidden = "wipe"

    return bufnr
end

---@param buffer_paths string[]
---@return integer width
---@return integer height
local function calc_buf_dimensions(buffer_paths)
    local width = 1
    local height = math.min(#buffer_paths, MAX_BUFFER_PICKER_LINES)

    for _, line in ipairs(buffer_paths) do
        width = math.max(width, vim.fn.strdisplaywidth(line))
    end

    width = math.min(
        width + vim.o.sidescrolloff * 2,
        vim.o.columns - vim.o.sidescrolloff * 2
    )

    return width, height
end

---@param bufnrs integer[]
---@param current_bufnr integer
---@param picker_bufnr integer
---@param width integer
---@param height integer
local function open_picker_win(
    bufnrs,
    current_bufnr,
    picker_bufnr,
    width,
    height
)
    local winid = api.nvim_open_win(picker_bufnr, true, {
        relative = "editor",
        style = "minimal",
        title = " Buffers ",
        title_pos = "left",
        width = width,
        height = height,
        row = math.floor((vim.o.lines - height) / 2),
        col = math.floor((vim.o.columns - width) / 2),
    })

    vim.wo[winid].cursorline = true
    vim.wo[winid].wrap = false

    -- Initially select the current buffer.

    for index, bufnr in ipairs(bufnrs) do
        if bufnr == current_bufnr then
            api.nvim_win_set_cursor(winid, { index, 0 })
            break
        end
    end

    return winid
end

---@param winid integer
local function close_picker(winid)
    if api.nvim_win_is_valid(winid) then
        api.nvim_win_close(winid, true)
    end
end

---@param winid integer
---@param bufnrs integer[]
local function open_buffer(winid, bufnrs)
    local index = unpack(api.nvim_win_get_cursor(winid))
    local selected_bufnr = bufnrs[index]

    close_picker(winid)

    if selected_bufnr and api.nvim_buf_is_valid(selected_bufnr) then
        api.nvim_set_current_buf(selected_bufnr)
    end
end

---@param current_winid integer
---@param picker_winid integer
---@param picker_bufnr integer
---@param bufnrs integer[]
---@param buffer_paths string[]
local function close_buffer(
    current_winid,
    picker_winid,
    picker_bufnr,
    bufnrs,
    buffer_paths
)
    local index = unpack(api.nvim_win_get_cursor(picker_winid))
    local selected_bufnr = bufnrs[index]

    local success = pcall(api.nvim_win_call, current_winid, function()
        api.nvim_buf_delete(selected_bufnr, {
            force = false,
        })
    end)

    if not success then
        vim.notify(
            "Cannot close buffer unsaved since last change.",
            vim.log.levels.ERROR
        )
        return
    end

    -- Remove selected buffer from memory.

    table.remove(bufnrs, index)
    table.remove(buffer_paths, index)

    -- Remove selected buffer from picker UI.

    vim.bo[picker_bufnr].modifiable = true
    api.nvim_buf_set_lines(picker_bufnr, 0, -1, false, buffer_paths)
    vim.bo[picker_bufnr].modifiable = false

    -- Update picker height.

    local _, height = calc_buf_dimensions(buffer_paths)
    if height == 0 then
        close_picker(picker_winid)
        return
    end

    api.nvim_win_set_config(picker_winid, {
        height = height,
    })
end

---@param current_winid integer
---@param picker_winid integer
---@param picker_bufnr integer
---@param bufnrs integer[]
---@param buffer_paths string[]
local function set_picker_keymaps(
    current_winid,
    picker_winid,
    picker_bufnr,
    bufnrs,
    buffer_paths
)
    vim.keymap.set("n", "<CR>", function()
        open_buffer(picker_winid, bufnrs)
    end, {
        buffer = picker_bufnr,
        nowait = true,
    })

    vim.keymap.set("n", "q", function()
        close_picker(picker_winid)
    end, {
        buffer = picker_bufnr,
        nowait = true,
    })

    vim.keymap.set("n", "<Esc>", function()
        close_picker(picker_winid)
    end, {
        buffer = picker_bufnr,
        nowait = true,
    })

    vim.keymap.set("n", "dd", function()
        close_buffer(
            current_winid,
            picker_winid,
            picker_bufnr,
            bufnrs,
            buffer_paths
        )
    end, {
        buffer = picker_bufnr,
        nowait = true,
    })
end

function M.open()
    local bufnrs = list_buffers()
    if #bufnrs == 0 then
        return
    end

    local current_bufnr = api.nvim_get_current_buf()
    local current_winid = api.nvim_get_current_win()
    local buffer_paths = buffer_names(bufnrs)
    local picker_bufnr = create_picker_buffer(buffer_paths)
    local width, height = calc_buf_dimensions(buffer_paths)
    local picker_winid =
        open_picker_win(bufnrs, current_bufnr, picker_bufnr, width, height)

    set_picker_keymaps(
        current_winid,
        picker_winid,
        picker_bufnr,
        bufnrs,
        buffer_paths
    )
end

return M
