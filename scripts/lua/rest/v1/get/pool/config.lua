--
-- (C) 2019-20 - ntop.org
--
dirs = ntop.getDirs()
package.path = dirs.installdir .. "/scripts/lua/modules/?.lua;" .. package.path

require "lua_utils"

local info = ntop.getInfo() 

local json = require ("dkjson")
local page_utils = require("page_utils")
local format_utils = require("format_utils")
local os_utils = require "os_utils"
local host_pools_nedge = require "host_pools_nedge"
local rest_utils = require("rest_utils")

--
-- Read host pools configuration
-- Example: curl -u admin:admin -d '{"ifid": "1"}' http://localhost:3000/lua/rest/v1/get/pool/config.lua
--
-- NOTE: in case of invalid login, no error is returned but redirected to login
--

local rc = rest_utils.consts_ok
local res = {}

local ifid = _GET["ifid"]
local download = _GET["download"] 

if not haveAdminPrivileges() then
   sendHTTPHeader('application/json')
   print(rest_utils.rc(rest_utils.consts_not_granted))
   return
end

if isEmptyString(ifid) then
   sendHTTPHeader('application/json')
   print(rest_utils.rc(rest_utils.consts_invalid_interface))
   return
end

local res = host_pools_nedge.export()

if isEmptyString(download) then
  sendHTTPHeader('application/json')
  print(rest_utils.rc(rc, res))
else
  sendHTTPContentTypeHeader('application/json', 'attachment; filename="pools_configuration.json"')
  print(json.encode(res, nil))
end
