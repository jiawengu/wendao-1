-- ArtifactSubmitDlg.lua
-- Created by yangym Dec/23/2016
-- 法宝提交

local ArtifactSubmitDlg = Singleton("ArtifactSubmitDlg", Dialog)

function ArtifactSubmitDlg:init()
    -- 要洗炼的主法宝
    self.mainArtifact = nil

    -- 当前选中的法宝pos
    self.selectPos = nil

    -- 法宝列表中的所有法宝(isChosen字段代表是否被勾选)
    self.artifacts = {}

    -- 默认可提交数量
    self.submitNum = 2

    -- 默认提交类型
    self.submitType = "refine"

    self.artifactPanel = self:getControl("SingleArtifactPanel", Const.UIPanel)
    self.artifactPanel:retain()
    self.artifactPanel:removeFromParent()

    self.infoPanelContentSize = self:getControl("InfoPanel"):getContentSize()
    self.descPanel1ContentSize = self:getControl("DescPanel1"):getContentSize()
    self.descPanel2ContentSize = self:getControl("DescPanel2"):getContentSize()

    self.listView = self:getControl("ArtifactView")

    self:bindListener("SubmitButton", self.onSubmitButton)
end

-- 需要提交的法宝数量
function ArtifactSubmitDlg:setSubmitNum(num)
    self.submitNum = num

    -- 更新界面法宝数量消耗的提示
    if num == 1 then
        self:setCtrlVisible("TextLabel_1", false, "MarkPanel")
        self:setCtrlVisible("TextLabel_2", true, "MarkPanel")
    else
        self:setCtrlVisible("TextLabel_1", true, "MarkPanel")
        self:setCtrlVisible("TextLabel_2", false, "MarkPanel")
    end
end

-- 当前提交法宝的类型
-- 目前包括法宝洗炼（refine）、法宝特殊技能升级（skillup）
function ArtifactSubmitDlg:setSubmitType(type)
    self.submitType = type
end

function ArtifactSubmitDlg:setMainArtifact(artifact)
    self.mainArtifact = artifact
    self:updateArtifactList()
end

function ArtifactSubmitDlg:updateArtifactList()
    if not self.mainArtifact then
        return
    end

    local allBagArtifacts = InventoryMgr:getBagAllArtifacts()
    local artifacts = {}
    for i = 1, #allBagArtifacts do
        local artifact = allBagArtifacts[i]
        -- 找出当前主法宝同种类的非限时法宝
        if not InventoryMgr:isTimeLimitedItem(artifact)
                and artifact.pos ~= self.mainArtifact.pos
                and artifact.name == self.mainArtifact.name then
            table.insert(artifacts, artifact)
        end
    end

    -- 按照等级、亲密度排序
    table.sort(artifacts, function(l, r)
        if l.level < r.level then return true end
        if l.level > r.level then return false end

        if l.intimacy < r.intimacy then return true end
        if l.intimacy > r.intimacy then return false end
    end)

    -- 记录每个法宝的勾选状态，用isChosen字段保存
    self.artifacts = artifacts
    for i = 1, #self.artifacts do
        self.artifacts[i].isChosen = false
    end

    -- 初始化列表
    self.listView:removeAllChildren()
    self:setCtrlVisible("NonePanel", false)
    if #artifacts == 0 then
        self:setCtrlVisible("NonePanel", true)
    end

    for i = 1, #artifacts do
        local artifact = artifacts[i]
        local cell = self.artifactPanel:clone()
        cell:setTag(artifact.pos)
        self:setCheck("CheckBox_45", false, cell)
        self:setCellInfo(cell, artifact)

        -- 选中而不勾选
        local function func(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local tag = sender:getTag()
                self:onSelectArtifact(tag)
            end
        end

        cell:addTouchEventListener(func)

        -- 勾选
        local checkBox = self:getControl("CheckBox_45", Const.UICheckBox, cell)
        local function checkBoxClick(self, sender, eventType)
            local cell = sender:getParent()
            local tag = cell:getTag()
            local artifact = InventoryMgr:getItemByPos(tag)
            local chosenArtifacts = self:getChosenArtifacts()
            if eventType == ccui.TouchEventType.ended then
                if sender:getSelectedState() then
                    if #chosenArtifacts >= self.submitNum then
                        -- 如果当前要勾选某个法宝，但已经勾选过相应数量的法宝
                        self:setCheck("CheckBox_45", false, cell)
                        gf:ShowSmallTips(string.format(CHS[7002001], self.submitNum))
                        return
                    end

                    if gf:isExpensive(artifact) then
                        -- 勾选贵重法宝时给出提示
                        local tipStr
                        if self.submitType == "refine" then
                            tipStr = CHS[7100061]
                        elseif self.submitType == "skillup" then
                            tipStr = CHS[7100062]
                        end

                        gf:ShowSmallTips(tipStr)
                        self:setCheck("CheckBox_45", false, cell)
                        self:setArtifactChosenOrNot(tag, false)
                        return
                    end

                    -- 标记当前法宝的勾选情况
                    self:setArtifactChosenOrNot(tag, true)
                else

                    -- 标记当前法宝的勾选情况
                    self:setArtifactChosenOrNot(tag, false)
                end

                self:onSelectArtifact(tag)
            end
        end

        self:bindTouchEndEventListener(checkBox, checkBoxClick)

        self.listView:pushBackCustomItem(cell)
    end

    -- 默认选中第一个法宝
    if not self.selectPos then
        local cell = self.listView:getItem(0)
        self:onSelectArtifact(cell:getTag())
    else
        self:onSelectArtifact(self.selectPos)
    end

end

function ArtifactSubmitDlg:setCellInfo(cell, artifact)
    if not artifact then
        return
    end

    -- 法宝图标
    self:setImage("GuardImage", InventoryMgr:getIconFileByName(artifact.name), cell)
    self:setItemImageSize("GuardImage", cell)

    -- 图标左上角等级
    self:setNumImgForPanel("ShapePanel", ART_FONT_COLOR.NORMAL_TEXT,
        artifact.level, false, LOCATE_POSITION.LEFT_TOP, 21, cell)

    -- 图标右下角相性标志
    local img = self:getControl("GuardImage", nil, cell)
    if artifact.item_polar then
        InventoryMgr:addArtifactPolarImage(img, artifact.item_polar)
    end

    -- 图标左下角限制交易/限时标记
    if artifact and InventoryMgr:isTimeLimitedItem(artifact) then
        InventoryMgr:addLogoTimeLimit(img)
    elseif artifact and InventoryMgr:isLimitedItem(artifact) then
        InventoryMgr:addLogoBinding(img)
    end

    -- 法宝名称
    self:setLabelText("NameLabel", artifact.name, cell)

    -- 法宝特殊技能名称与等级
    local artifactSpSkillName = SkillMgr:getArtifactSpSkillName(artifact.extra_skill)
    if artifactSpSkillName then
        local artifactSpSkillLevel = tonumber(artifact.extra_skill_level)
        self:setLabelText("SkillNameLabel", artifactSpSkillName, cell)
        self:setLabelText("SkillLevelLabel", string.format(CHS[2000131], artifactSpSkillLevel), cell)
    else
        self:setLabelText("SkillNameLabel", CHS[7000329], cell, COLOR3.GRAY)
    end
end

-- 获取已被勾选的法宝
function ArtifactSubmitDlg:getChosenArtifacts()
    if not self.artifacts then
        return
    end

    local result = {}
    for i = 1, #self.artifacts do
        local artifact = self.artifacts[i]
        if artifact.isChosen then
            table.insert(result, artifact)
        end
    end

    return result
end

-- 将某个法宝设为勾选/非勾选状态
function ArtifactSubmitDlg:setArtifactChosenOrNot(tag, choseOrNot)
    if not self.artifacts then
        return
    end

    for i = 1, #self.artifacts do
        if self.artifacts[i].pos == tag then
            self.artifacts[i].isChosen = choseOrNot
        end
    end
end

-- 选中某个法宝
function ArtifactSubmitDlg:onSelectArtifact(tag)
    for k, v in pairs(self.listView:getChildren()) do
        self:setCtrlVisible("ChosenEffectImage", false, v)
    end

    local selectItem = self.listView:getChildByTag(tag)
    self:setCtrlVisible("ChosenEffectImage", true, selectItem)

    self.selectPos = tag

    self:refreshArtifactInfo()
end

-- 刷新右侧法宝详细信息
function ArtifactSubmitDlg:refreshArtifactInfo()
    if not self.selectPos then
        return
    end

    local artifact = InventoryMgr:getItemByPos(self.selectPos)
    if not artifact then
        return
    end

    -- 还原infoPanel为默认大小
    local infoPanel = self:getControl("InfoPanel")
    infoPanel:setContentSize(self.infoPanelContentSize)

    -- 法宝图标
    self:setImage("ArtifactIconImage", InventoryMgr:getIconFileByName(artifact.name), "MainArtifactPanel")
    self:setItemImageSize("ArtifactIconImage", "MainArtifactPanel")

    -- 图标左上角等级
    self:setNumImgForPanel("ArtifactIconBKImage", ART_FONT_COLOR.NORMAL_TEXT,
        artifact.level, false, LOCATE_POSITION.LEFT_TOP, 21, "MainArtifactPanel")

    -- 图标右下角相性标志
    local iconImage = self:getControl("ArtifactIconImage", nil, "MainArtifactPanel")
    InventoryMgr:removeArtifactPolarImage(iconImage)
    if artifact.item_polar then
        InventoryMgr:addArtifactPolarImage(iconImage, artifact.item_polar)
    end

    -- 图标左下角限制交易/限时标记
    if artifact and InventoryMgr:isTimeLimitedItem(artifact) then
        InventoryMgr:removeLogoBinding(iconImage)
        InventoryMgr:addLogoTimeLimit(iconImage)
    elseif artifact and InventoryMgr:isLimitedItem(artifact) then
        InventoryMgr:removeLogoTimeLimit(iconImage)
        InventoryMgr:addLogoBinding(iconImage)
    else
        InventoryMgr:removeLogoTimeLimit(iconImage)
        InventoryMgr:removeLogoBinding(iconImage)
    end

    -- 法宝名称
    self:setLabelText("NameLabel", artifact.name, "MainArtifactPanel")

    -- 法宝特殊技能名称与等级
    local artifactSpSkillName = SkillMgr:getArtifactSpSkillName(artifact.extra_skill)
    if artifactSpSkillName then
        local artifactSpSkillLevel = tonumber(artifact.extra_skill_level)
        self:setLabelText("SkillNameLabel", artifactSpSkillName, "MainArtifactPanel", COLOR3.LIGHT_BROWN)
        self:setLabelText("SkillLevelLabel", string.format(CHS[2000131], artifactSpSkillLevel), "MainArtifactPanel")
    else
        self:setLabelText("SkillNameLabel", CHS[7000329], "MainArtifactPanel", COLOR3.GRAY)
        self:setLabelText("SkillLevelLabel", "", "MainArtifactPanel")
    end

    -- 道法、灵气、亲密度、金相
    local daoFa = string.format(CHS[7000190], artifact.exp or 0, artifact.exp_to_next_level or 0)
    local lingQi = string.format(CHS[7000190], artifact.nimbus or 0, Formula:getArtifactMaxNimbus(artifact.level or 0))
    local qinMiDu = artifact.intimacy or 0
    local polarAttrib = EquipmentMgr:getPolarAttribByArtifact(artifact)
    self:setLabelText("DaoFaLabel2", daoFa)
    self:setLabelText("LingqiLabel2", lingQi)
    self:setLabelText("QinmiduLabel2", qinMiDu)
    self:setLabelText("PolarLabel2", polarAttrib)
    self:setLabelText("PolarLabel1", string.format(CHS[7000183], gf:getPolar(artifact.item_polar)))

    -- 法宝技能
    local descPanel1 = self:getControl("DescPanel1")
    local descPanel2 = self:getControl("DescPanel2")
    local descPanel1Height = self.descPanel1ContentSize.height
    local descPanel2Height = self.descPanel2ContentSize.height

    local desc1 = string.format(CHS[7000151], CHS[7000152]) .. CHS[7000078] .. EquipmentMgr:getArtifactSkillDesc(artifact.name)
    local height1 = self:setDescript(desc1, descPanel1, COLOR3.TEXT_DEFAULT)
    descPanel1:setContentSize(descPanel1:getContentSize().width, height1)

    -- 特殊技能
    local desc2
    if artifact.extra_skill and artifact.extra_skill ~= "" then
        local extraSkillName = SkillMgr:getArtifactSpSkillName(artifact.extra_skill)
        local extraSkillLevel = artifact.extra_skill_level
        local extraSkillDesc = SkillMgr:getSkillDesc(extraSkillName).desc
        desc2 = string.format(CHS[7000311], extraSkillName, extraSkillLevel)
            .. CHS[7000078] .. extraSkillDesc
    else
        desc2 = string.format(CHS[7000151], CHS[7000153]) .. CHS[7000078]
            .. CHS[3001385] .. "\n" .. CHS[7002016]
    end

    local height2 = self:setDescript(desc2, descPanel2, COLOR3.TEXT_DEFAULT)
    descPanel2:setContentSize(descPanel2:getContentSize().width, height2)

    -- 限制交易时间
    local bindLabel = self:getControl("BindLabel")
    local bindLabelHeight = bindLabel:getContentSize().height
    local height3 = - bindLabelHeight
    if InventoryMgr:isLimitedItem(artifact) then
        local str, day = gf:converToLimitedTimeDay(artifact.gift)
        self:setLabelText("BindLabel", str)
        height3 = 0
    end

    -- 限时时间
    local limitTimeLabel = self:getControl("LimitTimeLabel")
    local limitTimeLabelHeight = limitTimeLabel:getContentSize().height
    local height4 = - bindLabelHeight
    if InventoryMgr:isTimeLimitedItem(artifact) then
        local timeLimitStr
        if artifact.isTimeLimitedReward then
            timeLimitStr = CHS[7000191]
        else
            timeLimitStr = string.format(CHS[7000184], gf:getServerDate(CHS[4200022], artifact.deadline))
        end

        self:setLabelText("LimitTimeLabel", timeLimitStr)
        height4 = 0
    end

    -- 总高度自适应
    local offset = height1 - descPanel1Height + height2 - descPanel2Height + height3 + height4
    local infoPanel = self:getControl("InfoPanel")
    infoPanel:setContentSize(infoPanel:getContentSize().width, infoPanel:getContentSize().height + offset)

    local scollCtrl = self:getControl("ScrollView")
    scollCtrl:setInnerContainerSize(infoPanel:getContentSize())
    self:updateLayout("InfoPanel")
end

function ArtifactSubmitDlg:setDescript(descript, panel, defaultColor)
    panel:removeAllChildren()
    local textCtrl = CGAColorTextList:create()
    if defaultColor then
        textCtrl:setDefaultColor(defaultColor.r, defaultColor.g, defaultColor.b)
    end
    textCtrl:setFontSize(19)
    textCtrl:setString(descript)
    textCtrl:setContentSize(panel:getContentSize().width, 0)
    textCtrl:updateNow()

    -- 垂直方向居左显示
    local textW, textH = textCtrl:getRealSize()
    textCtrl:setPosition(0, textH)

    panel:addChild(tolua.cast(textCtrl, "cc.LayerColor"))
    return textH
end

function ArtifactSubmitDlg:onSubmitButton()
    local chosenArtifacts = self:getChosenArtifacts()
    if #chosenArtifacts < self.submitNum then
        if self.submitType == "refine" then
            gf:ShowSmallTips(CHS[7000338])
            return
        elseif self.submitType == "skillup" then
            gf:ShowSmallTips(string.format(CHS[7002006], self.submitNum))
            return
        end
    end

    if self.submitType == "refine" then
        DlgMgr:sendMsg("ArtifactRefineDlg", "refreshSecondaryArtifactPanel", chosenArtifacts)
    elseif self.submitType == "skillup" then
        DlgMgr:sendMsg("ArtifactSkillUpDlg", "refreshSecondaryArtifactPanel", chosenArtifacts)
    end

    self:close()
end

function ArtifactSubmitDlg:cleanup()
    self.mainArtifact = nil

    self.selectPos = nil

    self.artifacts = {}

    self.submitNum = 2

    self.submitType = "refine"

    self:releaseCloneCtrl("artifactPanel")
end

return ArtifactSubmitDlg