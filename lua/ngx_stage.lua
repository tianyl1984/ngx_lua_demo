local s_data = ngx.shared.s_data
ngx.say("shared memory : ",s_data:get("count"),"<br/>")
local i = s_data:incr("count",1)
ngx.say("OK","<hr>")
