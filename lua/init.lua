local redis = require 'resty.redis'
local cjson = require 'cjson'

local s_data = ngx.shared.s_data
s_data:set("count",1)