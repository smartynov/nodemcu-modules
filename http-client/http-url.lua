-- URL parsing module for ESP8266 with nodeMCU
-- Written by Sergey Martynov http://martynov.info

local moduleName = ...
local M = {}
_G[moduleName] = M

function M.parse(url, default)
    local result = {}
    for i,v in pairs(default or result) do result[i] = v end

    url = tostring(url or ''):gsub(' ', '+')
    url = url:gsub('^([%w][%w%+%-%.]*)%:', function(scheme)
      result.scheme = scheme:lower()
      return '' end)
    url = url:gsub('^//([^/]*)', function(authority)
      authority = authority:gsub('^([^@]*)@', function(userpass)
        result.user = userpass
        userpass = userpass:gsub(':([^:]*)$', function(pass)
          result.pass = pass
          return '' end)
        result.user = userpass
        return '' end)
      authority = authority:gsub(':([^:]*)$', function(port)
        result.port = port
        return '' end)
      if authority ~= '' then
        result.host = authority:lower() end
      return '' end)
    if url ~= '' then
      result.path = url end
    
    return result
end

return M
