-- NoChatCell.lua
-- Created by sujl, Dec/8/2016
-- 不可交互聊天控件

local ChatCell = require("ctrl/ChatCell/ChatCell")
local NoChatCell = class("NoChatCell", ChatCell)

local WORD_COLOR = cc.c3b(86, 41, 2)

function NoChatCell:ctor(oneChatTable, width)
    self.width = width
    self:refresh(oneChatTable)
end

-- 不可以聊天交互
function NoChatCell:refresh(oneChatTable)
    self.oneChatTable = oneChatTable
    self:removeAllChildren()

    -- 单句聊天内容
    self:setPosition(0,0)
    self.textCtrl = CGAColorTextList:create()
    self.textCtrl:setFontSize(21)
    self.textCtrl:setString(self:getSystemTimeStr(self.oneChatTable["time"]).." "..(self.oneChatTable["chatStr"]),  self.oneChatTable["show_extra"])
    self.textCtrl:setContentSize(self.width, 0)
    self.textCtrl:setDefaultColor(WORD_COLOR.r, WORD_COLOR.g, WORD_COLOR.b)
    self.textCtrl:updateNow()
    local textW, textH = self.textCtrl:getRealSize()
    self.textCtrl:setPosition(0, textH)

    local function ctrlTouch(sender, eventType)
        if ccui.TouchEventType.ended == eventType then
            -- 处理类型点击
            gf:onCGAColorText(self.textCtrl, sender)
        end
    end

    local layer = tolua.cast(self.textCtrl, "cc.LayerColor")
    self:setContentSize(textW, textH)
    self:addChild(layer)
    self:setAnchorPoint(0,0)
    self:setTouchEnabled(true)
    self:addTouchEventListener(ctrlTouch)
end

function NoChatCell:getSystemTimeStr(time)
    local tiemStr = ""
    local timeTabel = os.date("*t",time)
    tiemStr = string.format("%02d:%02d:%02d", timeTabel["hour"], timeTabel["min"], timeTabel["sec"])
    return tiemStr
end

return NoChatCell