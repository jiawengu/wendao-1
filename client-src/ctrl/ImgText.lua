-- ImgText.lua
-- Created by chenyq Dec/24/2014
-- 左边显示图片，右边显示文本的控件，文本使用颜色字符串控件显示

local MARGIN_X = 2
local normalColor = cc.c4b(0, 128, 0, 128)
local selectedColor = cc.c4b(128, 128, 0, 128)

local ImgText = class("ImgText", function()
    return ccui.Layout:create()
end)

function ImgText:ctor(imgFile, text, w, h)
    self:setContentSize(w, h)
    self:setBackGroundImage(ResMgr.ui.img_text_bg, ccui.TextureResType.plistType)
    self:setBackGroundImageCapInsets(cc.rect(10, 10, 60, 80))
    self:setBackGroundImageScale9Enabled(true)

    self.img = ccui.ImageView:create(imgFile, 0)
    self.img:setPosition(3, h / 2)
    self.img:setAnchorPoint(0, 0.5)
    self:addChild(self.img)

    local textX = self.img:getContentSize().width + MARGIN_X
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(20)
    textCtrl:setString(text)
    textCtrl:setContentSize(w - textX, 0)
    textCtrl:updateNow()
    
    -- 垂直方向居中显示
    local textW, textH = textCtrl:getRealSize()
    textCtrl:setPosition(textX, textH + (h - textH) / 2)

    self:addChild(tolua.cast(textCtrl, "cc.LayerColor"))

    -- 选中图片
    self.selectImg = ccui.ImageView:create(ResMgr.ui.img_text_select, ccui.TextureResType.localType)
    self.selectImg:setPosition(0, h / 2)
    self.selectImg:setAnchorPoint(0, 0.5)
    self.selectImg:setCapInsets(cc.rect(20, 20, 34, 34))
    self.selectImg:setScale9Enabled(true)
    self.selectImg:setContentSize(w, h)
    self:addChild(self.selectImg)
    self.selectImg:setVisible(false)
end

-- 设置是否选中了
function ImgText:setSelected(selected)
    if selected then
        self.selectImg:setVisible(true)
    else
        self.selectImg:setVisible(false)
    end
end

-- 置灰图片
function ImgText:grayImg()
    if not self.img then
        return
    end
    
    gf:grayImageView(self.img)
end

return ImgText
