-- GuardAdvanceDlg.lua
-- Created by zhengjh Sep/28/2015
-- 守护历练

local GuardAdvanceDlg = Singleton("GuardAdvanceDlg", Dialog)

function GuardAdvanceDlg:init()
    self:bindListener("AdvanceButton", self.onAdvanceButton)
    self:hookMsg("MSG_GUARD_EXPERIENCE_ID")
    self:hookMsg("MSG_GET_NEXT_RANK_GUARD")
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_REQUEST_GUARD_ID)
    self:setCtrlVisible("TaskPanel", false)
end

function GuardAdvanceDlg:cleanup()
    self.advanceGuardId = nil
end

function GuardAdvanceDlg:setGuardAdvanceInfo(guard)
    self:setGuardShapInfo(guard)
    self:setAdvanceInfo(guard)
    self.guard = guard
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_NEXT_GUARD_INFO, guard:queryBasic("id"))
end

function GuardAdvanceDlg:setGuardShapInfo(guard)

    -- 名字
    local name = guard:queryBasic("name")
    self:setLabelText("GuardNameLabel", name, self.root)

    -- 等级
    local level = guard:queryBasic("level")
    self:setLabelText("LevelLabel", level..CHS[3002747], self.root)

    -- 相性
    local polar = guard:queryBasicInt("polar")
    self:setLabelText("PolarLabel", gf:getPolar(polar))

    -- 形象
    local icon = guard:queryBasic("icon")
    self:setPortrait("GuardIconPanel", icon, 0, nil, true)

    -- 品质
    local rank = guard:queryBasicInt("rank")
    local imagePath = GuardMgr:getGuardRankImage(rank)
    self:setImage("QualityImage", imagePath)

    -- 守护介绍
    local polar = gf:getPolar(guard:queryBasicInt("polar"))
    local rank = guard:queryBasicInt("rank")
    local guardDecribe = GuardMgr:getGuardDescByPolarAndRank(polar, rank)
    self:setLabelText("DescLabel", guardDecribe)
end

function GuardAdvanceDlg:setAdvanceInfo(guard)

    if guard:queryBasicInt("rank") == GUARD_RANK.TONGZI then
        self:setLabelText("ProgressLabel", string.format(CHS[3002748], 5))
    elseif guard:queryBasicInt("rank") == GUARD_RANK.ZHANGLAO then
        self:setLabelText("ProgressLabel", string.format(CHS[3002748], 10))
    end


    -- 头像
    local oldShapePanel = self:getControl("OldShapePanel")
    local imgPath = ResMgr:getSmallPortrait(guard:queryBasicInt("icon"))
    self:setImage("GuardImage", imgPath, oldShapePanel)
    self:setItemImageSize("GuardImage", oldShapePanel)
    local rankPortraitImage = GuardMgr:getGuardPortraitIamge(guard:queryBasicInt("rank"))
    local coverImage = self:getControl("CoverImage", Const.UIImage, oldShapePanel)
    coverImage:loadTexture(rankPortraitImage, ccui.TextureResType.plistType)

    local newShapePanel = self:getControl("NewShapePanel")
    self:setImage("GuardImage", imgPath, newShapePanel)
    rankPortraitImage = GuardMgr:getGuardPortraitIamge(guard:queryBasicInt("rank") + 1)
    coverImage = self:getControl("CoverImage", Const.UIImage, newShapePanel)
    coverImage:loadTexture(rankPortraitImage, ccui.TextureResType.plistType)

    -- 气血
    self:setLabelText('OldLifeValueLabel', guard:queryBasicInt("life"))
    self:setLabelText('NewLifeValueLabel', guard:queryBasicInt("life"))

    -- 物伤
    self:setLabelText('OldPhyValueLabel', guard:queryBasicInt("phy_power"))
    self:setLabelText('NewPhyValueLabel', guard:queryBasicInt("phy_power"))

    -- 法伤
    self:setLabelText('OldMagValueLabel', guard:queryBasicInt("mag_power"))
    self:setLabelText('NewMagValueLabel', guard:queryBasicInt("mag_power"))

    -- 速度
    self:setLabelText('OldSpeedValueLabel', guard:queryBasicInt("speed"))
    self:setLabelText('NewSpeedValueLabel', guard:queryBasicInt("speed"))

    -- 防御
    self:setLabelText('OldDefenceValueLabel', guard:queryBasicInt("def"))
    self:setLabelText('NewDefenceValueLabel', guard:queryBasicInt("def"))
end

function GuardAdvanceDlg:onAdvanceButton(sender, eventType)
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3002749])
        return
    elseif self.advanceGuardId and self.advanceGuardId ~= 0 then
        local guard = GuardMgr:getGuard(self.advanceGuardId)
        if nil == guard then return end
        local guardName = guard:queryBasic("name")
        gf:ShowSmallTips(string.format(CHS[3002750], guardName))
    else
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_REQUEST_GUARD_EXPERIENCE, self.guard:queryBasic("id"))
    end
end

function GuardAdvanceDlg:MSG_GUARD_EXPERIENCE_ID(data)
    self.advanceGuardId = data.guard_id

    if data.guard_id == self.guard:queryBasicInt("id") then
        -- 当前任务
        self:setCtrlVisible("TaskPanel", true)
        local taskPanel = self:getControl("TaskNamePanel")
        local task = TaskMgr:getAdvanceTask()
        local infoSize = taskPanel:getContentSize()
        local tip = CGAColorTextList:create(true)
        tip:setFontSize(17)
        tip:setString(task)
        tip:setContentSize(infoSize.width, 0)
        tip:updateNow()
        tip:setPosition(0,0)
        local textW, textH = tip:getRealSize()
        local colorLayer = tolua.cast(tip, "cc.LayerColor")
        colorLayer:setAnchorPoint(0.5, 0.5)

        colorLayer:setPosition(taskPanel:getContentSize().width / 2, taskPanel:getContentSize().height / 2)
        taskPanel:addChild(colorLayer)

        local function onTaskPanel()
            if tip:getCsType() ~= CONST_DATA.CS_TYPE_NPC and tip:getCsType() ~= CONST_DATA.CS_TYPE_ZOOM then
                gf:onCGAColorText(tip, taskPanel)
            else
                local autoWalkInfo = gf:findDest(task)
                AutoWalkMgr:beginAutoWalk(autoWalkInfo)
            end

            DlgMgr:closeDlg(self.name)
            DlgMgr:closeDlg("GuardAttribDlg")
        end

        self:bindListener("TaskPanel", onTaskPanel)
    end
end

function GuardAdvanceDlg:MSG_GET_NEXT_RANK_GUARD(data)
   --[[ local newShapePanel = self:getControl("NewShapePanel")
    local coverImage = self:getControl("CoverImage", Const.UIImage, newShapePanel)
    local rankPortraitImage = GuardMgr:getGuardPortraitIamge(data.rank)
    coverImage:loadTexture(rankPortraitImage, ccui.TextureResType.plistType)]]

    -- 气血
    self:setLabelText('NewLifeValueLabel', data.life)

    -- 物伤
    self:setLabelText('NewPhyValueLabel', data.phy_power)

    -- 法伤
    self:setLabelText('NewMagValueLabel', data.mag_power)

    -- 速度
    self:setLabelText('NewSpeedValueLabel', data.speed)

    -- 防御
    self:setLabelText('NewDefenceValueLabel', data.def)
end

return GuardAdvanceDlg
