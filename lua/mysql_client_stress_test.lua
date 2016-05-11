
--连接池和非连接池对比测试

local function to_json( obj )
	local cjson = require "cjson"
	cjson.encode_empty_table_as_object(true)
	return cjson.encode(obj)
end

local function close_db(db)
	if not db then
		return
	end
	--db:close()
	--连接池设计
	local pool_max_idle_time = 100000 --毫秒
	local pool_size = 100
	local ok,err = db:set_keepalive(pool_max_idle_time,pool_size)
	if not ok then
		ngx.say("set keepalive error : ",err)
		db:close()
	end
end

local function start_transaction( db )
	if not db then
		return
	end
	local res, err, errno, sqlstate = db:query("START TRANSACTION")
	if not res then
		close_db(db)
		print_err_exit("start transaction", res, err, errno, sqlstate)
		return
	end
end

local function commit_transaction( db )
	if not db then
		return
	end
	local res, err, errno, sqlstate = db:query("COMMIT")
	--ngx.log(ngx.ERR, " COMMIT ", to_json(res))
	if not res then
		close_db(db)
		print_err_exit("commit", res, err, errno, sqlstate)
		return
	end
end

local function rollback_transaction( db )
	if not db then
		return
	end
	local res, err, errno, sqlstate = db:query("ROLLBACK")
	--ngx.log(ngx.ERR, " ROLLBACK ", to_json(res))
	if not res then
		close_db(db)
		print_err_exit("rollback", res, err, errno, sqlstate)
		return
	end
end

local function print_err_exit(opt, res, err, errno, sqlstate)
	--ngx.exit(500)
	ngx.status = 500
	ngx.say(opt," , res : ", res , " , error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)
	ngx.exit(ngx.OK)
end

local function getDB()
	local mysql = require("resty.mysql")
	local db, err = mysql:new()
	if not db then
		print_err_exit("new db")
	end

	--设置超时
	db:set_timeout(2000)

	local props = {
		host = "10.2.2.3",-- 10.2.2.3
		port = 3306,
		database = "bd",
		user = "root",
		password = "jksfdsdff2",
		pool = "mysqlpool"
	}

	local res, err, errno, sqlstate = db:connect(props)
	if not res then
		close_db(db)
		print_err_exit("connect", res, err, errno, sqlstate)
		return 
	else
		--res, err, errno, sqlstate = db:query("SET character_set_client = gbk")
		res, err, errno, sqlstate = db:query("SET NAMES 'utf8'")
		if not res then
			close_db(db)
			print_err_exit("set names 'utf8'", res, err, errno, sqlstate)
			return
		end
		--ngx.say("set character success!! <br/>")
	end
	return db
end

local function select( db )
	local sql = "select * from bd_student where id = 4866 "
	local res, err, errno, sqlstate = db:query(sql)
	if not res then
		close_db(db)
		print_err_exit("select", res, err, errno, sqlstate)
		return 
	end

	for i, row in ipairs(res) do
		ngx.say("id : ", row.id, " name : ", row.name, " examNum : ", row.examNum, "<br/>")
	end
end

local function insert( db )
	local sql = "insert into stu(name,age) values('张三',20)"
	local res, err, errno, sqlstate = db:query(sql)
	if not res then
		rollback_transaction(db)
		close_db(db)
		print_err_exit("insert", res, err, errno, sqlstate)
		return
	end
	ngx.say("insert rows : ", res.affected_rows, " , id : ", res.insert_id, "<br>")
end

local function insert_bad( db )
	local sql = "insert into stu(name,age) values('李四',20)"
	local res, err, errno, sqlstate = db:query(sql)
	if not res then
		rollback_transaction(db)
		close_db(db)
		print_err_exit("insert_bad", res, err, errno, sqlstate)
		return
	end
	ngx.say("insert_bad rows : ", res.affected_rows, " , id : ", res.insert_id, "<br>")
end

local db = getDB()
start_transaction(db)
select(db)
--insert(db)
--ngx.log(ngx.ERR, "before insert_bad")
--insert_bad(db)
--ngx.log(ngx.ERR, "after insert_bad")
commit_transaction(db)
close_db(db)