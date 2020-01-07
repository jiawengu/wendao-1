-- BlogMoreInfoDlg.lua
-- Created by sujl, Sept/25/2017
-- 空间更多信息界面

local BlogMoreInfoDlg = Singleton("BlogMoreInfoDlg", Dialog)

function BlogMoreInfoDlg:init(gid)
    cc.SpriteFrameCache:getInstance():addSpriteFrames("ui/polaricon.plist")
    self.oneInfoPanel = self:retainCtrl("OneInfoPanel", "InfoPanel")
    self.infoPanel = self:getControl("InfoPanel")
    self.mainPanel = self:getControl("MainPanel")
    local dlgSize = self.mainPanel:getContentSize()
    local infoPanelSize = self.infoPanel:getContentSize()
    self.dlgWidth = dlgSize.width
    self.minHeight = dlgSize.height - infoPanelSize.height
    
    self.gid = gid

    self:refresh()
end

function BlogMoreInfoDlg:refresh()
    local data = BlogMgr:getUserDataByGid(self.gid)
    if not data then return end
    local polarImage = self:getControl("TypeImage", nil, "MainPanel")
    local polarPath = BlogMgr:getPolarImageByGid(self.gid)
    if polarImage and polarPath then
        polarImage:loadTexture(polarPath, ccui.TextureResType.plistType)
    end

    self:setLabelText("NameLabel", data.name, "MainPanel")
    self:setLabelText("NameLabel", string.isNilOrEmpty(BlogMgr:getTitleByGid(self.gid)) and CHS[2000453] or CharMgr:getChengweiShowName(BlogMgr:getTitleByGid(self.gid)), self:getControl("NameBKImage", nil, "MainPanel"))




    local partyName = data.party_name
    self:initInfoPanel(CHS[2000454], string.isNilOrEmpty(partyName) and CHS[2000455] or partyName)
    local coupleName = data.couple_name
    if string.isNilOrEmpty(coupleName) then
        self:initInfoPanel(CHS[2000456], CHS[2000457])
    else
        self:initInfoPanel(GENDER_TYPE.MALE == data.gender and CHS[2000458] or CHS[2000459], coupleName)
    end


    local brothers = data.brothers
    if not brothers or #brothers <= 0 then
        self:initInfoPanel(CHS[2000460], CHS[2000461])
    else
        for i = 1, #brothers do
            if self.gid ~= brothers[i].gid then
                self:initInfoPanel(brothers[i].chengWei, brothers[i].name)
            end
        end
    end

    -- 修正一下界面高度
    local children = self.infoPanel:getChildren()
    local itemSize = self.oneInfoPanel:getContentSize()
    local height = #children * itemSize.height
    local panelSize = self.infoPanel:getContentSize()
    self.infoPanel:setContentSize(cc.size(panelSize.width, height))
    self.mainPanel:setContentSize(cc.size(self.dlgWidth, self.minHeight + height))

    local item
    for i = 1, #children do
        item = children[i]
        item:setPosition(cc.p(0, height - i * itemSize.height))
    end
end

function BlogMoreInfoDlg:initInfoPanel(key, value)
    if string.isNilOrEmpty(value) then return end
    local item = self.oneInfoPanel:clone()
    self:setLabelText("TitelLabel", key, item)
    self:setLabelText("InfoLabel", value, item)
    self.infoPanel:addChild(item)
end

return BlogMoreInfoDlg