-- HTTP client module for ESP8266 with nodeMCU
-- Written by Sergey Martynov http://martynov.info

local moduleName = ...
local M = {}
_G[moduleName] = M

function M.get (host, path, callback, port)
  print(node.heap())
  local conn = net.createConnection(net.TCP, 0)

  -- collect response in buffer, do callback on connection close
  local buf = ""
  conn:on("disconnection", function(c)
    c:close()
    local s,e = buf:find("\r\n\r\n")
    if e > 0 then
      callback(buf:sub(e+1))
    end
  end )
  conn:on("receive", function(c, data)
    --print("receive:"..data)
    buf = buf .. data
    print(node.heap())
  end )

  -- connect and send request
  if port == nil then port = 80 end
  local query =
    "GET "..path.." HTTP/1.0\r\n"..
    "Host: "..host.."\r\n"..
    "Accept: */*\r\n"..
    "User-Agent: NodeMCU\r\n"..
    "Connection: close\r\n\r\n"
  conn:on("connection", function(c)
    --print("connection:sending\n"..query)
    c:send(query)
  end )
  conn:connect(port, host)
end

return M
