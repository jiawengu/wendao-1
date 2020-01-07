-- InnNpc.lua
-- Created by lixh Api/26/2018
-- 客栈Npc对象

local Char = require("obj/Char")
local InnNpc = class("InnNpc", Char)

function InnNpc:init()
    Char.init(self)
end

function InnNpc:getType()
    return "InnNpc"
end

-- 绑定事件
function InnNpc:bindEvent()
    -- 客栈Npc不能转向，不在init函数中设置的原因是
    -- init函数在Char:setAct之前执行，会导致服务器发过来的方向不生效
    self:setBasic("isFixDir", 1)

    if not self.needBindClickEvent then
        return
    end

    -- 绑定角色点击事件
    if self.charAction then
        local this = self
        local function onTouchBegan(touch, event)
            if event:getEventCode() == cc.EventCode.BEGAN then
                local function containsTouchPos()
                    if self.charAction.containsTouchPos then
                        return self.charAction:containsTouchPos(touch)
                    else
                        local pos = self.middleLayer:convertTouchToNodeSpace(touch)
                        local rect = self.charAction:getBoundingBox()
                        return cc.rectContainsPoint(rect, pos)
                    end
                end

                -- 可见时才处理 Touch 事件
                if containsTouchPos() and self.visible and self:isCanTouch() then
                    return true
                end

                return false
            elseif event:getEventCode() == cc.EventCode.ENDED then
                self:addFocusMagic()
                Me.selectTarget = self

                -- 直接请求打开npc对话框
                CharMgr:openNpcDlg(self:getId())
                return false
            end
        end

        gf:bindTouchListener(self.charAction, onTouchBegan, cc.Handler.EVENT_TOUCH_ENDED, false)
    end
end

return InnNpc