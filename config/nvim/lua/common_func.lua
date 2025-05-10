-- 定义 async_command 函数
local function async_command(cmd, callback)
	local job_id =
		vim.fn.jobstart(
		cmd,
		{
			on_exit = function(_, exit_code, _)
				callback(exit_code)
			end
		}
	)

	if job_id <= 0 then
		print("Failed to start job")
		return
	end
end
vim.g.async_command = async_command

-- 定义获取选中内容的函数
local function get_visual_selection()
	-- 保存当前的寄存器内容
	local saved_register = vim.fn.getreg('"')
	local saved_register_type = vim.fn.getregtype('"')

	-- 复制选中的文本到寄存器
	vim.cmd('normal! gv""y')

	-- 获取选中的文本
	local selected_text = vim.fn.getreg('"')

	-- 恢复寄存器的内容
	vim.fn.setreg('"', saved_register, saved_register_type)

	-- 删除所有转义字符
	selected_text = selected_text:gsub("[%c%z]", "") -- 删除控制字符和零字符
	selected_text = selected_text:gsub('\\[\\\'"nrtbfv]', "") -- 删除常见的转义字符
	return selected_text
end
vim.g.get_visual_selection = {get = get_visual_selection}

local function workspace_dir2()
	local workspace_folders = vim.lsp.buf.list_workspace_folders()
	if workspace_folders and #workspace_folders <= 0 then
		return vim.fn.getcwd()
	end
	for index, folder in ipairs(workspace_folders) do
		return folder
	end
end

local function workspace_dir()
	local path = ''
	if vim.fn.empty(vim.g.workspace_dir_content) == 1 then
		local workspace_folders = vim.lsp.buf.list_workspace_folders()
		if workspace_folders and #workspace_folders <= 0 then
			vim.g.workspace_dir_content = vim.fn.getcwd()
		end
		for index, folder in ipairs(workspace_folders) do
			vim.g.workspace_dir_content = folder
			break
		end
	end
	return vim.g.workspace_dir_content
end
vim.g.workspace_dir = {get = workspace_dir}
vim.g.workspace_dir2 = workspace_dir

local function reset_workspace_dir()
	vim.g.workspace_dir_content = nil
	print(vim.g.workspace_dir.get())
end

local function reset_workspace_dir_nop()
	vim.g.workspace_dir_content = nil
	vim.g.workspace_dir.get()
end

vim.g.reset_workspace_dir = {get = reset_workspace_dir}
vim.g.reset_workspace_dir_nop = reset_workspace_dir_nop

local function generate_ctags(np)
	np = np == nil and true or false
	-- 获取当前目录
	local current_dir = vim.g.workspace_dir.get()

	-- 检查当前目录是否包含 CMakeLists.txt 或 Makefile
	local has_cmake = vim.fn.filereadable(current_dir .. "/CMakeLists.txt") == 1
	local has_makefile = vim.fn.filereadable(current_dir .. "/Makefile") == 1

	-- 检查当前目录是否包含指定的目录
	local has_specific_dirs =
		vim.fn.isdirectory(current_dir .. "/out") == 1 or vim.fn.isdirectory(current_dir .. "/.venv") == 1 or
		vim.fn.isdirectory(current_dir .. "/.vs") == 1 or
		vim.fn.isdirectory(current_dir .. "/.venv_wsl") == 1 or
		vim.fn.isdirectory(current_dir .. "/.vscode") == 1 or
		vim.fn.isdirectory(current_dir .. "/.git") == 1

	-- 获取当前打开的文件类型
	local filetype = vim.bo.filetype

	-- 使用 glob 查找当前目录下的 .cpp 和 .py 文件
	local cpp_files = vim.fn.glob(current_dir .. "/*.cpp", false, true)
	local py_files = vim.fn.glob(current_dir .. "/*.py", false, true)
	local go_files = vim.fn.glob(current_dir .. "/*.go", false, true)
	local js_files = vim.fn.glob(current_dir .. "/*.js", false, true)
	local java_files = vim.fn.glob(current_dir .. "/*.java", false, true)

	-- -- 检查当前打开的文件是否是 python、cpp、c、lua 或 go 文件
	-- local is_supported_file = filetype == "python" or
	--                           filetype == "cpp" or
	--                           filetype == "c" or
	--                           filetype == "lua" or
	--                           filetype == "go" or
	--                           filetype == "java" or
	--                           filetype == "javascript" or
	--                           filetype == "assembly"

	-- 如果满足条件，则生成 ctags
	-- if has_cmake or has_makefile or has_specific_dirs or is_supported_file then
	if
		has_cmake or has_makefile or has_specific_dirs or #cpp_files > 0 or #py_files > 0 or #js_files > 0 or #java_files > 0
	 then
		-- 过滤掉不需要的目录
		local exclude_dirs =
			" --exclude=.cache --exclude=.qt --exclude=.exe --exclude=.venv --exclude=.vs --exclude=.venv_wsl --exclude=.vscode --exclude=.git" ..
			" --exclude='build*' --exclude='.venv*' --exclude=.github --exclude=out --exclude='*.txt' --exclude='*.json' --exclude='*.md' --exclude='.cache'"
		local ctags_cmd = string.format("ctags -R %s -f %s/tags %s", exclude_dirs, current_dir, current_dir)

		if vim.fn.filereadable(current_dir .. "/tags") == 1 then
			os.remove(current_dir .. "/tags")
		end

		-- 执行 ctags 命令
		vim.o.tags = current_dir .. "/tags"

		if np == true then
			print("ctags generating in " .. current_dir .. "/tags")
		end
		vim.g.async_command(
			ctags_cmd,
			function(code)
				if code == 0 then
					if np == true then
						print("ctags generated in " .. current_dir .. "/tags")
					end
				else
					if np == true then
						print("ctags exit code: " .. code)
					end
				end
			end
		)
	else
		if np == true then
			print("No need to generate ctags in " .. current_dir)
		end
	end
end
-- vim.g.generate_ctags = {get = generate_ctags}
vim.g.generate_ctags = generate_ctags

-- 定义函数：启动 live_grep_args 并自动添加引号
local function live_grep_args_with_quotes()
	require("telescope").extensions.live_grep_args.live_grep_args(
		{
			default_text = '""', -- 默认添加一对引号
			initial_mode = "insert", -- 启动后直接进入插入模式
			mappings = {
				i = {
					["<C-a>"] = function(prompt_bufnr)
						-- 将光标移动到引号内
						local actions = require("telescope.actions")
						actions.move_to_start(prompt_bufnr) -- 移动到行首
						vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Right>", true, false, true), "n", true) -- 向右移动一个字符
					end
				}
			}
		}
	)
end
vim.g.live_grep_args_with_quotes = {get = live_grep_args_with_quotes}

-- 切换 NvimTree
local function toggle_nvimtree()
	local nvim_tree = require("nvim-tree.api").tree
	local is_nvim_tree_open = nvim_tree.is_visible() -- 检测 NvimTree 是否打开

	-- 检测 TagBar 是否打开
	local is_tagbar_open = false
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.api.nvim_buf_get_option(buf, "filetype") == "aerial" then
			is_tagbar_open = true
			break
		end
	end

	-- 如果 NvimTree 打开，则关闭它
	if is_nvim_tree_open then
		nvim_tree.toggle()
	else
		-- 如果 TagBar 打开，则关闭它
		if is_tagbar_open then
			vim.cmd("AerialClose")
		end
		-- 打开 NvimTree
		nvim_tree.toggle()
	end
end
vim.g.toggle_nvimtree = toggle_nvimtree

-- 切换 TagBar
local function toggle_tagbar()
	local nvim_tree = require("nvim-tree.api").tree
	local is_nvim_tree_open = nvim_tree.is_visible() -- 检测 NvimTree 是否打开

	-- 检测 TagBar 是否打开
	local is_tagbar_open = false
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.api.nvim_buf_get_option(buf, "filetype") == "aerial" then
			is_tagbar_open = true
			break
		end
	end

	-- 如果 TagBar 打开，则关闭它
	if is_tagbar_open then
		vim.cmd("AerialClose")
	else
		-- 如果 NvimTree 打开，则关闭它
		if is_nvim_tree_open then
			nvim_tree.toggle()
		end
		-- 打开 TagBar
		vim.cmd("AerialOpen")
	end
end
vim.g.toggle_tagbar = toggle_tagbar


local function hash_djb2(str)
	local hash = 5381
	for i = 1, #str do
		hash = (hash * 33) + str:byte(i)
	end
    return string.format("%d", math.abs(hash)):gsub('-', '')
end
vim.g.hash_djb2 = hash_djb2
