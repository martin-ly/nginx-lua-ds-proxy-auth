local http = require "resty.http"
local config = require "config"

function ds_proxy()
    local req_host=ngx.req.get_headers()["Host"]
    local req_uri=ngx.var.request_uri
    local req_url="http://"..req_host..req_uri
    local req_method=ngx.req.get_method()
    local req_body=ngx.req.get_body_data()
    local req_headers=ngx.req.get_headers()
    req_headers["accept-encoding"]="deflate,sdch"

    local hc = http:new()
    local resp_ok, resp_code, resp_headers, resp_status, resp_body  = hc:request {
        url = req_url,
        method = req_method, 
        headers=req_headers,
        body=req_body,
    }

    if not resp_ok then
        ngx.say("Error: "..resp_code)
        return
    end

    ngx.status=resp_code

    tmp_set_cookie={}
    for k,v in pairs(resp_headers) do
        if k=="set-cookie" then
            for i in string.gmatch(v, "[^,]+") do
                table.insert(tmp_set_cookie,i)
            end
        else
            ngx.header[k]=v
        end
    end
    ngx.header["Set-Cookie"]=tmp_set_cookie

    --ngx.header["Connection"]=nil
    --ngx.header["Transfer-Encoding"]=nil

    if resp_body then
        ngx.say(resp_body)
    end
end

--------------------------------------------------------

function auth_access()
    local auth_time=ngx.shared.auth_ip:get(ngx.var.remote_addr)
    if not auth_time or auth_time < ngx.now() then
        ngx.redirect("/auth")
    else
        return
    end
end

function auth_get()
    ngx.say([=[
        <form action="/auth" method="post">
            account: <input type="text" name="name">
            password: <input type="password" name="passwd">
            <input type="submit" value="login">
        </form>
    ]=])
    ngx.exit(200)
end

function auth_post()
    local args = ngx.req.get_post_args()
    local name = args.name
    local passwd = args.passwd
    if name == "ds" and passwd == "ccc" then
        ngx.shared.auth_ip:set(ngx.var.remote_addr,ngx.now()+config.expiration_time)
        ngx.redirect("/")
    else
        ngx.redirect("/auth")
    end
end
