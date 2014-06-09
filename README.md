nginx-lua-ds-proxy-auth
=======================

Under developing

一个具备认证模块的HTTP代理服务器，基于liseen/lua-resty-http

A http proxy with auth module, based on liseen/lua-resty-http

将代码放在位于nginx根目录下的lua/ds_proxy_auth/下

Put the code into the directory lua/ds_proxy_auth which is located in the root directory of the nginx

在nginx.conf的http段中添加如下配置：

Add the config below to the http seg in nginx.conf:

    lua_package_path "/u/nginx/lua/ds_proxy_auth/?.lua;;";
    lua_need_request_body on;
    init_by_lua_file lua/ds_proxy_auth/init.lua;
    
    lua_shared_dict auth_ip 10m;
    
    resolver 223.5.5.5;
    resolver_timeout 5s;
    
在nginx.conf的location段中添加如下配置：

Add the config below to the location seg in nginx.conf:

    location / {
        access_by_lua_file lua/ds_proxy_auth/access.lua;
        content_by_lua_file lua/ds_proxy_auth/proxy.lua;
    }
    
    location = /auth {
         if ( $request_method = GET ){
              content_by_lua_file lua/ds_proxy_auth/auth_get.lua;
         }
         if ( $request_method = POST ){
              content_by_lua_file lua/ds_proxy_auth/auth_post.lua;
         }
    }
    
