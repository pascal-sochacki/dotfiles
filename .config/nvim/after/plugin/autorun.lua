
local attach_to_buffer = function (output_bufnr, command, pattern)
    vim.api.nvim_create_autocmd("BufWritePost", {
        group = vim.api.nvim_create_augroup("pascal-autorun", {clear = true}),
        pattern = pattern,
        callback = function ()

            local append_data = function (_, data)
                if data then
                    vim.api.nvim_buf_set_lines(output_bufnr, -1, -1, false, data)
                end
            end

            vim.api.nvim_buf_set_lines(output_bufnr, 0, -1, false, {"auto run output:"})
            vim.fn.jobstart(command, {
                stdout_buffered = true,
                on_stdout = append_data,
                on_stderr = append_data,
            })
        end

    })
end

vim.api.nvim_create_user_command("AutoRun", function ()
    vim.cmd('vnew')

    local bufnr = vim.api.nvim_get_current_buf()
    local command = vim.split(vim.fn.input("Command: "), " ")
    local pattern = vim.fn.input("Pattern: ")

    attach_to_buffer(bufnr, command, pattern)
end, {})
