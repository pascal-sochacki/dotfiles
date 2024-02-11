function ColorMyPencils(color)
	color = color or "rose-pine"
	vim.cmd.colorscheme(color)
end

return {
    {
        "rose-pine/neovim",
        name = "rose-pine",
        config = function()
            require('rose-pine').setup({})
            vim.cmd("colorscheme rose-pine")
            ColorMyPencils()
        end
    },
}
