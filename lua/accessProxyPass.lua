local args = ngx.req.get_uri_args()
ngx.req.set_uri_args({ a = "aaaaaaaa",b = 123456 })
