local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node  -- 新增恢复节点
local rep = require("luasnip.extras").rep  -- 正确导入重复函数

local fmt = require("luasnip.extras.fmt").fmt

-- 通用 C/C++ 片段
local c_cpp_snippets = {
	-- Main 函数
	s("main", fmt([[
	int main(int argc, char *argv[]) 
	{{
		{}
		return 0;
	}}]], { i(1) })),

	-- For 循环
	s("for", fmt([[
	for (int {} = 0; {} < {}; ++{}) 
	{{
		{}
	}}]], { 
		i(1, "i"), 
		rep(1), 
		i(2, "n"), 
		rep(1), 
		i(0) 
	})),

	-- 函数定义
	s("fn", fmt([[
	{} {}({}) 
	{{
		{}
	}}]], { 
		c(1, { t("void"),  t("auto"), t(nil, "type") }),
		i(2, 'function_name'),
		i(3),
		i(0)
	})),

	-- Include 头文件
	s("inc", fmt([[#include <{}>]], { i(1) })),

	-- 结构体
	s("struct", fmt([[
	struct {} 
	{{
		{};
	}};]], { i(1, "StructName"), i(0) })),

	-- If 条件
	s("if", fmt([[
	if ({}) 
	{{
		{}
	}}]], { i(1), i(0) })),

	-- If-Else
	s("ife", fmt([[
	if ({}) 
	{{
		{}
	}}
	else 
	{{
		{}
	}}]], { i(1), i(2), i(0) })),

	-- 指针声明
	s(
		"ptr", fmt([[{}* {} = {};]], 
		{ c(1, { t("uint64_t"), t("uint8_t"), i(nil, "type") })
		, i(2, "var"), i(3, "NULL") })
	),

	-- 类定义 (C++)
	s({trig = "class", dscr = "C++ class definition"}, fmt([[
	class {} 
	{{
		public:
		{}();
		~{}();

		private:
		{}
	}};]], { 
		i(1, "ClassName"),
		rep(1),
		rep(1),
		i(0)
	})),
}

-- C++ 专用片段
local cpp_snippets = {
	-- 命名空间
	s("ns", fmt([[
	namespace {} 
	{{
		{}
	}} // namespace {}]], { 
		i(1, "namespace_name"), 
		i(0), 
		rep(1) 
	})),

	-- cout 输出
	s("cout", fmt([[std::cout << "{}" << std::endl;]], { i(1, "") })),

	-- 智能指针
	s("sptr", fmt([[std::shared_ptr<{}> {};]], { i(1, "T"), i(2, "ptr") })),
}

-- 注册片段
ls.add_snippets("c", c_cpp_snippets)
ls.add_snippets("cpp", vim.tbl_extend("keep", c_cpp_snippets, cpp_snippets)) -- force or keep

