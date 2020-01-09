-- ArtifactRefineDlg.lua
-- Created by yangym Dec/23/2016
-- 法宝洗练界面

local ArtifactRefineDlg = Singleton("ArtifactRefineDlg", Dialog)

local COST_COIN = 466

local ARTIFACT_REFINE_MIN_LEVEL = 70

function ArtifactRefineDlg:init()
    self:bindListener("ArtifactImagePanel_1", self.onSelectSecondaryArtifact)
    self:bindListener("ArtifactImagePanel_2", self.onSelectSecondaryArtifact)
    self:bindListener("InfoButton", self.onRuleButton)
    self:bindListener("RefineButton", self.onRefineButton)
    self:setCtrlEnabled("RefineButton", false)
    self:setCtrlVisible("NoneArtifactImage", true, "ArtifactImagePanel")
    self:setCtrlVisible("FrameImage", false, "ArtifactImagePanel")

    local secondaryArtifactPanel1 = self:getControl("ArtifactImagePanel_1")
    local secondaryArtifactPanel2 = self:getControl("ArtifactImagePanel_2")
    secondaryArtifactPanel1:setTouchEnabled(true)
    secondaryArtifactPanel2:setTouchEnabled(true)

    self.selectArtifact = nil
    self.selectSecondaryArtifact1 = nil
    self.selectSecondaryArtifact2 = nil

    -- 金银元宝勾选框
    self.radio = self:getControl("CheckBox", Const.UICheckBox)
    self.radio:setSelectedState(InventoryMgr.isUseGoldRefineArtifact)
    if InventoryMgr.isUseGoldRefineArtifact then
        self:setCtrlVisible("CoinImage_1", false, "CoinPanel")
        self:setCtrlVisible("CoinImage_2", true, "CoinPanel")
    else
        self:setCtrlVisible("CoinImage_1", true, "CoinPanel")
        self:setCtrlVisible("CoinImage_2", false, "CoinPanel")
    end

    local function checkBoxClick(self, sender, eventType)
        if eventType == ccui.CheckBoxEventType.selected then
            self:setCtrlVisible("CoinImage_1", false, "CoinPanel")
            self:setCtrlVisible("CoinImage_2", true, "CoinPanel")
            InventoryMgr.isUseGoldRefineArtifact = true
        elseif eventType == ccui.CheckBoxEventType.unselected then
            self:setCtrlVisible("CoinImage_1", true, "CoinPanel")
            self:setCtrlVisible("CoinImage_2", false, "CoinPanel")
            InventoryMgr.isUseGoldRefineArtifact = false
        end
    end

    self:bindCheckBoxWidgetListener(self.radio, checkBoxClick)

    self:refreshSecondaryArtifactPanel()
end

function ArtifactRefineDlg:setArtifactInfo(artifact)
    if not artifact or artifact.item_type ~= ITEM_TYPE.ARTIFACT then
        return
    end

    self:setCtrlVisible("NoneArtifactImage", false, "ArtifactImagePanel")
    self:setCtrlVisible("FrameImage", true, "ArtifactImagePanel")

    local lastSelectedArtifact = self.selectArtifact
    self.selectArtifact = artifact

    -- 法宝图标
    self:setImage("ArtifactImage", InventoryMgr:getIconFileByName(artifact.name), "ArtifactImagePanel")
    self:setItemImageSize("ArtifactImage", "ArtifactImagePanel")
    self:setCtrlVisible("ArtifactImage", true, "ArtifactImagePanel")

    -- 图标左上角等级
    self:setNumImgForPanel("ArtifactImagePanel", ART_FONT_COLOR.NORMAL_TEXT,
        artifact.level, false, LOCATE_POSITION.LEFT_TOP, 21)

    -- 图标右下角相性标志
    local img = self:getControl("ArtifactImage", nil, "ArtifactImagePanel")
    InventoryMgr:removeArtifactPolarImage(img)
    if artifact.item_polar then
        InventoryMgr:addArtifactPolarImage(img, artifact.item_polar)
    end

    -- 图标左下角限制交易/限时标记
    if InventoryMgr:isTimeLimitedItem(artifact) then
        InventoryMgr:removeLogoBinding(img)
        InventoryMgr:addLogoTimeLimit(img)
    elseif InventoryMgr:isLimitedItem(artifact) then
        InventoryMgr:removeLogoTimeLimit(img)
        InventoryMgr:addLogoBinding(img)
    else
        InventoryMgr:removeLogoTimeLimit(img)
        InventoryMgr:removeLogoBinding(img)
    end

    -- 点击弹出法宝名片
    local function func(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local rect = self:getBoundingBoxInWorldSpace(sender)
            local selectArtifact = self.selectArtifact
            InventoryMgr:showArtifact(selectArtifact, rect, true)
        end
    end

    local artifactImage = self:getControl("ArtifactImage", nil, "ArtifactImagePanel")
    artifactImage:addTouchEventListener(func)

    -- 法宝名称
    self:setLabelText("ArtifactNameLabel", artifact.name)

    -- 洗练预览部分
    -- 洗练前
    local artifactSpSkillName = SkillMgr:getArtifactSpSkillName(artifact.extra_skill)
    if artifactSpSkillName then
        local artifactSpSkillLevel = tonumber(artifact.extra_skill_level)
        self:setLabelText("SkillNameLabel", artifactSpSkillName, "OldArtifactSkillPanel", COLOR3.TEXT_DEFAULT)
        self:setLabelText("SkillNLabel", string.format(CHS[2000131], artifactSpSkillLevel), "OldArtifactSkillPanel")
    else
        self:setLabelText("SkillNameLabel", CHS[7000329], "OldArtifactSkillPanel", COLOR3.GRAY)
        self:setLabelText("SkillNLabel", "", "OldArtifactSkillPanel")
    end

    -- 洗练后
    self:setLabelText("SkillNameLabel", CHS[7000330], "NewArtifactSkillPanel")
    self:setLabelText("SkillNLabel", CHS[7000331], "NewArtifactSkillPanel")

    -- 消耗元宝数量
    local cost = COST_COIN
    local costText, costColor = gf:getArtFontMoneyDesc(cost)
    self:setNumImgForPanel("CoinValuePanel", costColor, costText, false, LOCATE_POSITION.MID, 23)

    -- 重置选择的副法宝

    local useLastSelectedSecondaryArtifacts = false
    if lastSelectedArtifact and lastSelectedArtifact.iid_str == artifact.iid_str
          and self.selectSecondaryArtifact1 and InventoryMgr:getItemByIIdFromBag(self.selectSecondaryArtifact1.iid_str)
          and self.selectSecondaryArtifact2 and InventoryMgr:getItemByIIdFromBag(self.selectSecondaryArtifact2.iid_str) then
        -- 如果当前的主法宝是上一次选择的主法宝，且上一次选择副法宝仍然可用，则不重置之前选择的副法宝
        useLastSelectedSecondaryArtifacts = true
    end

    if not useLastSelectedSecondaryArtifacts then
        self:refreshSecondaryArtifactPanel()
    end

    self:setCtrlEnabled("RefineButton", true)
end


-- 更新副法宝
function ArtifactRefineDlg:refreshSecondaryArtifactPanel(chosenArtifacts)
    if not chosenArtifacts or #chosenArtifacts < 2 then
        self.selectSecondaryArtifact1 = nil
        self.selectSecondaryArtifact2 = nil
        self:setCtrlVisible("NoneImage", true, "ArtifactImagePanel_1")
        self:setCtrlVisible("ArtifactPanel", false, "ArtifactImagePanel_1")
        self:setCtrlVisible("NoneImage", true, "ArtifactImagePanel_2")
        self:setCtrlVisible("ArtifactPanel", false, "ArtifactImagePanel_2")
        return
    end

    self.selectSecondaryArtifact1 = chosenArtifacts[1]
    self.selectSecondaryArtifact2 = chosenArtifacts[2]
    self:setCtrlVisible("NoneImage", false, "ArtifactImagePanel_1")
    self:setCtrlVisible("ArtifactPanel", true, "ArtifactImagePanel_1")
    self:setCtrlVisible("NoneImage", false, "ArtifactImagePanel_2")
    self:setCtrlVisible("ArtifactPanel", true, "ArtifactImagePanel_2")

    for i = 1, 2 do
        local mainArtifactName = "ArtifactImagePanel_" .. i
        local artifact = chosenArtifacts[i]
        -- 法宝图标
        self:setImage("ArtifactImage", InventoryMgr:getIconFileByName(artifact.name), mainArtifactName)
        self:setItemImageSize("ArtifactImage", mainArtifactName)

        -- 图标左上角等级
        self:setNumImgForPanel("ArtifactPanel", ART_FONT_COLOR.NORMAL_TEXT,
            artifact.level, false, LOCATE_POSITION.LEFT_TOP, 21, mainArtifactName)

        -- 图标右下角相性标志
        local img = self:getControl("ArtifactImage", nil, mainArtifactName)
        InventoryMgr:removeArtifactPolarImage(img)
        if artifact.item_polar then
            InventoryMgr:addArtifactPolarImage(img, artifact.item_polar)
        end

        -- 限制交易标志
        if artifact and InventoryMgr:isLimitedItem(artifact) then
            InventoryMgr:addLogoBinding(img)
        else
            InventoryMgr:removeLogoBinding(img)
        end
    end
end

-- 规则界面
function ArtifactRefineDlg:onRuleButton()

    local data = {one = CHS[4200588], isScrollToDef = true}
    DlgMgr:openDlgEx("ArtifactRuleNewDlg", data)
end

-- 打开副法宝选择界面
function ArtifactRefineDlg:onSelectSecondaryArtifact(sender, eventType)
    local mainArtifact = self.selectArtifact
    if not mainArtifact then
        gf:ShowSmallTips(CHS[7002011])
        return
    end

    local artifacts = InventoryMgr:getBagAllArtifacts()
    local count = 0
    for i = 1, #artifacts do
        if artifacts[i].name == self.selectArtifact.name
              and not InventoryMgr:isTimeLimitedItem(artifacts[i])
              and artifacts[i].pos ~= mainArtifact.pos then
            count = count + 1
        end
    end

    if count < 2 then
        gf:ShowSmallTips(CHS[7000332])
        return
    end

    local dlg = DlgMgr:openDlg("ArtifactSubmitDlg")
    dlg:setMainArtifact(self.selectArtifact)
    dlg:setSubmitType("refine")
    dlg:setSubmitNum(2)
end

function ArtifactRefineDlg:onRefineButton()
    if not DistMgr:checkCrossDist() then return end

    local artifact = self.selectArtifact

    if not artifact then
        return
    end

    -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3002430])
        return
    end

    -- 玩家等级不够
    if Me:getLevel() <  ARTIFACT_REFINE_MIN_LEVEL then
        gf:ShowSmallTips(string.format(CHS[3004067],  ARTIFACT_REFINE_MIN_LEVEL))
        return
    end

    -- 限时法宝
    if InventoryMgr:isTimeLimitedItem(artifact) then
        gf:ShowSmallTips(CHS[7000333])
        return
    end

    -- 法宝等级不够
    if artifact.level < 7 then
        gf:ShowSmallTips(CHS[7000334])
        return
    end

    if not self.selectSecondaryArtifact1
        or self.selectSecondaryArtifact1.name ~= artifact.name
        or not self.selectSecondaryArtifact2
        or self.selectSecondaryArtifact2.name ~= artifact.name then
        gf:ShowSmallTips(CHS[7000335])
        return
    end

    self:refineArtifact()
end

function ArtifactRefineDlg:refineArtifact()
    local artifact = self.selectArtifact
    local isUsingSilver = not InventoryMgr.isUseGoldRefineArtifact
    if not artifact then
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("refineArtifact") then
        return
    end

    -- 元宝不足判断
    local totalCoin
    if isUsingSilver then
        totalCoin = math.max(Me:queryInt("silver_coin"), 0) + math.max(Me:queryInt("gold_coin"), 0)
    else
        totalCoin = math.max(Me:queryInt("gold_coin"), 0)
    end

    if totalCoin < COST_COIN then
        gf:askUserWhetherBuyCoin()
        return
    end

    -- 获取增加的限制交易时间
    local str, day = gf:converToLimitedTimeDay(artifact.gift)
    local count = 0
    if InventoryMgr:isLimitedItemForever(self.selectSecondaryArtifact1) then
        count = count + 10
    end

    if InventoryMgr:isLimitedItemForever(self.selectSecondaryArtifact2) then
        count = count + 10
    end

    if isUsingSilver and Me:queryInt("silver_coin") > 0 then
        count = count + 10
    end

    local skillName = SkillMgr:getArtifactSpSkillName(artifact.extra_skill)
    local skillLevel = artifact.extra_skill_level
    local mainArtifactPos = self.selectArtifact.pos
    local secondaryArtifact1Pos = self.selectSecondaryArtifact1.pos
    local secondaryArtifact2Pos = self.selectSecondaryArtifact2.pos
    local usingSilverFlag = 1
    if isUsingSilver then
        usingSilverFlag = 0
    end

    local data = {pos = mainArtifactPos,
                  type = Const.EQUIP_REFINE_ARTIFACT,
                  para = secondaryArtifact1Pos .. "|" .. secondaryArtifact2Pos .. "|" .. usingSilverFlag}

    if isUsingSilver and math.max(Me:queryInt("silver_coin"), 0) < COST_COIN then
        -- 银元宝不足时，需要用金元宝代替，弹出确认框
        gf:confirm(string.format(CHS[7003004], COST_COIN - math.max(Me:queryInt("silver_coin"), 0)), function()
            if day <= Const.LIMIT_TIPS_DAY and count > 0 then
                gf:confirm(string.format(CHS[7000337], count), function()
                    if skillName then
                        gf:confirm(string.format(CHS[7002010], skillLevel, skillName), function()
                            gf:CmdToServer("CMD_UPGRADE_EQUIP", data)
                            return
                        end)
                        return
                    end

                    gf:CmdToServer("CMD_UPGRADE_EQUIP", data)
                    return
                end)
                return
            end

            if skillName then
                gf:confirm(string.format(CHS[7002010], skillLevel, skillName),
                    function()
                        gf:CmdToServer("CMD_UPGRADE_EQUIP", data)
                        return
                    end)
                return
            end

            gf:CmdToServer("CMD_UPGRADE_EQUIP", data)
        end)
        return
    end

    if day <= Const.LIMIT_TIPS_DAY and count > 0 then
        gf:confirm(string.format(CHS[7000337], count), function()
            if skillName then
                gf:confirm(string.format(CHS[7002010], skillLevel, skillName),
                    function()
                        gf:CmdToServer("CMD_UPGRADE_EQUIP", data)
                        return
                    end)
                return
            end

            gf:CmdToServer("CMD_UPGRADE_EQUIP", data)
            return
        end)
        return
    end

    if skillName then
        gf:confirm(string.format(CHS[7002010], skillLevel, skillName),
            function()
                gf:CmdToServer("CMD_UPGRADE_EQUIP", data)
                return
            end)
        return
    end

    gf:CmdToServer("CMD_UPGRADE_EQUIP", data)
end

return ArtifactRefineDlg
