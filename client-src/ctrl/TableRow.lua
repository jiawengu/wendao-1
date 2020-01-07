-- TableRow.lua
-- Created by chenyq Jan/12/2015
-- 表格列表中的一行，一行有若干列，每一列显示一段文本

local TableRow = class('TableRow', function()
    return ccui.Layout:create()
end)

-- w, h 格子的默认宽高
-- colNum 列数
function TableRow:ctor(w, h, colNum, fontSize, color)
    self:setTouchEnabled(true)
    self:ignoreAnchorPointForPosition(false)
    self:setAnchorPoint(0, 0)
    fontSize = fontSize or 20
    color = color or COLOR3.TEXT_DEFAULT
    self.cols = {}
    for j = 1, colNum do
        local label = ccui.Text:create()
        label:ignoreContentAdaptWithSize(false)
        label:setContentSize(w, h)
        label:setFontSize(fontSize)
        label:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        label:setTextVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
        label:setAnchorPoint(0, 0)
        label:setColor(color)
        self:addChild(label)
        table.insert(self.cols, label)
    end
end

function TableRow:setText(idx, text, w)
    local label = self.cols[idx]
    if label then
        label:setString(text)
        
        -- 如果有宽度信息，则重新设置宽度
        if w then
            local sz = label:getContentSize()
            label:setContentSize(w, sz.height)
        end
    end
end

function TableRow:doLayout()
    local x = 0
    local sz
    for i = 1, #self.cols do
        local ctl = self.cols[i]
        sz = ctl:getContentSize()
        ctl:setPositionX(x)
        x = x + sz.width
    end
    
    self:setContentSize(x, sz.height)
end

return TableRow
