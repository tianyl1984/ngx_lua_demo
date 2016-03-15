local http = require("resty.http")
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
