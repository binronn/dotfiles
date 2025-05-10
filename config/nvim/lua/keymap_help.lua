------------------
---- 通用函数 ----
------------------
--
-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",
--
local M = {}
function map(mode, shortcut, command, opts)
	local o = opts == nil and {noremap = true, silent = true} or opts
	-- vim.api.nvim_set_keymap(mode, shortcut, command, o)
	vim.keymap.set(mode, shortcut, command, o)
end
M.map = map

function mapd(mode, shortcut)
	local o = opts == nil and {noremap = true, silent = true} or opts
	-- vim.api.nvim_set_keymap(mode, shortcut, command, o)
	vim.keymap.del(mode, shortcut, command, o)
end
M.mapd = mapd

function map2(mode, shortcut, command, opts)
	local o = opts == nil and {noremap = true, silent = false} or opts
	vim.keymap.set(mode, shortcut, command, o)
end
M.map2 = map2

local function nmap(shortcut, command, opts)
	map("n", shortcut, command, opts)
end
M.nmap = nmap

local function nmapd(shortcut)
	mapd("n", shortcut)
end
M.nmapd = nmapd

local function vmap(shortcut, command, opts)
	map("v", shortcut, command, opts)
end
M.vmap = vmap

local function xmap(shortcut, command, opts)
	map("x", shortcut, command, opts)
end
M.xmap = xmap

local function cmap(shortcut, command, opts)
	map('c', shortcut, command, opts)
end
M.cmap = cmap

local function cmap2(shortcut, command, opts)
	map2('c', shortcut, command, opts)
end
M.cmap2 = cmap2

local function imap(shortcut, command, opts)
	map("i", shortcut, command, opts)
end
M.imap = imap

local function imap2(shortcut, command, opts)
	map2("i", shortcut, command, opts)
end
M.imap2 = imap2

-- 定义 nmap 函数
local function nmap2(key, cmd, opts)
	map2("n", key, cmd, opts)
end
M.nmap2 = nmap2

-- 定义 vmap 函数
local function vmap2(key, cmd, opts)
	map2("v", key, cmd, opts)
end
M.vmap2 = vmap2

return M
