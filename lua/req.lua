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

return ngx.exit(200)