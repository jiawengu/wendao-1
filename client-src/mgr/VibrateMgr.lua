-- VibrateMgr.lua
-- created by zhengjh Sep/08/2016
-- 震动管理器

VibrateMgr = Singleton()
local platform = cc.Application:getInstance():getTargetPlatform()

local NEED_PUSH_LIST =
{
    [CHS[3004146]] = CHS[3004146],
    [CHS[3004147]] = CHS[3004147],
    [CHS[3004148]] = CHS[3004148],
    [CHS[3004149]] = CHS[3004149],
    [CHS[3004150]] = CHS[3004150],
}

local PUSH_KEY =
{
    [CHS[3004146]] = "push_biaoxing_wanli",
    [CHS[3004147]] = "push_haidao_ruqin",
    [CHS[3004148]] = "push_chanchu_yaowang",
    [CHS[3004149]] = "push_shidao_dahui",
    [CHS[3004150]] = "push_shuadao_double",
}

-- 开启震动
function VibrateMgr:vibrate()
    if not gf:gfIsFuncEnabled(FUNCTION_ID.VIBRATE) then return  end -- c++ 函数没有生效

    
    local fun = 'vibrate'
    local v = fun .. ":nil"
    if gf:isAndroid() then
        local luaj = require('luaj')
        local className = 'org/cocos2dx/lua/AppActivity'
        local sig = "(I)V"
        local args = {}
        args[1] = 2000 -- 单位毫秒
        local ok = luaj.callStaticMethod(className, fun, args, sig)
        v = tostring(ok)
    elseif gf:isIos() then
        local luaoc = require('luaoc')
        local ok = luaoc.callStaticMethod('AppController', fun)
         v = tostring(ok)
    end

    Log:I('fun: ' .. fun .. ' result: ' ..  v )
    
end

-- 停止震动
function VibrateMgr:cancelVibrate()
    if not gf:gfIsFuncEnabled(FUNCTION_ID.CANCEL_VIBRATE) then return end -- c++ 函数没有生效
    
    local fun = 'cancelVibrate'
    local v = fun .. ":nil"
    if gf:isAndroid() then
        local luaj = require('luaj')
        local className = 'org/cocos2dx/lua/AppActivity'
        local sig = "()V"
        local args = {}
        local ok = luaj.callStaticMethod(className, fun, args, sig)
        v = tostring(ok)
    elseif gf:isIos() then
        local luaoc = require('luaoc')
        local ok = luaoc.callStaticMethod('AppController', fun)
        v = tostring(ok)
    end
    
    Log:I('fun: ' .. fun .. ' result: ' ..  v )
    
end

-- type  震动类型，包括dungeon,team,combat,laojun,remindSomeBody（通知其他人震动）
function VibrateMgr:sendVibrate(type, para)
    gf:CmdToServer("CMD_SHOCK", {type = type, para = para or ""})
end

function VibrateMgr:MSG_SHOCK()
    if not GameMgr:isInBackground() then
        SoundMgr:playHint("friend")
        self:vibrate()
    end
end

MessageMgr:regist("MSG_SHOCK", VibrateMgr)

return VibrateMgr
