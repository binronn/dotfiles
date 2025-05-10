local M = {}

local clangd_param_base = {
			"clangd", 
			"--background-index=true",
			"--clang-tidy",
			"--compile-commands-dir=build",
			-- "--completion-style=detailed",  -- 增强补全信息
			'--pch-storage=disk',
			'--completion-style=bundled',
			-- "--header-insertion=never"      -- 禁用自动头文件插入
		}

-- Initialize paths only if they haven't been set before
if not M.cc_path then
    M.cc_path = 'clang' .. (vim.g.is_win32 == 1 and '.exe' or '')
end
if not M.cxx_path then
    M.cxx_path = 'clang++' .. (vim.g.is_win32 == 1 and '.exe' or '')
end

if not M.clangd_path then
	M.clangd_param = clangd_param_base
end

if vim.g.is_win32 == 0 then
	return M
end

-- 获取环境变量 COMPILS 的路径
local compils_path = os.getenv("COMPILERS")
if not compils_path then
	vim.notify("COMPILS environment variable is not set", vim.log.levels.ERROR)
	return M
end

-- 读取 COMPILS 路径下的所有目录
local function get_compilers()
	local compilers = {}
	local handle = io.popen('dir "' .. compils_path .. '" /b /ad')
	if handle then
		for line in handle:lines() do
			table.insert(compilers, line)
		end
		handle:close()
	end
	return compilers
end


local function file_exists(path)
  local file = io.open(path, "r")
  if file then
    file:close()
    return true
  else
    return false
  end
end

local function set_compiler_paths(clangd_path)
    local clang_cc = clangd_path .. '\\bin\\clang.exe'
    local gcc_cc = clangd_path .. '\\bin\\gcc.exe'
    local clang_cxx = clangd_path .. '\\bin\\clang++.exe'
    local gcc_cxx = clangd_path .. '\\bin\\g++.exe'

    -- Set C compiler path
    if file_exists(clang_cc) then
        M.cc_path = clang_cc
    elseif file_exists(gcc_cc) then
        M.cc_path = gcc_cc
    else
        print("No suitable C compiler found.")
    end

    -- Set C++ compiler path
    if file_exists(clang_cxx) then
        M.cxx_path = clang_cxx
    elseif file_exists(gcc_cxx) then
        M.cxx_path = gcc_cxx
    else
        print("No suitable C++ compiler found.")
    end
end
-- 现在M.cc_path和M.cxx_path已经被正确设置了

local function update_clang_llvm_version(clangd_path)
    -- Use path.normalize for consistent path handling
	-- M.cxx_path = clangd_path .. '\\bin\\clang++.exe'
	-- M.cc_path = clangd_path .. '\\bin\\clang.exe'

	set_compiler_paths(clangd_path)

    -- Get current file type
    local query_driver = M.cxx_path  -- Default to C++ compiler
    if vim.bo.filetype == 'c' then
        query_driver = M.cc_path
    end
    
    M.clangd_param = vim.deepcopy(clangd_param_base)
    table.insert(M.clangd_param, '--query-driver=' .. query_driver)

    -- Update LSP configuration
    local success, result = pcall(require, "config.lsp_cfg")
    if success then
        require('config.lsp_cfg').reset_clangdex()
    end

    -- Update CMake tools if available
    success, result = pcall(require, "cmake-tools")
    if success then
        require('config.plugins_cfg').cmake_tools_init()
    end
end

-- 注册 comps 命令
vim.api.nvim_create_user_command(
"Comps",
function()
	require('telescope.pickers').new({}, {
		prompt_title = 'Select a Compiler',
		finder = require('telescope.finders').new_table {
			results = get_compilers(),
		},
		sorter = require('telescope.sorters').get_generic_fuzzy_sorter(),
		attach_mappings = function(prompt_bufnr, map)
			map('i', '<CR>', function()
				local selection = require("telescope.actions.state").get_selected_entry()
				if selection then
					local p = compils_path .. '\\' .. selection.value
					update_clang_llvm_version(p)
					vim.notify("Selected compiler: " .. p, vim.log.levels.INFO)
				end
				require("telescope.actions").close(prompt_bufnr)
			end)
			return true
		end,
	}):find()
end,
{}
)

return M
