-- WeddinglistDlg.lua
-- Created by zhengjh Jun/20/2016
-- 结婚礼单

local WeddinglistDlg = Singleton("WeddinglistDlg", Dialog)

function WeddinglistDlg:init()
    self.itemCell = self:getControl("OneRowPartyMemberPanel")
    self.itemCell:retain()
    self.itemCell:removeFromParent()
    self:setTestDistUI()
end

function WeddinglistDlg:setTestDistUI()
    if DistMgr:curIsTestDist() then
        self:setCtrlVisible("GoldCoinImage", false, self.itemCell)
        self:setCtrlVisible("SilverCoinImage", true, self.itemCell)
        local panel = self:getControl("TotalPanel")
        self:setCtrlVisible("SilverCoinImage", true, panel)
        self:setCtrlVisible("GoldCoinImage", false, panel)
    else
        self:setCtrlVisible("GoldCoinImage", true, self.itemCell)
        self:setCtrlVisible("SilverCoinImage", false, self.itemCell)
        local panel = self:getControl("TotalPanel")
        self:setCtrlVisible("SilverCoinImage", false, panel)
        self:setCtrlVisible("GoldCoinImage", true, panel)
    end
end

function WeddinglistDlg:initList(data)
    local listView = self:getControl("ListView")
    listView:removeAllChildren()

    for i = 1, #data.items do
        listView:pushBackCustomItem(self:createCell(data.items[i], i)) 
    end
    
    self:setBottomInfo(data)
end

function WeddinglistDlg:createCell(data, index)
    local cell = self.itemCell:clone() 
    
    -- 设置头型
    local path = MarryMgr:getImagePath(data.name)
    self:setImage("Image", path, cell)
    self:setItemImageSize("Image", cell)
    
    -- 名字
    self:setLabelText("NameLabel", data.name, cell)
    
    local goldText = gf:getArtFontMoneyDesc(data.price or 0)
    self:setNumImgForPanel("CoinPanel", ART_FONT_COLOR.DEFAULT, goldText, false, LOCATE_POSITION.MID, 23, cell)
    
    if index % 2 == 0 then
        self:setCtrlVisible("BackImage_1", true, cell)
        self:setCtrlVisible("BackImage_2", false, cell)
    else
        self:setCtrlVisible("BackImage_1", false, cell)
        self:setCtrlVisible("BackImage_2", true, cell)
    end
    
    return cell
end

function WeddinglistDlg:getTotalMoney(data)
    local total = 0
    local list = data.items
    for i = 1, #list do
        total = list[i].price + total
    end
    
    return total
end

function WeddinglistDlg:setBottomInfo(data)

    -- 总额
    local goldText = gf:getArtFontMoneyDesc(self:getTotalMoney(data))
    self:setNumImgForPanel("TotalCoinPanel", ART_FONT_COLOR.DEFAULT, goldText, false, LOCATE_POSITION.MID, 23)
    
    self:setLabelText("TimeLabel", gf:getServerDate("%Y.%m.%d", data.time))
    
    self:setLabelText("MaleNameLabel", data.maleName)
    self:setLabelText("FemaleNameLabel", data.feMaleName)
end

function WeddinglistDlg:cleanup()
    self:releaseCloneCtrl("itemCell")
end

return WeddinglistDlg
