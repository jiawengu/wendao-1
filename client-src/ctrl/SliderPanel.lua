-- SliderPanel.lua
-- Created by zhengjh Apr/08/2016
-- 滚动条


local STAY_TIME = 500

local SliderPanel = class("SliderPanel", function()
    return ccui.Layout:create()
end)

function SliderPanel:ctor(contentSize, listView)
    self:setContentSize(contentSize)
    self.contentSize = contentSize
    self.listView = listView

    -- 滚动条
    self.sliderImage = ccui.ImageView:create(ResMgr.ui.slider_scroll_image, ccui.TextureResType.plistType)
    self.sliderImage:setPosition(contentSize.width / 2, contentSize.height)
    self.sliderImage:setVisible(false)
    self:addChild(self.sliderImage)
    self.opreatTime = nil

    schedule(self, self.update, 0)
end

function SliderPanel:update()
    local curTime = gf:getTickCount()
	if self.opreatTime and curTime - self.opreatTime > STAY_TIME then
        self.sliderImage:setVisible(false)
	end
end


function SliderPanel:scrolling()
    local listInnerContent = self.listView:getInnerContainer()
    local innerSize = listInnerContent:getContentSize()
    local listViewSize = self.listView:getContentSize()

    -- 计算滚动的百分比
    local totalHeight = innerSize.height - listViewSize.height

    local innerPosY = listInnerContent:getPositionY()
    local persent = 1 - (-innerPosY) / totalHeight

    if totalHeight > 0 and persent ~= 1 then
        self:setPrecent(persent)
    end
end

function SliderPanel:setPrecent(precent)
    local posy =  0
    if precent > 1  then
        posy = 0 - self.sliderImage:getContentSize().height * (precent - 1)
    elseif precent < 0  then
        posy = self.contentSize.height + self.sliderImage:getContentSize().height * (0 - precent)
    else
        posy = self.contentSize.height * (1 - precent)
    end

    self.sliderImage:setPositionY(posy)
    self.opreatTime = gfGetTickCount()
    self.sliderImage:setVisible(true)
end

return SliderPanel
