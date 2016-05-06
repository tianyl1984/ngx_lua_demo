--cjson模块使用
local cjson = require("cjson")
local obj = {
	name = "zhangsan",
	age = 23,
	gf = nil
}

local str = cjson.encode(obj)
ngx.say("<hr>")
ngx.say(str, "<hr>")

local str2 = '{"name":"lisi","age":24,"male":true,"bf":null}'
local jsonObj = cjson.decode(str2)
ngx.say(jsonObj.name,"<br>")
ngx.say(jsonObj.age,"<br>")
ngx.say(jsonObj.male,"<br>")
ngx.say(jsonObj.bf,"<br>")
ngx.say(jsonObj.bf == nil,"<br>")

