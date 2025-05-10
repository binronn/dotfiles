local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({"git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath})
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo(
			{
				{"Failed to clone lazy.nvim:\n", "ErrorMsg"},
				{out, "WarningMsg"},
				{"\nPress any key to exit..."}
			},
			true,
			{}
		)
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = " " --- this line

vim.g.is_win32 = vim.fn.has('win32')
vim.g.is_unix = vim.fn.has('unix')

if vim.g.is_unix == 1 then
    vim.g.clipboard = 'wl-copy'
end

--------------------
---- 顺序不可变 ----
--------------------
---

require("lazy").setup("plugins")
require("config.basic_cfg")
require("config.compiles_cfg")
require("common_func")
require("autocmd")
require("keymaps")


vim.api.nvim_create_autocmd("VimEnter", {
	-- pattern = "*",
	once = true,
	callback = function()
		require("config.basic_cfg")
	end,
})
