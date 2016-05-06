local args = ngx.req.get_uri_args()
ngx.req.set_uri_args({ a = "aaaaaaaa",b = 123456 })
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

--模块
local count = 0;
local function addCount()
	count = count + 1
	ngx.say("count : ",count)
end

local _M = {
	addCount = addCount
}

return _Mlocal http = require("resty.http")
local httpc = http.new()
local resp,err = httpc:request_uri("http://223.202.64.196:7777/api/md/",{
	method = "GET",
	headers = {
		["User-Agent"] = "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:45.0) Gecko/20100101 Firefox/45.0"
	}
})

if not resp then
	ngx.say("request error:", err)
	return
end

ngx.header["Content-Type"] = "text/html; charset=utf8"

ngx.say("resp code : ",resp.status,"<hr>")
local html = resp.body
html = ngx.re.gsub(html,"<","&lt;")
ngx.say(html)

httpc:close()
local redis = require 'resty.redis'
local cjson = require 'cjson'

local s_data = ngx.shared.s_data
s_data:set("count",1)
local opt = ngx.req.get_uri_args()["opt"] or ""
if opt == "" then
	ngx.say("need paramter opt !!")
end

local function close_db(db)
	if not db then
		return
	end
	db:close()
end

local function print_opt(opt, res, err, errno, sqlstate)
	ngx.say(opt, " error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)
end

local mysql = require("resty.mysql")
local db, err = mysql:new()
if not db then
	ngx.say("new mysql error : ", err)
end

--设置超时
db:set_timeout(1000)

local props = {
	host = "127.0.0.1",
	port = 3306,
	database = "test",
	user = "root",
	password = "hzth-801"
}

local res, err, errno, sqlstate = db:connect(props)
if not res then
	print_opt("connect", res, err, errno, sqlstate)
	return close_db(db)
else
	--res, err, errno, sqlstate = db:query("SET character_set_client = gbk")
	res, err, errno, sqlstate = db:query("SET NAMES 'utf8'")
	if not res then
		print_opt(opt, res, err, errno, sqlstate)
		return close_db(db)
	end
	ngx.say("set character success!! <br/>")
end

if opt == "drop" then
	local sql = "drop table if exists test"
	res, err, errno, sqlstate = db:query(sql)
	if not res then
		print_opt(opt, res, err, errno, sqlstate)
		return close_db(db)
	end
	ngx.say(opt, " success!! ")
end

if opt == "create" then
	local sql = "create table student(id int primary key auto_increment, name varchar(200),age int)"
	res, err, errno, sqlstate = db:query(sql)
	if not res then
		print_opt(opt, res, err, errno, sqlstate)
		return close_db(db)
	end
	ngx.say(opt, " success!! ")
end

if opt == "insert" then
	local name = ngx.req.get_uri_args()["name"] or ""
	local sql = "insert into student(name,age) values("..ngx.quote_sql_str(name)..",20)"
	res, err, errno, sqlstate = db:query(sql)
	if not res then
		print_opt(opt, res, err, errno, sqlstate)
		return close_db(db)
	end
	ngx.say(opt, " success!! ")
	ngx.say("</br>","insert rows : ", res.affected_rows, " , id : ", res.insert_id,ngx.quote_sql_str(name))
end

if opt == "update" then
	local sql = "update student set name = 'aaa' where id = 3"
	res, err, errno, sqlstate = db:query(sql)
	if not res then
		print_opt(opt, res, err, errno, sqlstate)
		return close_db(db)
	end
	ngx.say(opt, " success!! ")
	ngx.say("</br>","insert rows : ", res.affected_rows)
end

if opt == "select" then
	local name = ngx.req.get_uri_args()["name"] or ""
	local sql = "select * from student "
	if name ~= "" then
		sql = sql.."where name like "..ngx.quote_sql_str("%"..name.."%")
	end
	res, err, errno, sqlstate = db:query(sql)
	if not res then
		print_opt(opt, res, err, errno, sqlstate)
		return close_db(db)
	end
	
	ngx.say(opt, " success!! "..name.." <br/>")
	for i, row in ipairs(res) do
		ngx.say("id : ", row.id, " name : ", row.name, " age : ", row.age, "<br/>")
	end
end

close_db(db)

local s_data = ngx.shared.s_data
ngx.say("shared memory : ",s_data:get("count"),"<br/>")
local i = s_data:incr("count",1)
ngx.say("OK","<hr>")
--ngx变量
ngx.say("------ ngx var ------<br/>");
local var = ngx.var
ngx.say("ngx.var.a : ", var.a, "<br/>")
ngx.say("ngx.var.b : ", var.b, "<br/>")
ngx.say("ngx.var[2] : ", var[2], "<br/>")
ngx.var.b = 2
ngx.say("<hr>")

ngx.say("------ ngx header ------<br/>");
local headers = ngx.req.get_headers()
ngx.say("Host : ", headers["Host"],"<br/>")
ngx.say("User-agent : ", headers.user_agent,"<br/>")
ngx.say("<br/>")
for k,v in pairs(headers) do
	if type(v) == "table" then
		ngx.say(k," : ",table.concat(v,","),"<br/>")
	else
		ngx.say(k," : ",v,"<br/>")
	end
end
ngx.say("<hr>")

ngx.say("------ ngx uri ------<br/>");
local uri = ngx.req.get_uri_args()
for k,v in pairs(uri) do
	if type(v) == "table" then
		ngx.say(k," : ",table.concat(v,","),"<br/>")
	else
		ngx.say(k," : ",v,"<br/>")
	end
end
ngx.say("<hr>")

ngx.say("------ ngx post ------<br/>");
local post = ngx.req.get_post_args()
for k,v in pairs(post) do
	if type(v) == "table" then
		ngx.say(k," : ",table.concat(v,","),"<br/>")
	else
		ngx.say(k," : ",v,"<br/>")
	end
end
ngx.say("<hr>")

ngx.say("------ ngx req other ------<br/>");
ngx.say("ngx.req.http_version : ",ngx.req.http_version(),"<br/>")
ngx.say("ngx.req.get_method : ",ngx.req.get_method(),"<br/>")
ngx.say("ngx.req.raw_header : ",ngx.req.raw_header(),"<br/>")
ngx.say("ngx.req.get_body_data : ",ngx.req.get_body_data(),"<br/>")
ngx.say("<hr>")

--有问题
ngx.say("------ ngx response ------<br/>");
ngx.header.a = "abc"
ngx.header.b = {"b1","b2"}
ngx.print("中文字符")
ngx.say("<hr>")

ngx.say("------ ngx shared data ------<br/>");
local shared_data = ngx.shared.shared_data
local i = shared_data:get("times")
if not i then
	i = 1
	shared_data:set("times",i)
	ngx.say("lazy set times ",i,"<br/>")
end
i = shared_data:incr("times",1)
ngx.say("times : ", i)
ngx.say("<hr>")

return ngx.exit(200)local template = require("resty.template")
template.caching(false)

local stu = {
	name = "张三",
	age = 20,
	male = true,
	scores = {{name="数学",score=95},{name="语文",score=45},{name="英语",score=45.8}}
}

template.render("t1.html",stu)
ngx.say("hello in file")
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

--模块
local count = 0;
local function addCount()
	count = count + 1
	ngx.say("count : ",count)
end

local _M = {
	addCount = addCount
}

return _Mlocal http = require("resty.http")
local httpc = http.new()
local resp,err = httpc:request_uri("http://223.202.64.196:7777/api/md/",{
	method = "GET",
	headers = {
		["User-Agent"] = "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:45.0) Gecko/20100101 Firefox/45.0"
	}
})

if not resp then
	ngx.say("request error:", err)
	return
end

ngx.header["Content-Type"] = "text/html; charset=utf8"

ngx.say("resp code : ",resp.status,"<hr>")
local html = resp.body
html = ngx.re.gsub(html,"<","&lt;")
ngx.say(html)

httpc:close()
local redis = require 'resty.redis'
local cjson = require 'cjson'

local s_data = ngx.shared.s_data
s_data:set("count",1)
local opt = ngx.req.get_uri_args()["opt"] or ""
if opt == "" then
	ngx.say("need paramter opt !!")
end

local function close_db(db)
	if not db then
		return
	end
	db:close()
end

local function print_opt(opt, res, err, errno, sqlstate)
	ngx.say(opt, " error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)
end

local mysql = require("resty.mysql")
local db, err = mysql:new()
if not db then
	ngx.say("new mysql error : ", err)
end

--设置超时
db:set_timeout(1000)

local props = {
	host = "127.0.0.1",
	port = 3306,
	database = "test",
	user = "root",
	password = "hzth-801"
}

local res, err, errno, sqlstate = db:connect(props)
if not res then
	print_opt("connect", res, err, errno, sqlstate)
	return close_db(db)
else
	--res, err, errno, sqlstate = db:query("SET character_set_client = gbk")
	res, err, errno, sqlstate = db:query("SET NAMES 'utf8'")
	if not res then
		print_opt(opt, res, err, errno, sqlstate)
		return close_db(db)
	end
	ngx.say("set character success!! <br/>")
end

if opt == "drop" then
	local sql = "drop table if exists test"
	res, err, errno, sqlstate = db:query(sql)
	if not res then
		print_opt(opt, res, err, errno, sqlstate)
		return close_db(db)
	end
	ngx.say(opt, " success!! ")
end

if opt == "create" then
	local sql = "create table student(id int primary key auto_increment, name varchar(200),age int)"
	res, err, errno, sqlstate = db:query(sql)
	if not res then
		print_opt(opt, res, err, errno, sqlstate)
		return close_db(db)
	end
	ngx.say(opt, " success!! ")
end

if opt == "insert" then
	local name = ngx.req.get_uri_args()["name"] or ""
	local sql = "insert into student(name,age) values("..ngx.quote_sql_str(name)..",20)"
	res, err, errno, sqlstate = db:query(sql)
	if not res then
		print_opt(opt, res, err, errno, sqlstate)
		return close_db(db)
	end
	ngx.say(opt, " success!! ")
	ngx.say("</br>","insert rows : ", res.affected_rows, " , id : ", res.insert_id,ngx.quote_sql_str(name))
end

if opt == "update" then
	local sql = "update student set name = 'aaa' where id = 3"
	res, err, errno, sqlstate = db:query(sql)
	if not res then
		print_opt(opt, res, err, errno, sqlstate)
		return close_db(db)
	end
	ngx.say(opt, " success!! ")
	ngx.say("</br>","insert rows : ", res.affected_rows)
end

if opt == "select" then
	local name = ngx.req.get_uri_args()["name"] or ""
	local sql = "select * from student "
	if name ~= "" then
		sql = sql.."where name like "..ngx.quote_sql_str("%"..name.."%")
	end
	res, err, errno, sqlstate = db:query(sql)
	if not res then
		print_opt(opt, res, err, errno, sqlstate)
		return close_db(db)
	end
	
	ngx.say(opt, " success!! "..name.." <br/>")
	for i, row in ipairs(res) do
		ngx.say("id : ", row.id, " name : ", row.name, " age : ", row.age, "<br/>")
	end
end

close_db(db)

local s_data = ngx.shared.s_data
ngx.say("shared memory : ",s_data:get("count"),"<br/>")
local i = s_data:incr("count",1)
ngx.say("OK","<hr>")
--ngx变量
ngx.say("------ ngx var ------<br/>");
local var = ngx.var
ngx.say("ngx.var.a : ", var.a, "<br/>")
ngx.say("ngx.var.b : ", var.b, "<br/>")
ngx.say("ngx.var[2] : ", var[2], "<br/>")
ngx.var.b = 2
ngx.say("<hr>")

ngx.say("------ ngx header ------<br/>");
local headers = ngx.req.get_headers()
ngx.say("Host : ", headers["Host"],"<br/>")
ngx.say("User-agent : ", headers.user_agent,"<br/>")
ngx.say("<br/>")
for k,v in pairs(headers) do
	if type(v) == "table" then
		ngx.say(k," : ",table.concat(v,","),"<br/>")
	else
		ngx.say(k," : ",v,"<br/>")
	end
end
ngx.say("<hr>")

ngx.say("------ ngx uri ------<br/>");
local uri = ngx.req.get_uri_args()
for k,v in pairs(uri) do
	if type(v) == "table" then
		ngx.say(k," : ",table.concat(v,","),"<br/>")
	else
		ngx.say(k," : ",v,"<br/>")
	end
end
ngx.say("<hr>")

ngx.say("------ ngx post ------<br/>");
local post = ngx.req.get_post_args()
for k,v in pairs(post) do
	if type(v) == "table" then
		ngx.say(k," : ",table.concat(v,","),"<br/>")
	else
		ngx.say(k," : ",v,"<br/>")
	end
end
ngx.say("<hr>")

ngx.say("------ ngx req other ------<br/>");
ngx.say("ngx.req.http_version : ",ngx.req.http_version(),"<br/>")
ngx.say("ngx.req.get_method : ",ngx.req.get_method(),"<br/>")
ngx.say("ngx.req.raw_header : ",ngx.req.raw_header(),"<br/>")
ngx.say("ngx.req.get_body_data : ",ngx.req.get_body_data(),"<br/>")
ngx.say("<hr>")

--有问题
ngx.say("------ ngx response ------<br/>");
ngx.header.a = "abc"
ngx.header.b = {"b1","b2"}
ngx.print("中文字符")
ngx.say("<hr>")

ngx.say("------ ngx shared data ------<br/>");
local shared_data = ngx.shared.shared_data
local i = shared_data:get("times")
if not i then
	i = 1
	shared_data:set("times",i)
	ngx.say("lazy set times ",i,"<br/>")
end
i = shared_data:incr("times",1)
ngx.say("times : ", i)
ngx.say("<hr>")

return ngx.exit(200)local template = require("resty.template")
template.caching(false)

local stu = {
	name = "张三",
	age = 20,
	male = true,
	scores = {{name="数学",score=95},{name="语文",score=45},{name="英语",score=45.8}}
}

template.render("t1.html",stu)
ngx.say("hello in file")
