local keymap = require("keymap_help")
local map = keymap.map
local nmap = keymap.nmap
local vmap = keymap.vmap
local xmap = keymap.xmap
local cmap = keymap.cmap
local cmap2 = keymap.cmap2
local imap = keymap.imap
local imap2 = keymap.imap2
local nmap2 = keymap.nmap2
local vmap2 = keymap.vmap2

------------------------------------------------------------------------------------------
-- 取消无用 按键映射
------------------------------------------------------------------------------------------
--nmap('<leader>r', '<nop>')
--nmap('<leader>f', '<nop>')
nmap("<Space>", "<nop>")
vmap("<Space>", "<nop>")
xmap("<Space>", "<nop>")
------------------------------------------------------------------------------------------
-- Telescope 映射
------------------------------------------------------------------------------------------
-- cmap('te', 'Telescope')

------------------------------------------------------------------------------------------
-- CMake-tools 映射
------------------------------------------------------------------------------------------
-- cmap2("Cst", "CMakeSelectBuildType")
-- cmap2("Cb", "CMakeBuild")
-- cmap2("Cg", "CMakeGenerate")
-- cmap('SS', 'Leaderf! rg -g *.{}')

-- 重置工作目录
cmap2("Rw", "lua vim.g.reset_workspace_dir.get()")
cmap2("Rg", "cd %:h | lua vim.g.reset_workspace_dir_nop()")
------------------
---- VIM 相关 ----
------------------
--
-- 保存文件
nmap("<leader>fs", ":w<CR>")

-- 保存所有文件
nmap("<leader>fS", ":wa<CR>")

-- 关闭当前文件
nmap("<leader>fd", ": bp | bd! #<CR>")
--nmap('<leader>fo',':e ') -- 异常
vim.cmd "nmap <leader>fo :e "

-- 文件保存与退出
nmap("<leader>wq", ":wq<CR>")
nmap("<leader>wQ", ":wqa<CR>")

-- 文件不保存退出
-- nmap("<leader>q", ":q<CR>")
nmap("<leader>fq", "<cmd>lua if vim.bo.buftype == '' then vim.cmd('q') end<CR>")
nmap("qw", "<cmd>lua if vim.bo.buftype ~= '' then vim.cmd('q') end<CR>")
nmap("<leader>fQ", ":q!<CR>")

-- 上/下一个 buffer
nmap("<leader>fn", ":bn<CR>")
nmap("<leader>fp", ":bp<CR>")

-- 开启与关闭高亮
nmap("<leader>hl", ":set hlsearch<CR>")
nmap("<leader>hc", ":set nohlsearch<CR>")

-- 快速切换到行首行尾
nmap("H", "^")
xmap("H", "^")
vmap("H", "^")
nmap("L", "$")
xmap("L", "$")
vmap("L", "$")

-- 批量缩进
xmap("<<", "<gv")
xmap(">>", ">gv")

-- 关闭quickfix
nmap("<leader>wc", ":cclose<cr>")

-- 16进制打开文件
nmap("<leader>hx", ":%!xxd<cr>")

-- 16进制打开文件恢复到正常模式打开文件
nmap("<leader>hr", ":%!xxd -r<cr>")

-- 显示开始界面
--nmap('<leader>ho :Startify<CR>

-- 上一个文件分屏横向分屏
nmap("<leader>ls", ":vsplit #<CR> ")

-- 上一个文件垂直分屏
nmap("<leader>lv", ":split #<CR> ")
nmap("<leader>lo", ":e #<CR>")

-- 窗口切换
nmap("<leader>wk", "<C-w>k")
nmap("<leader>wl", "<C-w>l")
nmap("<leader>wh", "<C-w>h")
nmap("<leader>wj", "<C-w>j")
nmap("<leader>wp", ":wincmd p<CR>")
nmap("<leader>w=", "<C-w>=")
nmap("<leader>w|", "<C-w>|")

-- 窗口移动
nmap("<leader>wK", "<C-w>K")
nmap("<leader>wL", "<C-w>L")
nmap("<leader>wH", "<C-w>H")
nmap("<leader>wJ", "<C-w>J")

-- 窗口删除
nmap("<leader>wo", ":only<CR>")

-- 窗口尺寸调整
nmap2("<leader>ws", ":vertical resize ")
nmap2("<leader>wv", ":resize ")

-- 括号跳转
nmap("<C-h>", "%")
vmap("<C-h>", "%")

vim.keymap.set("t", "<Esc>", '<C-\\><C-n>', {noremap = true}) -- 在终端中按下 ESC 切换normal模式
-- 窗口跳转
-- nmap("<leader>1", ":1wincmd w<CR>")
-- nmap("<leader>2", ":2wincmd w<CR>")
-- nmap("<leader>3", ":3wincmd w<CR>")
-- nmap("<leader>4", ":4wincmd w<CR>")
-- nmap("<leader>5", ":5wincmd w<CR>")
-- nmap("<leader>6", ":6wincmd w<CR>")
-- nmap("<leader>7", ":7wincmd w<CR>")
-- nmap("<leader>8", ":8wincmd w<CR>")
-- nmap("<leader>9", ":9wincmd w<CR>")
-- nmap("<leader>0", ":0wincmd w<CR>")

------------------------------------------------------------------------------------------
-- 选中文字加括号引号
------------------------------------------------------------------------------------------
--
local wrappers = {
	double_quote = {'"', '"'},
	bracket = {"(", ")"},
	curly_brace = {"{", "}"}
}

function wrap_selection(a, b)

    local cmd = string.format("'<,'>s/\\%%V\\(.*\\)\\%%V/%s\\1%s/", a, b)
    vim.cmd(cmd)
end
vim.g.wrap_selection = wrap_selection

vmap('S"', ":lua vim.g.wrap_selection('\"', '\"')<CR>")
vmap('S(', ":lua vim.g.wrap_selection('(', ')')<CR>")
vmap('S{', ":lua vim.g.wrap_selection('{', '}')<CR>")

------------------------------------------
-- 定义 Lua 文件格式化
------------------------------------------
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'lua', -- 仅对 Lua 文件生效
  callback = function()
    vim.api.nvim_set_keymap('n', '<leader>ff', ':%!npx lua-fmt --use-tabs --stdin<CR>', {noremap = true, silent = true})
  end,
})

------------------------------------------
-- 输入分号自动格式化段落（仅限 C/C++ 文件）
------------------------------------------
local function setup_semicolon_formatting()
    vim.keymap.set('i', ';', function()
        -- 保存原始光标位置
        local original_pos = vim.api.nvim_win_get_cursor(0)
        -- 获取当前行号和列号
		local row, col = original_pos[1], original_pos[2] + 1  -- col从0开始，需要+1
		-- 获取光标位置的字符
		local char_at_cursor = vim.fn.getline(row):sub(col, col)
		-- 判断是否是行尾（空字符或换行符）
		local is_at_end = char_at_cursor == "" or char_at_cursor == "\n" or char_at_cursor == '\r'

		if is_at_end then
			-- 插入分号
			vim.api.nvim_put({ ';' }, 'c', true, true)

			-- 使用更快的 nvim_exec 执行格式化操作
			vim.api.nvim_exec([[
			silent! execute "normal! =ap``"
			]], false)

			-- 恢复光标位置
			vim.api.nvim_win_set_cursor(0, original_pos)

			-- 查找并移动到分号的位置
			vim.api.nvim_exec([[
			silent! execute "normal! g_"
			]], false)
		else
			vim.api.nvim_put({ ';' }, 'c', true, true)
		end
 
        return ''
    end, { noremap = true , silent = true })
end

-- 为 C/C++ 文件类型设置自动命令
vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'c', 'cpp', 'h', 'hpp', 'cxx' },
    callback = function()
        -- setup_semicolon_formatting() -- 有BUG
    end
})
