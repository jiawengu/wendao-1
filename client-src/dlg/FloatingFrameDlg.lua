-- FloatingFrameDlg.lua
-- Created by zhengjh Mar/9/2015
-- 文字悬浮框

local FloatingFrameDlg = Singleton("FloatingFrameDlg", Dialog)

local def_width = 350
local font_height = 19
local MARGIN_HEIGHT = 20

function FloatingFrameDlg:init()
    self.root:removeAllChildren()
end

function FloatingFrameDlg:setText(text, contentWidth)
    if string.match(text, "babyType") then -- 元婴指引，需要具体到玩家的元婴类型
        text = string.gsub(text, "babyType", "")
        text = string.format(text, Me:getChildName())
    end

    self.root:removeAllChildren()
    contentWidth = contentWidth or def_width
    local lableText = CGAColorTextList:create()
    lableText:setFontSize(font_height)
    lableText:setString(text)
    lableText:setContentSize(contentWidth, 0)
    lableText:updateNow()
    local labelW, labelH = lableText:getRealSize()
    local layerColor = tolua.cast(lableText, "cc.LayerColor")
    self.root:addChild(layerColor)
    self.root:setContentSize(labelW + 30, labelH + 20)      

    local pos = cc.p((self.root:getContentSize().width - labelW) * 0.5, (self.root:getContentSize().height - labelH) * 0.5 + labelH)
    layerColor:setPosition(pos)
end

return FloatingFrameDlg
