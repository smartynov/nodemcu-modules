-- A simple Telnet server for ESP8266 with nodeMCU
-- Written by Sergey Martynov http://martynov.info

local moduleName = ...
local M = {}
_G[moduleName] = M

function M.start (port, delay)
  if port == nil then port = 21 end
  if delay == nil then delay = 600 end
  
  local srv = net.createServer(net.TCP, delay)
  srv:listen(port, function(socket)
    local fifo = {}
    local fifo_drained = true
    
    local function sender(c)
        if #fifo > 0 then
            c:send(table.remove(fifo, 1))
        else
            fifo_drained = true
        end
    end
    
    local function s_output(str)
        table.insert(fifo, str)
        if socket ~= nil and fifo_drained then
            fifo_drained = false
            sender(socket)
        end
    end
    
    node.output(s_output, 1)
    
    socket:on("receive", function(c, l)
      node.input(l)
    end)
    
    socket:on("disconnection", function(c) 
      con_std = nil
      node.output(nil)
    end)
    
    socket:on("sent", sender)
  end)
end

return M
