local template = require("resty.template")
template.caching(false)

local stu = {
	name = "����",
	age = 20,
	male = true,
	scores = {{name="��ѧ",score=95},{name="����",score=45},{name="Ӣ��",score=45.8}}
}

template.render("t1.html",stu)
