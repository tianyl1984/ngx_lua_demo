
--连接池和非连接池对比测试

local function close_db(db)
	if not db then
		return
	end
	--db:close()
	--连接池设计
	local pool_max_idle_time = 100000; --毫秒
	local pool_size = 100;
	local ok,err = db:set_keepalive(pool_max_idle_time,pool_size);
	if not ok then
		ngx.say("set keepalive error : ",err);
		db:close();
	end
end

local function print_opt(opt, res, err, errno, sqlstate)
	--ngx.exit(500);
	ngx.status = 500;
	ngx.say(opt, " error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate);
end

local mysql = require("resty.mysql")
local db, err = mysql:new()
if not db then
	ngx.say("new mysql error : ", err);
end

--设置超时
db:set_timeout(2000)

local props = {
	host = "10.2.2.3",
	port = 3306,
	database = "bd",
	user = "root",
	password = "jksfdsdff2",
	pool = "mysqlpool"
}

local res, err, errno, sqlstate = db:connect(props);
if not res then
	print_opt("connect", res, err, errno, sqlstate);
	return close_db(db)
else
	--res, err, errno, sqlstate = db:query("SET character_set_client = gbk")
	res, err, errno, sqlstate = db:query("SET NAMES 'utf8'")
	if not res then
		print_opt(opt, res, err, errno, sqlstate)
		return close_db(db)
	end
	--ngx.say("set character success!! <br/>")
end

local sql = "select * from bd_student where id = 4866 "
res, err, errno, sqlstate = db:query(sql)
if not res then
	print_opt(opt, res, err, errno, sqlstate)
	return close_db(db)
end

for i, row in ipairs(res) do
	ngx.say("id : ", row.id, " name : ", row.name, " examNum : ", row.examNum, "<br/>")
end
