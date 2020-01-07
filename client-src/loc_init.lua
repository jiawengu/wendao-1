

local updatePath = cc.FileUtils:getInstance():getWritablePath()
cc.FileUtils:getInstance():addSearchPath(updatePath .. "atmu/src")
cc.FileUtils:getInstance():addSearchPath(updatePath .. "atmu/res")
Log:I('Update path:' .. updatePath)

cc.FileUtils:getInstance():addSearchPath("src")
cc.FileUtils:getInstance():addSearchPath("res")

cc.FileUtils:getInstance():addSearchPath("raw/src")
cc.FileUtils:getInstance():addSearchPath("raw/res")

cc.FileUtils:getInstance():addSearchPath("obb/src")
cc.FileUtils:getInstance():addSearchPath("obb/res")

-- 添加文件路径
cc.FileUtils:getInstance():addSearchPath(updatePath .. "data")

local r_require = require
require = function(...)
    print("require:", ..., package.loaded[...])
    return r_require(...)
end

require "core/Singleton"
require "global/CHS"
require "global/Const"
require "global/GlobalFunc"
require "mgr/ResMgr"
require "mgr/EventDispatcher"
require "mgr/MessageMgr"
require "mgr/InventoryMgr"
require "mgr/DeviceMgr"
require "dlg/Dialog"


local _gt = __G__TRACKBACK__
function __G__TRACKBACK__(msg)
    _gt(string.format("%s:%s", msg, debug.traceback()))
end