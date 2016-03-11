
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

--…Ë÷√≥¨ ±
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
	res, err, errno, sqlstate = db:query("SET character_set_client = gbk")
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
	local sql = "insert into student(name,age) values('"..name.."',20)"
	res, err, errno, sqlstate = db:query(sql)
	if not res then
		print_opt(opt, res, err, errno, sqlstate)
		return close_db(db)
	end
	ngx.say(opt, " success!! ")
	ngx.say("</br>","insert rows : ", res.affected_rows, " , id : ", res.insert_id)
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

