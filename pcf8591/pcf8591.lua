-- PCF8591 module for ESP8266 with nodeMCU
-- Written by Sergey Martynov http://martynov.info
-- Based on http://www.nxp.com/documents/data_sheet/PCF8591.pdf

-- On YL-40 board
-- 0 = photoresistor
-- 1 = 255 - pulled up ??
-- 2 = thermistor ??
-- 3 = variable resistor


local moduleName = ...
local M = {}
_G[moduleName] = M

local id = 0 -- i2c interface ID
local device = 0x48 -- PCF8591 address, might vary from 0x48 to 0x4F

-- read data register
-- reg_addr: address of the register
-- lenght: bytes to read
local function read_reg(reg_addr, length)
  i2c.start(id)
  i2c.address(id, device, i2c.TRANSMITTER)
  i2c.write(id, reg_addr)
  i2c.stop(id)
  i2c.start(id)
  i2c.address(id, device, i2c.RECEIVER)
  c = i2c.read(id, length)
  i2c.stop(id)
  return c
end

-- write data register
-- reg_addr: address of the register
-- reg_val: value to write to the register
local function write_reg(reg_addr, reg_val)
  i2c.start(id)
  i2c.address(id, device, i2c.TRANSMITTER)
  i2c.write(id, reg_addr)
  i2c.write(id, reg_val)
  i2c.stop(id)
end


-- initialize module
-- sda: SDA pin
-- scl: SCL pin
function M.init(sda, scl)
  i2c.setup(id, sda, scl, i2c.SLOW)
  init = true
end

-- XXX read adc register 0 to 3
function M.adc(reg)
  local data = read_reg(0x00 + reg, 2)
  return string.byte(data, 2)
end

-- XXX write dac register
function M.dac(val)
  write_reg(0x40, val)
end

return M
