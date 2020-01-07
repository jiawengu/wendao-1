-- FightComObj.lua
-- Created by chenyq Nov/22/2014
-- 特殊战斗对象（不显示）

local FightObj = require('obj/fight/FightObj')

-- 与服务器端约定：特殊战斗对象的位置为 FightPosMgr.OBJ_NUM，id 为 0
local FightComObj = Singleton('FightComObj', FightObj.new(FightPosMgr.OBJ_NUM))
FightComObj.id = 0

function FightComObj:create(attr)
    if attr then
        self:absorbBasicFields(attr)
    end

    self:setBasic('id', FightComObj.id)
    self.isCreated = true
end

-- 清空动作
function FightComObj:clearAction()
    if not self.isCreated then
        return
    end

    self:setFinished(true)
end

return FightComObj