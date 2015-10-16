-- test/demo for http-url module
local url = require('http-url')

function tdump(t)
  for k, v in pairs(t) do
    print(k.."="..v)
  end
end

local t = {
  'http://www.example.com',
  'HTTP://EXAMPLE.COM/',
  'http://user:password@example.com/',
  'http://user@example.com/',
  'http://www.example.com/cgi-bin/index.lua?a=2&b=3',
  'http://www.example.com/?query with spaces',
  'http://[2a00:1450:4010:c0b::66]:8080/test?a=b',
  'ftp://ftp.is.co.za/rfc/rfc1808.txt',
  'ftp://root:passwd@unsafe.org/etc/passwd',
  'news:comp.infosystems.www.servers.unix',
  'mailto:John.Doe@example.com',
  'telnet://192.0.2.16:80/',
  'plain text',
  1234567,
  false,
  true,
  ''
}

for i,v in pairs(t) do
  print()
  print(v)
  tdump(url.parse(v))
end
