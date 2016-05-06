
--resty.template模块需要单独安装
--https://github.com/bungle/lua-resty-template

local template = require("resty.template")
template.caching(false)

local stu = {
	name = "张三",
	age = 20,
	male = true,
	scores = {{name="数学",score=95},{name="语文",score=45},{name="英语",score=45.8}}
}

template.render("t1.html",stu)
