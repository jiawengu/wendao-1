-- QianktDlg.lua
-- Created by lixh2 May/10/2018
-- 2018中元节乾坤图界面

local QianktDlg = Singleton("QianktDlg", Dialog)

local MAP_CFG = {
    [CHS[7190210]] = {[1] = {"2048_1024", "2304_1024"}, [2] = {"512_256", "768_256"},       [3] = {"256_1792", "512_1792"}},    -- 无名小镇
    [CHS[7190211]] = {[1] = {"2048_0", "2304_0"},       [2] = {"256_256", "512_256"},       [3] = {"768_1536", "1024_1536"}},   -- 东海渔村
    [CHS[7190212]] = {[1] = {"512_512", "768_512"},     [2] = {"2816_1536", "3072_1536"},   [3] = {"512_1280", "768_1280"}},    -- 揽仙镇
    [CHS[7190213]] = {[1] = {"1536_1536", "1792_1536"}, [2] = {"0_1792", "256_1792"}},                                          -- 十里坡
    [CHS[7190214]] = {[1] = {"768_768", "1024_768"},    [2] = {"0_512", "256_512"},         [3] = {"1536_768", "1792_768"}},    -- 蓬莱岛
    [CHS[7190215]] = {[1] = {"1024_0", "1280_0"},       [2] = {"3072_2816", "3328_2816"},   [3] = {"256_3072", "512_3072"}},    -- 天墉城
}

function QianktDlg:init()
    self:setFullScreen()
    self:bindListener("ConfrimButton", self.onConfrimButton)
    
    self:hookMsg("MSG_ENTER_ROOM")
end

function QianktDlg:setData(mapName, index)
    local mapCfg = MAP_CFG[mapName][index]
    if mapCfg then
        local pic1 = ccui.ImageView:create(self:getMapBlockByName(mapName, mapCfg[1]))
        local pic2 = ccui.ImageView:create(self:getMapBlockByName(mapName, mapCfg[2]))
        gf:grayImageView(pic1)
        gf:grayImageView(pic2)
        pic1:setAnchorPoint(0, 0)
        pic2:setAnchorPoint(0, 0)
        local panel = self:getControl("MapPanel")
        panel:addChild(pic1)
        panel:addChild(pic2)
        local picWidth = pic1:getContentSize().width
        pic1:setPosition(3, 0)
        pic2:setPosition(3 + picWidth, 0)
    end
end

function QianktDlg:getMapBlockByName(mapName, blockName)
    local mapInfo = MapMgr:getMapInfoByName(mapName)
    if mapInfo then
        return string.format("maps/%05d/%s.jpg", mapInfo.map_id, blockName)
    end
end

function QianktDlg:onConfrimButton(sender, eventType)
    self:onCloseButton()
end

function QianktDlg:MSG_ENTER_ROOM()
    self:onCloseButton()
end

return QianktDlg
