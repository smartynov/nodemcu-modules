-- A simple Telnet server for ESP8266 with nodeMCU
-- Written by Sergey Martynov http://martynov.info

local moduleName = ...
local M = {}
_G[moduleName] = M

function M.start (port, delay)
  if port == nil then port = 21 end
  if delay == nil then delay = 600 end
  local sv = net.createServer(net.TCP, delay)
  sv:listen(port, function(c)
    con_std = c
    
    function s_output(str)
      if con_std ~= nil then
        con_std:send(str .. "\n")
      end
    end
    node.output(s_output, 1)
    
    c:on("receive", function(c, l)
      node.input(l)
    end)
    
    c:on("disconnection", function(c) 
      con_std = nil
      node.output(nil)
    end)
  end)
end

return M
