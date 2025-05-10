local autocmd = vim.api.nvim_create_autocmd
local vim = vim

local keymap = require("keymap_help")
local nmap = keymap.nmap

----------------------------------------------------------------
--- 构建cpp项目函数
----------------------------------------------------------------
function build_project(compile_command)
	local cmd = ""
	-- 获取当前缓冲区的 LSP 客户端
	local clients = vim.lsp.get_active_clients()
	if #clients == 0 then
		print("No LSP client attached.")
		return
	end

	local wsdir = vim.g.workspace_dir2()
	local cmake_lists_path = wsdir .. "/CMakeLists.txt"
	local makefile_path = wsdir .. "/Makefile"
	local current_file = '"' .. vim.fn.expand("%:p") .. '"' -- 获取当前文件的完整路径
	local file_extension = vim.fn.expand("%:e") -- 获取当前文件的扩展名
	local build_makefile_path = wsdir .. "/build/Makefile"

	local build_dir = wsdir .. "/build"

	if vim.fn.isdirectory(build_dir) == 1 and vim.fn.filereadable(build_makefile_path) == 1 and compile_command == true then
		cmd = "cd " .. build_dir .. "&& make"
		vim.cmd("AsyncRun " .. cmd)
	elseif vim.fn.filereadable(cmake_lists_path) == 1 then
		-- 如果 CMakeLists.txt 存在
		print("CMakeLists.txt found.")

		-- 检查 build 目录是否存在，如果不存在则创建
		local build_dir = wsdir .. "/build"
		if vim.fn.isdirectory(build_dir) == 0 then
			vim.fn.mkdir(build_dir, "p")
			print("Created build directory: " .. build_dir)
		end

		local cmake_pam = ""
		if vim.fn.has("unix") == 1 then
			cmake_pam =
				'-DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_FLAGS="-O0 -g" -DCMAKE_C_FLAGS="-O0 -g"'
		else
			cmake_pam =
				' -G "MinGW Makefiles"'..
				' -DCMAKE_C_COMPILER=' .. require('config.compiles_cfg').cc_path ..
				' -DCMAKE_CXX_COMPILER=' .. require('config.compiles_cfg').cxx_path .. 
				' -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_FLAGS="-O0 -g" -DCMAKE_C_FLAGS="-O0 -g"' ..
				' -DCMAKE_BUILD_TYPE=Debug'
		end
		-- '-DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_BUILD_TYPE=Debug'
		-- 在 Fterm 中执行 cmake 命令
		if compile_command == true then
			if vim.fn.has("unix") == 1 then
				cmd = 'cd "' .. build_dir .. '" && cmake ' .. cmake_pam .. " -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .. && make"
			else
				cmd = 'cd "' .. build_dir .. '" && cmake ' .. cmake_pam .. " -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .. && mingw32-make"
				-- cmd = 'cd "' .. build_dir .. '" && cmake ' .. cmake_pam .. " -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .. && ninja"
			end
			-- fterm.run(cmd)
			vim.cmd("AsyncRun " .. cmd)
		else
			cmd = 'cd "' .. build_dir .. '" && cmake ' .. cmake_pam .. " -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .."
			vim.cmd("AsyncRun " .. cmd)
		end

		-- 将生成的可执行文件目录保存到全局变量中
		vim.g.build_dir = build_dir
		print("CMake build directory saved to global variable: " .. vim.g.build_dir)
	elseif vim.fn.filereadable(makefile_path) == 1 then
		-- 如果 Makefile 存在
		print("Makefile found.")

		-- 在 Fterm 中执行 make 命令
		if compile_command == true then
			cmd = 'cd "' .. wsdir .. '" && bear --append -o compile_commands.json make'
			vim.cmd("AsyncRun " .. cmd)
		else
			cmd = 'cd "' .. wsdir .. '" && make'
			-- fterm.run(cmd)
			vim.cmd("AsyncRun " .. cmd)
		end

		-- 将生成的可执行文件目录保存到全局变量中
		vim.g.build_dir = wsdir
		print("Make build directory saved to global variable: " .. vim.g.build_dir)
	else
		-- 如果既没有 CMakeLists.txt 也没有 Makefile
		print("No CMakeLists.txt or Makefile found. Compiling directly.")

		-- 根据文件类型选择编译器
		local compiler = ""
		local output_file = '"' .. wsdir .. "/main" .. '"'
		if file_extension == "cpp" then
			compiler = require('config.compiles_cfg').cxx_path .. " -g "
		elseif file_extension == "c" then
			compiler = require('config.compiles_cfg').cc_path .. " -g "
		else
			print("Unsupported file type. Only .c and .cpp files are supported.")
			return
		end

		-- 在 Fterm 中执行编译命令
		local cmd = compiler .. " " .. current_file .. " -o " .. output_file
		vim.cmd("AsyncRun " .. cmd)

		-- 将生成的可执行文件目录保存到全局变量中
		vim.g.build_dir = wsdir
		print("Build directory saved to global variable: " .. vim.g.build_dir)
	end
end

function build_project_bin()
	build_project(true)
end

function build_project_sym()
	build_project(false)
end

----------------------------------------------------------------
--- 弃用
----------------------------------------------------------------
vim.api.nvim_create_autocmd(
	"BufEnter",
	{
		-- 自动添加工作区
		pattern = "*.cpp,*.h,*.py,CMakeLists.txt",
		callback = function()
			-- vim.lsp.buf.add_workspace_folder(vim.fn.getcwd())  -- 添加工作区目录
		end
	}
)

----------------------------------------------------------------
-- CPP 文件启用:
--  调试
--  构建
----------------------------------------------------------------
vim.api.nvim_create_autocmd(
	"BufEnter",
	{
		pattern = {"*.h", "*.hpp", "*.cxx", "*.c", "*.cpp"}, -- 匹配的文件类型
		callback = function()
			vim.keymap.set("n", "<leader>wbd", build_project_bin, {noremap = true, silent = true, buffer = true})
			vim.keymap.set("n", "<leader>wbg", build_project_sym, {noremap = true, silent = true, buffer = true})
		end
	}
)

----------------------------------------------------------------
-- 当只剩下 NvimTree 窗口时，自动退出
----------------------------------------------------------------
vim.cmd(
	[[
  augroup NvimTreeWindowSize
    autocmd!
    autocmd WinEnter * if winnr('$') == 1 && (&filetype == 'aerial' || &filetype == 'NvimTree' || &filetype == 'qf' || &filetype == 'codecompanion') | qa! | endif
  augroup END
]]
)

------------------------------------------------------------------------------------------
-- 格式化代码 null-ls
------------------------------------------------------------------------------------------
vim.api.nvim_create_autocmd(
	"FileType",
	{
		pattern = "lua", -- 仅对 Lua 文件生效
		callback = function()
			nmap("<leader>ff", ":lua vim.lsp.buf.format()<CR>")
		end
	}
)

----------------------------------------------------------------
-- 设置Windows路径分隔符
----------------------------------------------------------------
vim.api.nvim_create_autocmd(
	"BufWinEnter",
	{
		pattern = "*",
		callback = function()
			vim.schedule(
				function()
					if vim.g.is_win32 == 1 then
						vim.opt.shellslash = true -- 解决Windows下路径分隔符 \\ / 不一致的问题
					end
					vim.opt.laststatus = 3
				end
			)
		end
	}
)

----------------------------------------------------------------
-- 关闭 codecompanion 的行号
----------------------------------------------------------------
-- 为特定文件类型（这里是python）设置局部选项来关闭行号和相对行号
-- vim.api.nvim_create_autocmd("BufReadPost", 
-- {
-- 	-- pattern = "codecompanion",
-- 	callback = function()
-- 		if vim.bo.filetype == 'codecompanion' then
-- 			vim.cmd('setlocal nonumber norelativenumber')
-- 		end
-- 	end,
-- })

----------------------------------------------------------------
-- 首次进入设置工作目录
----------------------------------------------------------------
vim.api.nvim_create_autocmd(
"BufReadPost", -- 修改为在缓冲区加载完成之后执行
{
	once = true,
	pattern = "*",
	callback = function()

			vim.schedule(
				function()
					-- vim.g.reset_workspace_dir_nop()
					vim.g.workspace_dir.get()
					vim.fn.chdir(vim.g.workspace_dir.get())
					-- vim.g.generate_ctags(true)
					vim.notify('Workdir: ' .. vim.g.workspace_dir.get(), vim.log.levels.INFO, { title = 'Workspace Setup' })
				end
				-- 1000
				)
		end
	}
)

----------------------------------------------------------------
-- 在 Vim 启动时执行 generate_ctags 函数
----------------------------------------------------------------
-- vim.cmd(
-- 	[[
-- augroup GenerateCtags
--     autocmd!
--     autocmd VimEnter * lua vim.schedule(function()vim.g.generate_ctags(true)end) 
-- augroup END
-- ]]
-- )

----------------------------------------------------------------
-- 主题切换部分设置重新设置
----------------------------------------------------------------
vim.api.nvim_create_autocmd(
	"ColorScheme",
	{
		callback = function()
			vim.schedule(
				function()
					if vim.g.is_win32 == 1 then
						vim.opt.shellslash = true -- 解决Windows下路径分隔符 \\ / 不一致的问题
					end
					vim.opt.laststatus = 3
				end
			)
		end
	}
)


----------------------------------------------------------------
-- Session保存与恢复
----------------------------------------------------------------
function SaveCurrentSession()
	local wsdir = vim.g.workspace_dir2()
	local session_file_path = wsdir .. "/Session.vim"

	vim.cmd("AerialClose")
	vim.cmd("NvimTreeClose")

	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.api.nvim_buf_get_option(buf, "filetype") == "Avante" then
			vim.cmd("AvanteToggle")
			break
		end
	end

	local function jmp_active_buffers()
		local all_windows = vim.api.nvim_list_wins()
		for _, win_id in ipairs(all_windows) do
			local bufnr = vim.api.nvim_win_get_buf(win_id)
			vim.api.nvim_command("buffer " .. bufnr)
			break
		end
	end
	jmp_active_buffers()

	vim.cmd("mksession! " .. session_file_path)

	-- Check for Avante window and append 'AvanteToggle' to the session file if it exists
	-- local avante_toggle_added = false
	-- local file = io.open(session_file_path, "a")
	-- for _, win in ipairs(vim.api.nvim_list_wins()) do
	-- 	local buf = vim.api.nvim_win_get_buf(win)
	-- 	if vim.api.nvim_buf_get_option(buf, "filetype") == "Avante" then
	-- 		file:write("\nAvanteChat")
	-- 	elseif vim.api.nvim_buf_get_option(buf, "filetype") == "NvimTree" then
	-- 		file:write("\n lua vim.g.toggle_nvimtree()")
	-- 	elseif vim.api.nvim_buf_get_option(buf, "filetype") == "aerial" then
	-- 		file:write("\n vim.g.toggle_tagbar()")
	-- 	end
	-- end
	-- file:close()
	
	-- local mark_name = wsdir:gsub("[:/\\ \\.]", "_") .. "_Session"
	-- local mark_name = vim.g.hash_djb2(session_file_path)
	-- print(mark_namd)
	-- vim.cmd("silent MarkSave")
	vim.notify("Session saved to: " .. session_file_path, vim.log.levels.INFO, { title = 'Session' })
end

-- 注册加载会话的命令
function LoadSavedSession()
	local wsdir = vim.g.workspace_dir2()
	local session_file_path = wsdir .. "/Session.vim"
	if vim.fn.filereadable(session_file_path) == 1 then

		-- vim.cmd("silent! MarkLoad")
		vim.cmd("source " .. session_file_path)
		vim.notify("Session loaded from: " .. session_file_path, vim.log.levels.INFO, { title = 'Session' })
	else
		vim.notify("No session file found at: " .. session_file_path, vim.log.levels.INFO, { title = 'Session' })
	end
end

-- 注册command用于保存和加载会话
vim.api.nvim_create_user_command('Ss', SaveCurrentSession, {desc = 'Abbreviation command to save the current session', bang = true})
vim.api.nvim_create_user_command('Sq', function()
	SaveCurrentSession()
	vim.cmd('q')
end, {desc = 'Abbreviation command to save the current session', bang = true})
vim.api.nvim_create_user_command('Ls', LoadSavedSession, {desc = 'Abbreviation command to load a saved session', bang = true})
