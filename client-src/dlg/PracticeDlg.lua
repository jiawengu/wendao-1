-- PracticeDlg.lua
-- Created by zhengjh Mar/5/2015
-- 练功主界面
local RewardContainer = require("ctrl/RewardContainer")

local CONST_DATA =
{
    PageContainerNumber = 3,
    DoublePointLimit = 200,
    DoublePointPrice = 200,
    FloatingFramWidth = 300,
    PracticeLimitTimes = 100,
    CellSpace = 5,

}

local DEFENCE_NO = 9167
local PHYATTACT_NO = 9166
local LIFE_NO   = 9169
local MANA_NO   = 9170
local PHYSIC_CONFIG =
{
    [DEFENCE_NO] = CHS[3002275],
    [PHYATTACT_NO] = CHS[3002276],
    [LIFE_NO] = CHS[3002277],
    [MANA_NO] = CHS[3002278],
}

local PracticeDlg = Singleton("PracticeDlg", Dialog)

function PracticeDlg:init()
    self:bindListener("LeftButton", self.onLeftButton)
    self:bindListener("RightButton", self.onRightButton)
    self:bindListener("PatrolButton", self.onPatrolButton)
    self:bindListener("FreezeDoubleButton", self.onFreezeDoubleButton)
    self:bindListener("AddDoublePointButton", self.onAddDoubleButton)
    self:bindListener("AddShenMuPointButton", self.onAddShenMuPointButton)
    self:bindListener("InfoButton", self.onInfoButton)
   -- self:bindCheckBoxListener("ExorcismCheckBox", self.onCheckBox)

    -- 获取控件
    self.listCell = self:getControl("MapListCellPanel", Const.UIPanel)
    self.listCell:retain()
    self.listCell:removeFromParent()
    self.scrollviewPanel = self:getControl("ScrollviewPanel", Const.UIPanel)
    self.scroview = ccui.ScrollView:create()
    self.scroview:setContentSize(self.scrollviewPanel:getContentSize())
    self.scroview:setDirection(ccui.ScrollViewDir.horizontal)
    self.scrollviewPanel:addChild(self.scroview)

    self.checkSDLTaskName = nil

    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_FIGHT_CMD_INFO")

    -- 初值化数据
    self:loadScrollviewData()
    self:MSG_UPDATE()

    -- 出去使用驱魔香的标志
    local soundStatePanel = self:getControl("OpenStatePanel")
    if PracticeMgr:getIsUseExorcism() then
       -- self:setCheck("ExorcismCheckBox", true)
        self:createSwichButton(soundStatePanel, true, self.onSwichButton, nil, self.isCanOpenQumoxiang)
    else
       -- self:setCheck("ExorcismCheckBox", false)
        self:createSwichButton(soundStatePanel, false, self.onSwichButton, nil, self.isCanOpenQumoxiang)
    end

    -- 使用双倍
    local useDoublePanel = self:getControl("UseOpenStatePanel", nil, "DoublePointPanel")
    if Me:queryBasicInt("enable_double_points") == 1 then

        self:createSwichButton(useDoublePanel, true, self.onSwichUseButton, nil, self.limitDouble)
    else

        self:createSwichButton(useDoublePanel, false, self.onSwichUseButton, nil, self.limitDouble)
    end

    -- 神木鼎
    local shenmuPanel = self:getControl("ShenMuOpenStatePanel")

    if Me:queryBasicInt("enable_shenmu_points") == 1 then
        self:createSwichButton(shenmuPanel, true, self.onSwichShenMuButton, nil, self.limitShenmu)
    else
        self:createSwichButton(shenmuPanel, false, self.onSwichShenMuButton, nil, self.limitShenmu)
    end

    -- 自动战斗
    local autoFightPanel = self:getControl("AutoFightOpenStatePanel")

    if Me:queryBasicInt('auto_fight') == 1 then
        self:createSwichButton(autoFightPanel, true, self.onSwichAutoFightButton)
    else
        self:createSwichButton(autoFightPanel, false, self.onSwichAutoFightButton)
    end

    self.initAutoFightSkill = false
    self:initAutoFightInfo()
    
    self:swichUpAndDownButton()

    OnlineMallMgr:openOnlineMall(nil, "notOpenDlg")
    
    gf:CmdToServer("CMD_AUTO_FIGHT_INFO")
end

function PracticeDlg:isCanOpenQumoxiang()
    return false
end

function PracticeDlg:limitDouble(isOn)
    if not isOn and Me:queryBasicInt("double_points") < 1 then
        gf:ShowSmallTips(CHS[5420215])
        return true
    end

    return false
end

function PracticeDlg:limitShenmu(isOn)
    if not isOn and Me:queryBasicInt("shenmu_points") < 1 then
        gf:ShowSmallTips(CHS[5420214])
        return true
    end
    
    return false
end

function PracticeDlg:onLeftButton(sender, eventType)
    self.pageView:scrollToPage(self.pageView:getCurPageIndex() - 1)
    self:setPageBtnVisible()
end

function PracticeDlg:onRightButton(sender, eventType)
    self.pageView:scrollToPage(self.pageView:getCurPageIndex() + 1)
    self:setPageBtnVisible()
end

function PracticeDlg:onTimeLeftinfoButton(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    self:showInfo(rect, CHS[6000052])
end

function PracticeDlg:onAutoWalkInfoButton(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    self:showInfo(rect, CHS[6000054])
end

function PracticeDlg:onInfoButton()
    DlgMgr:openDlg("PracticeRuleDlg")
end

function PracticeDlg:onDoublePointInfoButton(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    self:showInfo(rect, CHS[6000053])
end

function PracticeDlg:showInfo(rect, text)
    local dlg = DlgMgr:openDlg("FloatingFrameDlg")
    dlg:setText(text, CONST_DATA.FloatingFramWidth)
    dlg.root:setAnchorPoint(0, 0)
    dlg:setFloatingFramePos(rect)

    --[[local dlg = DlgMgr:openDlg("TaskCardDlg")
    local task = {}
    task["taskTitle"] = CHS[3003495]
    dlg:setData(task) ]]
end

function PracticeDlg:onAddDoubleButton(sender, envetType)
    -- 如果有光效，删除
    self:removeArmatureMagicFromCtrl(sender:getName(), Const.ARMATURE_MAGIC_TAG)

    if not DistMgr:checkCrossDist() then return end

    if Me:queryBasicInt("double_points") > PracticeMgr:getDoublePointLimit() - 200 then
        gf:ShowSmallTips(CHS[3003496])

    else
        DlgMgr:openDlg("PracticeBuyDoubleDlg")
    end


    --[[gf:confirm(CHS[6000051], function()
        local coin = Me:queryBasicInt('gold_coin') + Me:queryBasicInt('silver_coin')
        if coin < CONST_DATA.DoublePointPrice then
            gf:askUserWhetherBuyCoin()
        else
            gf:CmdToServer('CMD_GENERAL_NOTIFY', {type = NOTIFY.NOTIFY_BUY_DOUBLE_POINTS})
        end
    end) ]]
end

function PracticeDlg:onAddShenMuPointButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    if Me:queryBasicInt("shenmu_points") > PracticeMgr:getShenmuPointLimit() - 1000 then
        gf:ShowSmallTips(CHS[6000253])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onAddShenMuPointButton", sender, eventType) then
        return
    end

    DlgMgr:openDlg("PracticeBuyShenMuDlg")
end

function PracticeDlg:onFreezeDoubleButton(sender, eventType)
    gf:CmdToServer('CMD_GENERAL_NOTIFY', {type = NOTIFY.NOTIFY_FROZEN_DOUBLE_POINTS})
end

function PracticeDlg:onPatrolButton(sender, eventType)
    PracticeMgr:autoWalkOnCurMap(true)
end

-- 设置左右按钮隐藏和显示
function PracticeDlg:setPageBtnVisible()
      if self.pageView:getCurPageIndex() == 0 then
         self.leftBtn:setVisible(false)
      else
       self.leftBtn:setVisible(true)
      end

      if self.pageView:getCurPageIndex() == self.pageNumber - 1 then
         self.rightBtn:setVisible(false)
    else
       self.rightBtn:setVisible(true)
      end
end

-- 加载scrollview数据
function PracticeDlg:loadScrollviewData()
    self.monsterListTable = self:getMonsterList()
    table.sort(self.monsterListTable, function(a, b) return a["minLevel"] < b["minLevel"] end)
    local container = ccui.Layout:create()
    self.scroview:addChild(container)

    for i = 1, #self.monsterListTable  do
        local cell = self.listCell:clone()
        cell:setPosition((i - 1) * (self.listCell:getContentSize().width + CONST_DATA.CellSpace), 0)
        container:addChild(cell, 0, i)
        self:setMapInfo(i, cell, self.monsterListTable[i])
    end

    container:setContentSize((self.listCell:getContentSize().width + CONST_DATA.CellSpace) * #self.monsterListTable , self.scroview:getContentSize().height)
    self.scroview:setInnerContainerSize(container:getContentSize())
    self.scroview:jumpToRight()
end

-- 设置me信息
function PracticeDlg:setMeInfo()
    -- 练功剩余次数
 --[[   local leftTimesLabel = self:getControl("PracticeTimesLabel", Const.UILabel)
    leftTimesLabel:setString(string.format(CHS[6000045], Me:queryBasic("practice_times"), CONST_DATA.PracticeLimitTimes))]]

    -- 已领取双倍点数
    local haveDoublePoint = self:getControl("DoublePointLabel", Const.UILabel)
    haveDoublePoint:setString(string.format(CHS[3003497], Me:queryBasicInt("double_points")))

    -- 已获取的神木鼎点数
    self:setLabelText("ShenMuPointLabel", string.format(CHS[6000254], Me:queryBasicInt("shenmu_points")))
    self:getControl("PracticePanel", Const.UIPanel):requestDoLayout()
end

function PracticeDlg:setMapInfo(index, cell, monster)
    -- 怪物信息按钮
    local infoBtn = self:getControl("MonsterInfoButton", Const.UIButton, cell)
    infoBtn:setTag(cell:getTag())

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local tag = sender:getTag()
            local rect = self:getBoundingBoxInWorldSpace(infoBtn)
            local dlg = DlgMgr:openDlg("PracticeMonsterDlg")
            dlg:setMonsterData(self.monsterListTable[tag])
            dlg.root:setAnchorPoint(0, 0)
            dlg:setFloatingFramePos(rect)
        end
    end

    infoBtn:addTouchEventListener(listener)
    local isRecommend = false   --是否是推荐区域

    if monster["maxLevel"] >=  Me:queryBasicInt("level") then
        isRecommend = true
    end
    -- 怪物图片
    local monsterPanel = self:getControl("IconPanel", Const.UIPanel, cell)

    local function touch(sender, eventType)
        if ccui.TouchEventType.ended == eventType then
            -- 处于禁闭状态
           if Me:isInJail() then
                gf:ShowSmallTips(CHS[6000214])
                return
           elseif Me:isInCombat() then
                gf:ShowSmallTips(CHS[3003498])
                return
           elseif Me:isLookOn() then
                gf:ShowSmallTips(CHS[3003499])
                return
            elseif Me:isTeamMember() and not Me:isTeamLeader() then
                gf:ShowSmallTips(CHS[6000156])
                return
           end

           if isRecommend == false then
                local tips = CHS[6000138]
                if Me:queryBasicInt("enable_double_points") == 1 then
                    tips = tips .. "\n" ..  CHS[5400606]
                end

                gf:confirm(tips, function()
                    self:gotoPractice(monster)
                end)
           else
                self:gotoPractice(monster)
           end
        end
    end

    cell:addTouchEventListener(touch)
    self:setPortrait("IconPanel", monster["icon"], 0, cell, nil, nil, nil, nil, nil, self:getMonsterListSize() - index > 4)

    -- 地图名
    local mapNameLabel = self:getControl("MapNameLabel", Const.UILabel, cell)
    mapNameLabel:setString(monster["mapName"])

    -- 推荐等级
    local recommendImg = self:getControl("RecommendImage", Const.UIImage, cell)

    if isRecommend == true then
        recommendImg:setVisible(true)
    else
        recommendImg:setVisible(false)
    end

    local levelLabel = self:getControl("LevelLabel", Const.UILabel, cell)
    levelLabel:setString(string.format(CHS[6000047], monster["minLevel"], monster["maxLevel"]))
end

function PracticeDlg:gotoPractice(monster)
    local x, y = self:flyPosition(monster)
    if x ~= nil and y ~= nil then
        local autoWalkStr = string.format("#Z%s|%s(%d,%d)|$1#Z", monster["mapName"], monster["mapName"], x, y)
        local dest = gf:findDest(autoWalkStr)
        dest.needExorcismTips = true
        AutoWalkMgr:beginAutoWalk(dest)
        PracticeMgr:closeDlgAndSendMisc()
    end
end

function PracticeDlg:onSwichButton(isOn, key)
    if isOn == true then
--        PracticeMgr:setIsUseExorcism(true)
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_OPEN_EXORCISM)
    else
 --       PracticeMgr:setIsUseExorcism(false)
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_CLOSE_EXORCISM)
    end

    -- 如果有光效，删除
    self:removeArmatureMagicFromCtrl("OpenStatePanel", Const.ARMATURE_MAGIC_TAG)
end

function PracticeDlg:setNeedCheckShuaDaoLing(taskName)
    self.checkSDLTaskName = taskName
end

function PracticeDlg:onSwichUseButton(isOn, key)
    if isOn == true then
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_ENABLE_DOUBLE_POINTS, 1)
    else
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_ENABLE_DOUBLE_POINTS, 0)
    end

    -- 如果有光效，删除
    self:removeArmatureMagicFromCtrl("UseOpenStatePanel", Const.ARMATURE_MAGIC_TAG)

    if self.checkSDLTaskName then
        TaskMgr:checkShuaDaoLing(self.checkSDLTaskName)
        self.checkSDLTaskName = nil
    end
end


function PracticeDlg:onSwichShenMuButton(isOn, key)
    if isOn == true then
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_ENABLE_SHENMU_POINTS, 1)
    else
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_ENABLE_SHENMU_POINTS, 0)
    end

    -- 如果有光效，删除
    self:removeArmatureMagicFromCtrl("ShenMuOpenStatePanel", Const.ARMATURE_MAGIC_TAG)
end

function PracticeDlg:onSwichAutoFightButton(isOn, key)
    if isOn == true then
        Me:setBasic('auto_fight', 1)
        AutoFightMgr:autoFightSiwchStatus(1)
        gf:ShowSmallTips(CHS[7000041])
    else
        Me:setBasic('auto_fight', 0)
        AutoFightMgr:autoFightSiwchStatus(0)
        gf:ShowSmallTips(CHS[7000042])
    end
end

function PracticeDlg:initAutoFightInfo()
    if not AutoFightMgr:getMeActionTag() or not AutoFightMgr:getPetActionTag() then
        AutoFightMgr:setDefaultAction()
    end

    self:refreshAllData()
end

function PracticeDlg:refreshAllData()
    local playerData = AutoFightMgr:getPlayerAutoFightData()
    if playerData and playerData.multi_index == 1 and playerData.autoFightData and playerData.autoFightData[1] then        
        local data = {no = AutoFightMgr:getSkillNoByData(playerData.autoFightData[1])}
        self:initSelceltedPanel(data, "me")
    else
        self:initSelceltedPanel(AutoFightMgr:getMeActionTag(), "me")
    end
    

    local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()

    if pet then
        local petData = AutoFightMgr:getPetAutoFightData()
        if petData and petData.multi_index == 1 and  petData.zhSkillsData and petData.zhSkillsData[1] then
            local data = {no = AutoFightMgr:getSkillNoByData(petData.zhSkillsData[1])}
            self:initSelceltedPanel(data, "pet")
        else
            self:initSelceltedPanel(AutoFightMgr:getPetActionTag(), "pet")
        end
    
        
        self:setCtrlVisible("PetSkillImage", true, "PetFightsettingPanel")
    else
        self:setCtrlVisible("PetSkillImage", false, "PetFightsettingPanel")
    end

    self:updatePetLogoImage()
end

-- 刷新宠物技能后面的标志，有可能当前设置的是娃娃标志
function PracticeDlg:updatePetLogoImage()
    local logoBtn = self:getControl("PetLogoButton", nil, "PetFightsettingPanel")
    if HomeChildMgr:getFightKid() then
        logoBtn:loadTextureNormal(ResMgr.ui.kid_logo_image, 0)
    else
        logoBtn:loadTextureNormal(ResMgr.ui.button_pet, 0)
    end
end

function PracticeDlg:initSelceltedPanel(skillNo, name)
    if nil == skillNo then return end
    
    local skillName 
	-- 如果传入为表，说明回调时，是组合技能
    if type(skillNo) == "table" then
        skillName = CHS[4100979]
        skillNo = skillNo.no
    else    
        skillName = SkillMgr:getSkillName(skillNo)
    end    
    
    local image, path

    local function OneSecondLaterFunc(obj, sender, type)
        local rect = self:getBoundingBoxInWorldSpace(sender)
        if not PHYSIC_CONFIG[skillNo] then
            if name == "me" then
                SkillMgr:showSkillDescDlg(SkillMgr:getSkillName(skillNo), Me:getId(), false, rect)
            elseif name == "pet" then
                local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
                if pet then
                    if HomeChildMgr:getFightKid() then
                        SkillMgr:showSkillDescDlg(SkillMgr:getSkillName(skillNo), pet:getId(), false, rect)
                    else
                        SkillMgr:showSkillDescDlg(SkillMgr:getSkillName(skillNo), pet:getId(), true, rect)
                    end
                end
            end
        else
            local dlg = DlgMgr:openDlg("SkillFloatingFrameDlg")
            dlg:setSKillByName(PHYSIC_CONFIG[skillNo] , rect)
        end
    end

    if name == "me" then
        image = self:getControl("PlayerSkillImage", Const.UIImage, "PlayerFightsettingPanel")
        self:blindLongPress("PlayerSkillImage", OneSecondLaterFunc, self.onPlayerSkillPanel, "PlayerFightsettingPanel")
        self:bindListener("PlayerFightSettingButton", self.onPlayerSkillPanel)
        self:setLabelText("SkillLabel", skillName, "PlayerFightsettingPanel")       
        self.playerSkillNo = skillNo
    elseif name == "pet" then
        image = self:getControl("PetSkillImage", Const.UIImage, "PetFightsettingPanel")
        self:setCtrlVisible("PetSkillImage", true, "PetFightsettingPanel")
        self:blindLongPress("PetSkillImage", OneSecondLaterFunc, self.onPetSkillPanel, "PetFightsettingPanel")
        self:bindListener("PetFightSettingButton", self.onPetSkillPanel)
        self:setLabelText("SkillLabel", skillName, "PetFightsettingPanel")        
        self.petSkillNo = skillNo
    end

    if PHYSIC_CONFIG[skillNo] then
        path = ResMgr:getSkillIconPath(skillNo)
    else
        path = SkillMgr:getSkillIconPath(skillNo)
    end

    if image and nil ~= path then
        image:loadTexture(path)
        gf:setItemImageSize(image)
    end

    self:refreshManaImage()
end


function PracticeDlg:refreshManaImage()
    if self.playerSkillNo and not PHYSIC_CONFIG[self.playerSkillNo] then -- 刷新人物技能是否缺蓝图标
        local skillInfo = SkillMgr:getSkill(Me:getId(), self.playerSkillNo)
        local meMana
        if Me:isInCombat() then
            meMana = Me:queryInt("mana")
        else
            meMana = Me:getExtraRecoverMana()
        end

        if skillInfo and ((skillInfo.skill_mana_cost or 0 ) > meMana or not SkillMgr:isArtifactSpSkillCanUse(skillInfo.skill_name)) then        
            self:setCtrlVisible("NoManaImage", true, "PlayerFightsettingPanel")
        else
            self:setCtrlVisible("NoManaImage", false, "PlayerFightsettingPanel")
        end
    else
        self:setCtrlVisible("NoManaImage", false, "PlayerFightsettingPanel")
    end

    local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
    if pet and self.petSkillNo and not PHYSIC_CONFIG[self.petSkillNo] then
        local skillInfo = SkillMgr:getSkill(pet:getId(), self.petSkillNo)
        if skillInfo and ((skillInfo.skill_mana_cost or 0 ) > pet:getExtraRecoverMana() or not SkillMgr:isPetDunWuSkillCanUse(pet:getId(), skillInfo)) then
            -- 普通技能缺少魔法，或者顿悟技能缺少怒气/魔法/灵气
            self:setCtrlVisible("NoManaImage", true, "PetFightsettingPanel")
        else
            self:setCtrlVisible("NoManaImage", false, "PetFightsettingPanel")
        end
    else
        self:setCtrlVisible("NoManaImage", false, "PetFightsettingPanel")
    end
end


function PracticeDlg:onPlayerSkillPanel(sender, eventType)
    local dlg = DlgMgr:openDlg("OutAutoFightDlg")
    if dlg then
        dlg:initSkill("me")
        dlg:setCallBcak(self, self.initSelceltedPanel)
        local rectPanel = self:getControl("PlayerFightsettingPanel")
        
        -- 如果角色等级大于100级，有组合技能，界面需要整体右移
        if Me:queryInt("level") >= 100 then
            rectPanel = self:getControl("PetFightsettingPanel")
        end

        local rect = self:getBoundingBoxInWorldSpace(rectPanel)

        local panel = dlg:getControl("MainPanel")
        local rootBoundingBox = self:getBoundingBoxInWorldSpace(panel)
        local x = (rect.x + rect.width - rootBoundingBox.width)
        if Me:queryInt("level") >= 100 then
            x = x + 70
        end

        local winSize = self:getWinSize()
        local playerBoundingBox = self:getBoundingBoxInWorldSpace(dlg:getControl("PlayerSettingPanel"))
        local offsetY = playerBoundingBox.y - rootBoundingBox.y
        local y = rect.y  + rect.height - offsetY
        if y + offsetY + rootBoundingBox.height > winSize.height then
            y = winSize.height - rootBoundingBox.height - offsetY
        end

        panel:setAnchorPoint(0,0)
        local pos = panel:getParent():convertToNodeSpace(cc.p(x, y))
        panel:setPosition(pos)
    end

    self:setCtrlVisible("UpButton", true, "PlayerFightsettingPanel")
    self:setCtrlVisible("DownButton", false, "PlayerFightsettingPanel")
end

function PracticeDlg:onPetSkillPanel(sender, eventType)
    if not HomeChildMgr:getFightKid() and not PetMgr:getFightPet() then
        -- 无参战宠物，直接返回即可
        return
    end
    
    local dlg = DlgMgr:openDlg("OutAutoFightDlg")
    if dlg then
        if HomeChildMgr:getFightKid() then
            dlg:initSkill("kid")
        else
            dlg:initSkill("pet")
        end

        dlg:setCallBcak(self, self.initSelceltedPanel)
        local rectPanel = self:getControl("PetFightsettingPanel")
        local rect = self:getBoundingBoxInWorldSpace(rectPanel)

        local panel = dlg:getControl("MainPanel")
        local rootBoundingBox = self:getBoundingBoxInWorldSpace(panel)
        local x = rect.x + rect.width - rootBoundingBox.width

        -- 如果角色等级大于100级，有组合技能，界面需要整体右移
        if Me:queryInt("level") >= 100 then
            x = x + 70
        end

        local winSize = self:getWinSize()
        local petBoundingBox = self:getBoundingBoxInWorldSpace(dlg:getControl("PetSettingPanel"))
        local offsetY = petBoundingBox.y - rootBoundingBox.y
        local y = rect.y  + rect.height - offsetY
        if y + offsetY + rootBoundingBox.height > winSize.height then
            y = winSize.height - rootBoundingBox.height - offsetY
        end

        local pos = panel:getParent():convertToNodeSpace(cc.p(x, y))
        panel:setAnchorPoint(0,0)
        panel:setPosition(pos)
    end

    self:setCtrlVisible("UpButton", true, "PetFightsettingPanel")
    self:setCtrlVisible("DownButton", false, "PetFightsettingPanel")
end

function PracticeDlg:swichUpAndDownButton()
    self:setCtrlVisible("UpButton", false, "PetFightsettingPanel")
    self:setCtrlVisible("DownButton", true, "PetFightsettingPanel")
    self:setCtrlVisible("UpButton", false, "PlayerFightsettingPanel")
    self:setCtrlVisible("DownButton", true, "PlayerFightsettingPanel")
end

-- 获取传送位置
function PracticeDlg:flyPosition(monster)
    local mapInfo =  MapMgr:getMapinfo()

    for k,v in pairs(mapInfo) do
        if v["map_name"] == monster["mapName"] then
            return v["teleport_x"],v["teleport_y"]
        end
    end

    gf:ShowSmallTips(CHS[6000073])
end

function PracticeDlg:MSG_UPDATE()
      self:setMeInfo()
      self:refreshManaImage()
end

-- 获取等级相应的怪物的个数
function PracticeDlg:getMonsterListSize()
    local monsterList = self:getMonsterList()
    if nil == monsterList then
        monsterList = {}
    end

    return #monsterList
end

-- 获取等级相应的怪物
function PracticeDlg:getMonsterList()
    local monsterListTable = {}
    local allMonsterList = PracticeMgr:getMonsterList()

    for i = 1,#allMonsterList do
        if allMonsterList[i]["minLevel"] <= Me:queryBasicInt("level") + 2 then
            table.insert(monsterListTable, allMonsterList[i])
        end
    end

    return monsterListTable
end

-- 标记关闭界面时，开启自动寻路
function PracticeDlg:setAutoWalkAfterCloseDlg(flag)
    self.needAutoWalk = flag
end

function PracticeDlg:cleanup()
    self:releaseCloneCtrl("listCell")
    self.petSkillNo = nil
    self.playerSkillNo = nil
    
    if self.needAutoWalk then
        if PracticeMgr:getIsUseExorcism() then
            gf:confirm(CHS[5400072], function()
                -- 关闭驱魔香并自动巡逻
                gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_CLOSE_EXORCISM)
                PracticeMgr:autoWalkOnCurMap()
            end)
        else
            -- PracticeMgr:autoWalkOnCurMap() 中会调用到 PracticeDlg:onCloseButton()，故延时一帧
            performWithDelay(gf:getUILayer(), function ()
                PracticeMgr:autoWalkOnCurMap()
            end, 0)
        end
        
        self.needAutoWalk = false
    end

    if self.checkSDLTaskName then
        TaskMgr:checkShuaDaoLing(self.checkSDLTaskName)
        self.checkSDLTaskName = nil
    end
end

function PracticeDlg:MSG_FIGHT_CMD_INFO(data)
    self:initAutoFightInfo()
end

return PracticeDlg
