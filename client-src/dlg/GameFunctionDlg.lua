-- GameFunctionDlg.lua
-- created by cheny Oct/14/2014
-- 游戏功能对话框
local LIMIT_SECONDS = 20 -- 若20s内没点击则隐藏功能按钮

local GameFunctionDlg = Singleton("GameFunctionDlg", Dialog)
local BtnList = {}

-- 所有按钮
local btnPosMap = {
    -- 状态1
    ["PartyButton"]     = 2,  -- 帮派
    ["ForgeButton"]     = 3,  -- 打造
    ["HomeButton"]      = 4,  -- 居所
    ["GuardButton"]     = 5,  -- 守护
    ["SocialButton"]    = 11, -- 社交
    -- 状态2
    ["WatchCenterButton"]   = 6,    -- 观战中心
    ["AchievementButton"]   = 8,    -- 成就
    ["SystemButton"]        = 9,    -- 设置
    ["SocialButton"]        = 11,   -- 社交
    ["BagButton"]           = 101,
}

local NEED_HIDE_IN_SERVER = {
    ["PartyButton"]       = true,  -- 帮派
    ["ForgeButton"]       = true,  -- 打造
    ["HomeButton"]        = true,  -- 居所
    ["GuardButton"]       = true,  -- 守护
    ["WatchCenterButton"] = true,  -- 观战中心
    ["AchievementButton"] = true,  -- 成就
    ["SocialButton"]      = true,   -- 社交
}

-- 新的按钮排布方式
local ButtonState = {
    -- 每种状态具体显示哪些按钮，在STATUS1_BTN、STATUS2_BTN、STATUS3_BTN定义
    -- 状态正常切换为  3 -> 1 -> 2 - > 3
    -- 状态转换按钮包括StatusButton1（+）、StatusButton2(X)、StatusButton3(-)
    -- 允许疯狂的点击状态转换按钮按钮，点击状态转换按钮按钮可以即时切换状态转换按钮
    -- （即状态转换按钮与左侧的按钮可以短时间内不匹配）

    -- 同时，此逻辑保证，只要点击了StatusButton(i)，最后一定能切换到状态i
    State1 = 1,  -- 切换按钮显示为X
    State2 = 2,  -- 切换按钮显示为—
    State3 = 3,  -- 切换按钮显示为+，且左侧不显示图标
}

-- 状态一显示的按钮（X）
local STATUS1_BTN = GFD_STATUS1_BTN

-- 状态二显示的按钮（-）
local STATUS2_BTN = GFD_STATUS2_BTN

-- 状态三显示按钮（+），不显示其他按钮，点击便展开到状态一
local STATUS3_BTN =
{
}

-- 二级按钮：目前包括打造下的装备、首饰、法宝
local SECOND_ICON_LIST =
{
    ["ArtifactButton"] = {order = 1, parent = "ForgeButton"},
    ["JewelryButton"] = {order = 2, parent = "ForgeButton"},
    ["EquipButton"] = {order = 3, parent = "ForgeButton"},

    ["MarryBookButton"] = {order = 1, parent = "SocialButton"},
    ["FindLovebutton"] = {order = 2, parent = "SocialButton"},
    ["TeachButton"] = {order = 3, parent = "SocialButton"},
    ["CommunityButton"] = {order = 4, parent = "SocialButton"},
}

-- 收起和展开的时间
local ACTION_TIME = 0.25

-- 收起和置隐的差值秒数（由于收起后需要在收起到右下角之前隐藏按钮）
local DIF_TIME_BETWEEN_ACTION_AND_HIDE = 0.15

local DELAY_TIME = 0.1

GameFunctionDlg.fastUseItemName = ""

local BUTTON_SIZE = 78
local BUTTON_MARGIN = 15

local GM_BUTTON_POS = {cc.p(320, 132), cc.p(411, 132)}

GameFunctionDlg.actNum  = 0

local TYPE_HORIZONTAL = 1
local TYPE_VERTICAL = 2

local cartoonList = {}

-- 打开帮派界面
local function openPartyInfoDlg()
    EventDispatcher:removeEventListener('MSG_PARTY_INFO', openPartyInfoDlg)

    local last = DlgMgr:getLastDlgByTabDlg('PartyInfoTabDlg') or 'PartyInfoDlg'
    DlgMgr:openDlg(last)
end



function GameFunctionDlg:init()
    local winSize = self:getWinSize()
    self:align(ccui.RelativeAlign.alignParentRightBottom, cc.p(-winSize.ox, winSize.oy + winSize.y))
    self:bindListener("AchievementButton", self.onAchievementButton)
    self:bindListener("PartyButton", self.onPartyButton)
    self:bindListener("EquipButton", self.onEquipButton)
    self:bindListener("ForgeButton", self.onForgeButton)
    self:bindListener("SocialButton", self.onSocialButton)
    self:bindListener("HideForgeButton", self.onForgeButton)
    self:bindListener("HideSocialButton", self.onSocialButton)
    self:bindListener("GuardButton", self.onGuardButton)
    self:bindListener("SystemButton", self.onSystemButton)
    self:bindListener("BagButton", self.onBagButton)
    self:bindListener("GMButton", self.onGMButton)
    self:bindListener("WatchCenterButton", self.onWatchCenterButton)
    self:bindListener("StatusButton1", self.onStatusButton1)
    self:bindListener("StatusButton2", self.onStatusButton2)
    self:bindListener("StatusButton3", self.onStatusButton3)
    self:bindListener("PuttingButton", self.onPuttintButton, "HomePanel")
    self:bindListener("HomeButton", self.onHomeButton)
    self:bindListener("TakeButton", self.onTakeButton, "HomePanel")
    self:bindListener("PlantButton", self.onPlantButton, "HomePanel")
    self:bindListener("FishButton", self.onFishButton, "HomePanel")
    self:bindListener("HomeManageButton", self.onHomeManageButton)
    self:bindListener("MarryBookButton", self.onMarryBookButton)
    self:bindListener("FindLoveButton", self.onFindLoveButton)
    self:bindListener("TeachButton", self.onTeachButton)
    self:bindListener("CommunityButton", self.onCommunityButton)
    self:bindListener("CloseButton", self.onCloseHomePanelButton, "HomePanel")

    self:bindListener("JewelryButton", self.onJewelryButton)
    self:bindListener("ArtifactButton", self.onArtifactButton)
    self:bindListener("AdministratorsButton", self.onAdministratorsButton)

    self:bindListener("KidButton", self.onKidButton)
    self:setCtrlVisible("ChildTipsPanel", false)

    self:setCtrlVisible("GMButton", false)
    self:setCtrlVisible("AdministratorsButton", false)
    self:setCtrlVisible("WatchCenterButton", false)
    self:setCtrlVisible("MarryBookTipsPanel", false)

    local button1 = self:getControl("StatusButton1", Const.UIButton)
    button1:setLocalZOrder(1)
    local button2 = self:getControl("StatusButton2", Const.UIButton)
    button2:setLocalZOrder(1)
    local button3 = self:getControl("StatusButton2", Const.UIButton)
    button2:setLocalZOrder(1)
    local x, y = button1:getPosition()

    local forgePanel = self:getControl("BackImage", nil, "ForgePanel")
    self.forgeSize = self.forgeSize or forgePanel:getContentSize()
    local bagBtn = self:getControl("BagButton", Const.UIButton)
    bagBtn:setPosition(x, y + BUTTON_SIZE + BUTTON_MARGIN)
    self:tryToAutoHide(true)

    self:showHouseButton()

    self:hookMsg("MSG_ICON_CARTOON")
    self:hookMsg("MSG_RESET_FAST_USE_ITEM")
    self:hookMsg("MSG_PLAY_INSTRUCTION")
    self:hookMsg("MSG_TASK_PROMPT")

    self:hookMsg("MSG_HOUSE_FURNITURE_DATA")
    self:hookMsg("MSG_HOUSE_DATA")
    self:hookMsg("MSG_ENTER_ROOM")

    self:hookMsg("MSG_MATCH_ADMIN_DATA")

    -- 如果是GM号显示GM按钮
    self:setCtrlVisible("GMButton", GMMgr:isGM())
    self:updateGMButtonPos()
end

function GameFunctionDlg:cleanup()
    BtnList = {}
    self.param = nil
    self.equipIsShow = nil
    self.socialIsShow = nil
    self:tryToAutoHide(true)
    EventDispatcher:removeEventListener('MSG_PARTY_INFO', openPartyInfoDlg)

    if not DistMgr:getIsSwichServer() then
        -- 非换线时，需要重置快捷使用物品勿扰信息
        self:MSG_RESET_FAST_USE_ITEM()
    end
end

-- 结婚纪念册光效
function GameFunctionDlg:doMarryEffect(pos)
    local dlg = DlgMgr:getDlgByName("BagDlg")
    if not dlg then
        self:setCtrlVisible("MarryBookTipsPanel", true)
        local bagBtn = self:getControl("BagButton")
        gf:createArmatureMagic(ResMgr.ArmatureMagic.main_ui_btn, bagBtn, Const.ARMATURE_MAGIC_TAG, 2, 0)
        local ctrl = bagBtn:getChildByTag(Const.ARMATURE_MAGIC_TAG)
        if ctrl then
            ctrl.guidePos = pos
        end
    end
end

-- 微社区指引光效
function GameFunctionDlg:doCommunityGuide()
    -- 提示
    gf:ShowSmallTips(CHS[7150071])

    -- 创建光效
    gf:createArmatureMagic(ResMgr.ArmatureMagic.main_ui_btn, self:getControl("CommunityButton"), Const.ARMATURE_MAGIC_TAG, 2, 0)

    -- WDSY-35297，玩家升到20级开启社区时，服务器后通知NOTICE_UPDATE_MAIN_ICON刷新界面图标
    -- 由于微社区开启前状态1还没有任何图标开启，导致切换到状态1失败，进而社交Panel位置不对，所以延迟0.5s切换状态
    performWithDelay(self.root, function()
        if self.curState ~= ButtonState.State1 then
            -- 先切换到状态1
            self.curState = ButtonState.State1
            self:onStatusButton1()
        end

        if not self.socialIsShow then
            -- 延迟 切换到状态1的时间 + 0.1秒 显示社交子目录
            performWithDelay(self.root, function()
                self:setSocialState()
            end, ACTION_TIME + 0.1)
        end
    end, 0.5)
end

function GameFunctionDlg:doShowOrHideButton()
    -- 控制各按钮的显示与隐藏
    for i = 1, #STATUS1_BTN do
        local needShow = (self.curState == ButtonState.State1) and self:isContainIcon(STATUS1_BTN[i])
        if STATUS1_BTN[i] == "ForgeButton" and self.equipIsShow then
            -- 打造按钮的两个状态不能同时显示
            needShow = false
        elseif STATUS1_BTN[i] == "SocialButton" and self.socialIsShow then
            needShow = false
        end
            self:setCtrlVisible(STATUS1_BTN[i], needShow)
        end

    for i = 1, #STATUS2_BTN do
        self:setCtrlVisible(STATUS2_BTN[i],
            (self.curState == ButtonState.State2) and self:isContainIcon(STATUS2_BTN[i]))
    end
end

function GameFunctionDlg:clearAllAction(isRefresh)
    for i = 1, #STATUS1_BTN do
        local ctrl = self:getControl(STATUS1_BTN[i])
        ctrl:stopAllActions()
    end

    for i = 1, #STATUS2_BTN do
        local ctrl = self:getControl(STATUS2_BTN[i])
        ctrl:stopAllActions()
    end

    if isRefresh then
        local bagBtn = self:getControl("BagButton")
        bagBtn:stopAllActions()
        local homeManageBtn = self:getControl("HomeManageButton")
        homeManageBtn:stopAllActions()
    end
end

function GameFunctionDlg:doStateChangeButton(state)
    self:setCtrlVisible("StatusButton1", state == ButtonState.State3)
    self:setCtrlVisible("StatusButton2", state == ButtonState.State1)
    self:setCtrlVisible("StatusButton3", state == ButtonState.State2)
    self.curButtonState = state
end

function GameFunctionDlg:onStatusButton1()
    if GameMgr:mainUIIsMoving() then
        -- WDSY-27514 修改
        return
    end

    -- 点击BUTTON1，收起状态二的按钮，展开状态一的按钮
    if GameMgr:isHideAllUI() then
        GameMgr:showAllUI()
    end

    -- 如果下一个时更多，要判断更多项中是否有按钮，没有则跳过
    if not self:checkIsExsitIcon(STATUS1_BTN) then
        self:onStatusButton2()
        return
    end

    self:clearAllAction()
    self:doShowOrHideButton()
    self:doStateChangeButton(ButtonState.State1)
    RedDotMgr:updateGFDShowBtnRedDot()
    self:tryToAutoHide()
    if self.curState == ButtonState.State1 then
        -- 展开状态一的按钮
        self:showButton(STATUS1_BTN, ACTION_TIME, function()
            self:doShowOrHideButton()
        end)
    elseif self.curState == ButtonState.State2 then
        self:hideButton(STATUS2_BTN, ACTION_TIME, function()
            self:showButton(STATUS1_BTN, ACTION_TIME, function()
                self.curState = ButtonState.State1
                self:doShowOrHideButton()
            end)
        end)
    elseif self.curState == ButtonState.State3 then
        self:showButton(STATUS1_BTN, ACTION_TIME, function()
            self.curState = ButtonState.State1
            self:doShowOrHideButton()
        end)
    end
end

function GameFunctionDlg:onStatusButton2()
    -- 点击BUTTON2，收起状态一的按钮，展开状态二的按钮
    self:clearAllAction()
    self:doShowOrHideButton()
    self:doStateChangeButton(ButtonState.State2)
    RedDotMgr:updateGFDShowBtnRedDot()
    self:tryToAutoHide()
    if self.curState == ButtonState.State1 then
        self:hideButton(STATUS1_BTN, ACTION_TIME, function()
            self:showButton(STATUS2_BTN, ACTION_TIME, function()
                self.curState = ButtonState.State2
                self:doShowOrHideButton()
            end)
        end)
    elseif self.curState == ButtonState.State2 then
        self:showButton(STATUS2_BTN, ACTION_TIME, function()
            self.curState = ButtonState.State2
            self:doShowOrHideButton()
        end)
    elseif self.curState == ButtonState.State3 then
        self:showButton(STATUS2_BTN, ACTION_TIME, function()
            self.curState = ButtonState.State2
            self:doShowOrHideButton()
        end)
    end
end

function GameFunctionDlg:onStatusButton3()
    -- 点击BUTTON3，收起状态一或者状态二的按钮
    self:clearAllAction()
    self:doShowOrHideButton()
    self:doStateChangeButton(ButtonState.State3)
    RedDotMgr:updateGFDShowBtnRedDot()
    if self.curState == ButtonState.State1 then
        self:hideButton(STATUS1_BTN, ACTION_TIME, function()
            self.curState = ButtonState.State3
            self:doShowOrHideButton()
        end)
    elseif self.curState == ButtonState.State2 then
        self:hideButton(STATUS2_BTN, ACTION_TIME, function()
            self.curState = ButtonState.State3
            self:doShowOrHideButton()
        end)
    elseif self.curState == ButtonState.State3 then

    end
end

-- 检测 buttons表中，是否有存在主界面的按钮
function GameFunctionDlg:checkIsExsitIcon(buttons)
    for k = 1, #buttons do
        local v = self:getControl(buttons[k])
        if self:isContainIcon(v:getName()) then
            return true
        end
    end

    return false
end

function GameFunctionDlg:showButton(buttons, time, callBackFunc)
    -- 在一定时间内展开部分按钮的通用逻辑
    local basicBtn = self:getControl("StatusButton1", Const.UIButton)
    local x, y = basicBtn:getPosition()

    local mark = 1
    for k = 1, #buttons do
        local v = self:getControl(buttons[k])
        if self:isContainIcon(v:getName()) then
            local contentSize = v:getContentSize()
            local move = cc.MoveTo:create(time, cc.p(x - mark * (BUTTON_SIZE + BUTTON_MARGIN) + BUTTON_SIZE / 2 - contentSize.width / 2, contentSize.height / 2))
            v:stopAllActions()
            v:setVisible(true)

            v:runAction(move)
            if callBackFunc and mark == 1 then
                local delay = time - DIF_TIME_BETWEEN_ACTION_AND_HIDE
                v:runAction(cc.Sequence:create(cc.DelayTime:create(delay), cc.CallFunc:create(callBackFunc)))
            end

            if self.param then
                -- 指引相关
                local param = self.param
                -- v:stopAllActions()
                v:runAction(cc.Sequence:create(move, cc.DelayTime:create(DELAY_TIME), cc.CallFunc:create(function()
                    GuideMgr:youCanDoIt(self.name, param)
                end)))
                self.param = nil
            end

            mark = mark + 1
        end
    end

    self.isMoveToHide = false

    if self.equipIsShow then
        self:setCtrlVisible("ForgeButton", false)
    end

    if self.socialIsShow then
        self:setCtrlVisible("SocialButton", false)
    end

    -- 如果矿石大战的宝石使用界面处于展开状态，则收起
    if DlgMgr:isDlgOpened("OreFunctionDlg") then
        local dlg = DlgMgr:getDlgByName("OreFunctionDlg")
        dlg:onCloseButton()
    end

    -- 如果矿石大战的宝石使用界面处于展开状态，则收起
    if DlgMgr:isDlgOpened("ZhiDuoXingDlg") then
        local dlg = DlgMgr:getDlgByName("ZhiDuoXingDlg")
        dlg:onCloseButton()
    end
end

function GameFunctionDlg:hideButton(buttons, time, callBackFunc)
    -- 在一定时间内收起部分按钮的通用逻辑
    -- 先处理一下打造二级界面
    self:setEquipState(true)
    self:setSocialState(true)
    local basicBtn = self:getControl("StatusButton1", Const.UIButton)
    local x, y = basicBtn:getPosition()
    self.isMoveToHide = true
    for k = 1, #buttons do
        local v = self:getControl(buttons[k])
        local contentSize = v:getContentSize()
        local move = cc.MoveTo:create(time, cc.p(x - contentSize.width / 3, contentSize.height / 2))
        v:stopAllActions()
        local func = cc.CallFunc:create(function()
            v:setVisible(false)
            if k == #buttons then
                -- 最后一个按钮隐藏，去除标记
                self.isMoveToHide = false
            end
        end)

        local action = cc.Sequence:create(move, func)
        v:runAction(action)
        if callBackFunc and k == 1 then
            local delay = time - DIF_TIME_BETWEEN_ACTION_AND_HIDE
            v:runAction(cc.Sequence:create(cc.DelayTime:create(delay), cc.CallFunc:create(callBackFunc)))
        end
    end
end

function GameFunctionDlg:onPartyButton()
    if not DistMgr:checkCrossDist() then return end

    local limitJoinPartyLevel = PartyMgr:getJoinPartyLevelMin()
    if Me:queryBasicInt("level") < limitJoinPartyLevel then
        gf:ShowSmallTips(CHS[4000273])
        return
    end

    if Me:queryBasic("party/name") == "" then
        -- 无帮派,有未处理的邀请则显示邀请界面
        local inviteData = PartyMgr:getInviteList()
        if next(inviteData) then
            DlgMgr:openDlg("InviteJoinPartyDlg")
        else
            -- 显示申请和创建
            DlgMgr:openDlg("JoinPartyDlg")
        end
        return
    end

    -- 有帮派清除其他人邀请列表
    PartyMgr:setInviteListClean()

    -- 重新请求帮派信息及帮派日志
    PartyMgr:queryPartyInfo()
    --PartyMgr:queryPartyLog()

    -- 有帮派显示帮派信息

    if PartyMgr:getPartyInfo() then
        openPartyInfoDlg()
    else
        EventDispatcher:addEventListener('MSG_PARTY_INFO', openPartyInfoDlg)
    end

    self:tryToAutoHide()
end

-- 控制显示/隐藏法宝图标，目前用于指引法宝图标开启
function GameFunctionDlg:showOrHideArtifact(showArtifact)

    self:setCtrlVisible("ForgeButton", false)
    self:setCtrlVisible("HideForgeButton", true)

    local forgePanel = self:getControl("HideForgeButton")
    local panel = self:getControl("BackImage", nil, forgePanel)
    local equipBtn = self:getControl("EquipButton")
    local jewelryBtn = self:getControl("JewelryButton")
    local artifactBtn = self:getControl("ArtifactButton")
    local btnSize = jewelryBtn:getContentSize()
    if showArtifact then
        artifactBtn:setContentSize(btnSize)
        equipBtn:setContentSize(btnSize)
        panel:setContentSize(self.forgeSize)
    else
        artifactBtn:setContentSize(0, 0)
        equipBtn:setContentSize(btnSize)
        panel:setContentSize(self.forgeSize.width, self.forgeSize.height - btnSize.height)
    end

    self:updateLayout("ForgePanel")
end

function GameFunctionDlg:setEquipState(showEquip)
    local forgePanel = self:getControl("HideForgeButton")
    local isVisible = showEquip or forgePanel:isVisible()
    forgePanel:setVisible(not isVisible)
    local panel = self:getControl("BackImage", nil, forgePanel)
    if forgePanel:isVisible() then
        self:setCtrlVisible("ForgeButton", false)
        local equipBtn = self:getControl("EquipButton")
        local jewelryBtn = self:getControl("JewelryButton")
        local artifactBtn = self:getControl("ArtifactButton")
        local btnSize = jewelryBtn:getContentSize()
        if Me:getLevel() >= Const.SHOW_ARTIFACT_ICON_MIN_LEVEL then
            -- 装备 + 首饰 + 法宝
            artifactBtn:setContentSize(btnSize)
            equipBtn:setContentSize(btnSize)
            panel:setContentSize(self.forgeSize)
        elseif Me:getLevel() >= Const.SHOW_EQUIP_ICON_MIN_LEVEL then
            -- 装备 + 首饰
            artifactBtn:setContentSize(0, 0)
            equipBtn:setContentSize(btnSize)
            panel:setContentSize(self.forgeSize.width, self.forgeSize.height - btnSize.height)
        else
            -- 首饰
            artifactBtn:setContentSize(0, 0)
            equipBtn:setContentSize(0, 0)
            panel:setContentSize(self.forgeSize.width, self.forgeSize.height - btnSize.height * 2)
        end
    else
        if GuideMgr:isIconExist(4) and self:btnIsInNowState(self.curState, "ForgeButton") then
            self:setCtrlVisible("ForgeButton", true)
        end
    end

    self:updateLayout("ForgePanel")
    self.equipIsShow = forgePanel:isVisible()
end

function GameFunctionDlg:setSocialState(showSocail)
    local socialPanel = self:getControl("HideSocialButton")
    local isVisible = showSocail or socialPanel:isVisible()
    socialPanel:setVisible(not isVisible)
    local showPanel = self:getControl("SocialPanel", nil, socialPanel)
    local panel = self:getControl("BackImage", nil, socialPanel)
    if socialPanel:isVisible() then
        local findLoveBtn = self:getControl("FindLoveButton")
        local marryBookBtn = self:getControl("MarryBookButton")
        local communtiyBtn = self:getControl("CommunityButton")
        local teacherBtn = self:getControl("TeachButton")
        local height = showPanel:getContentSize().height
        local bthHeight = 78

        if not GuideMgr:isIconExist(30) then
            communtiyBtn:setContentSize(communtiyBtn:getContentSize().width, 0)
            local layoutP = communtiyBtn:getLayoutParameter()
            local margin = layoutP:getMargin()
            margin.bottom = 0
            layoutP:setMargin(margin)
            height = height - bthHeight - 15
        else
            communtiyBtn:setContentSize(communtiyBtn:getContentSize().width, bthHeight)
            local layoutP = communtiyBtn:getLayoutParameter()
            local margin = layoutP:getMargin()
            margin.bottom = 15
            layoutP:setMargin(margin)

            -- 如果社区有引导光效，需要先移除，延迟一帧添加，因为按钮位置会在updateLayout中更新，导致光效从旧位置闪过来，表现不好
            local guideMagic = communtiyBtn:getChildByTag(Const.ARMATURE_MAGIC_TAG)
            if guideMagic then
                guideMagic:removeFromParent()
                guideMagic = nil
                performWithDelay(self.root, function()
                    gf:createArmatureMagic(ResMgr.ArmatureMagic.main_ui_btn, self:getControl("CommunityButton"), Const.ARMATURE_MAGIC_TAG, 2, 0)
                end, 0)
            end
        end

        if not GuideMgr:isIconExist(31) then
            findLoveBtn:setContentSize(findLoveBtn:getContentSize().width, 0)
            local layoutP = findLoveBtn:getLayoutParameter()
            local margin = layoutP:getMargin()
            margin.bottom = 0
            layoutP:setMargin(margin)
            height = height - bthHeight - 15
        else
            findLoveBtn:setContentSize(findLoveBtn:getContentSize().width, bthHeight)
            local layoutP = findLoveBtn:getLayoutParameter()
            local margin = layoutP:getMargin()
            margin.bottom = 15
            layoutP:setMargin(margin)
        end

        if not GuideMgr:isIconExist(32) then
            marryBookBtn:setContentSize(marryBookBtn:getContentSize().width, 0)
            local layoutP = marryBookBtn:getLayoutParameter()
            local margin = layoutP:getMargin()
            margin.bottom = 0
            layoutP:setMargin(margin)
            height = height - bthHeight - 10
        else
            marryBookBtn:setContentSize(marryBookBtn:getContentSize().width, bthHeight)
            local layoutP = marryBookBtn:getLayoutParameter()
            local margin = layoutP:getMargin()
            margin.bottom = 10
            layoutP:setMargin(margin)
        end

        if not GuideMgr:isIconExist(33) then
            teacherBtn:setContentSize(teacherBtn:getContentSize().width, 0)
            local layoutP = teacherBtn:getLayoutParameter()
            local margin = layoutP:getMargin()
            margin.bottom = 0
            layoutP:setMargin(margin)
            height = height - bthHeight - 10
        else
            teacherBtn:setContentSize(teacherBtn:getContentSize().width, bthHeight)
            local layoutP = teacherBtn:getLayoutParameter()
            local margin = layoutP:getMargin()
            margin.bottom = 10
            layoutP:setMargin(margin)
        end

        panel:setContentSize(panel:getContentSize().width, height)

        self:setCtrlVisible("SocialButton", false)
    else
        if GuideMgr:isIconExist(29) and self:btnIsInNowState(self.curState, "SocialButton") then
            self:setCtrlVisible("SocialButton", true)
        end
    end

    local x, y = self:getControl("SocialButton"):getPosition()
    socialPanel:setPosition(cc.p(x, y))
    self:updateLayout("SocialPanel")
    self.socialIsShow = socialPanel:isVisible()
end

function GameFunctionDlg:onForgeButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end
    if not sender:isVisible() or self.isMoveToHide then
        return
    end

    self:setEquipState()
    self:setSocialState(true)
    self:tryToAutoHide()
end

function GameFunctionDlg:onSocialButton(sender)
    if not sender:isVisible() or self.isMoveToHide then
        return
    end

    self:setSocialState()
    self:setEquipState(true)
    self:tryToAutoHide()
end

function GameFunctionDlg:onEquipButton()
    if not DistMgr:checkCrossDist() then return end

    DlgMgr:openTabDlg("EquipmentTabDlg")
    self:setEquipState(true)
    self:tryToAutoHide()
end

function GameFunctionDlg:onGuardButton()
    if not DistMgr:checkCrossDist() then return end

    if Me:isInCombat() then
        return
    end

    local last = DlgMgr:getLastDlgByTabDlg('GuardTabDlg') or 'GuardAttribDlg'
    DlgMgr:openDlg(last)
    self:tryToAutoHide()
end

function GameFunctionDlg:onJewelryButton()
    if not DistMgr:checkCrossDist() then return end

    local last = DlgMgr:getLastDlgByTabDlg('JewelryTabDlg') or 'JewelryUpgradeDlg'
    DlgMgr:openDlg(last)
    self:setEquipState(true)
    self:tryToAutoHide()
end


function GameFunctionDlg:onArtifactButton()
    if not DistMgr:checkCrossDist() then return end

    local last = DlgMgr:getLastDlgByTabDlg('ArtifactTabDlg') or 'ArtifactRefineDlg'
    DlgMgr:openDlg(last)
    self:setEquipState(true)
    self:tryToAutoHide()
end

function GameFunctionDlg:onSystemButton()
    --DlgMgr:openDlg('DebugDlg')
    local last = DlgMgr:getLastDlgByTabDlg('SystemConfigTabDlg') or 'SystemConfigDlg'
    DlgMgr:openDlg(last)
    --gf:ShowSmallTips(CHS[2000003])
    self:tryToAutoHide()
end

function GameFunctionDlg:onWatchCenterButton()
    if not DistMgr:checkCrossDist() then return end

    if not GMMgr:isGM() and Me:queryInt("level") < 50 then
        gf:ShowSmallTips(CHS[4100444])
        return
    end

    WatchCenterMgr:queryWatchCombats(CHS[4100445])
end

function GameFunctionDlg:onPuttintButton(sender)
    local effect = sender:getChildByTag(ResMgr.magic.main_fish)
    if effect then
        effect:removeFromParent()
    end

    if HomeMgr:getHouseId() ~= Me:queryBasic("house/id") then
        gf:ShowSmallTips(CHS[2000342])
        return
    end

    if TeamMgr:inTeam(Me:getId()) and TeamMgr:getLeaderId() ~= Me:getId() then
        gf:ShowSmallTips(CHS[3002659])
        return
    end

    gf:CmdToServer('CMD_HOUSE_TRY_MANAGE', {})
end

function GameFunctionDlg:onTakeButton()
    if HomeMgr:getHouseId() ~= Me:queryBasic("house/id") then
        gf:ShowSmallTips(CHS[7003103])
        return
    end

    if TeamMgr:inTeam(Me:getId()) and TeamMgr:getLeaderId() ~= Me:getId() then
        gf:ShowSmallTips(CHS[3002659])
        return
    end
    DlgMgr:openDlg("HomeTakeCareDlg")
end

function GameFunctionDlg:onPlantButton(sender)
    local effect = sender:getChildByTag(ResMgr.magic.main_fish)
    if effect then
        effect:removeFromParent()
    end

    if HomeMgr:getHouseId() ~= Me:queryBasic("house/id") then
        gf:ShowSmallTips(CHS[7003103])
        return
    end

    if TeamMgr:inTeam(Me:getId()) and TeamMgr:getLeaderId() ~= Me:getId() then
        gf:ShowSmallTips(CHS[3002659])
        return
    end

    DlgMgr:openDlg("HomePlantDlg")
end

function GameFunctionDlg:onFishButton(sender)
    local effect = sender:getChildByTag(ResMgr.magic.main_fish)
    if effect then
        effect:removeFromParent()
    end

    if HomeMgr:getHouseId() ~= Me:queryBasic("house/id") then
        gf:ShowSmallTips(CHS[7003103])
        return
    end

    if TeamMgr:inTeam(Me:getId()) and TeamMgr:getLeaderId() ~= Me:getId() then
        gf:ShowSmallTips(CHS[3002659])
        return
    end

    local destStr = "#Z" .. CHS[7002319] .. "-" .. CHS[7002330] .. "|H=me|Dlg=HomeFishingDlg#Z"
    AutoWalkMgr:beginAutoWalk(gf:findDest(destStr))
    -- DlgMgr:openDlg("HomePlantDlg")
end

function GameFunctionDlg:onHomeManageButton()
    self:onStatusButton3()
    self:setCtrlVisible("HomePanel", true)
    self:setCtrlVisible("HomeManageButton", false)
    self:setBackYardButtonVisible()
end

function GameFunctionDlg:onCloseHomePanelButton()
    self:setCtrlVisible("HomePanel", false)
    self:setCtrlVisible("HomeManageButton", HomeMgr:getHouseId() == Me:queryBasic("house/id") and MapMgr:isInHouse(MapMgr:getCurrentMapName()) and not self:getCtrlVisible("HomePanel"))
    self:setBackYardButtonVisible()
end

function GameFunctionDlg:onHideAllUI()
    self:onCloseHomePanelButton()
end

-- 回到居所
function GameFunctionDlg:onHomeButton()
    if not DistMgr:checkCrossDist() then return end

    if Me:isInPrison() then
        gf:ShowSmallTips(CHS[7000072])
        return
    end

    if string.isNilOrEmpty(Me:queryBasic("house/id")) and Me:isInCombat() then
        gf:ShowSmallTips(CHS[4300268])
        return
    end

    if string.isNilOrEmpty(Me:queryBasic("house/id")) then
        -- 没有居所
        gf:confirm(CHS[2000272], function()
            if Me:isInJail() then
                gf:ShowSmallTips(CHS[2000273])
                return
            end

            if Me:isInCombat() then
                gf:ShowSmallTips(CHS[2000274])
                return
            end

            gf:doActionByColorText(CHS[2000275])
        end)
    else
        -- 请求居所信息
        HomeMgr:requestData("HomeInDlg")
    end
end

function GameFunctionDlg:onGMButton()
    local dlg = DlgMgr:getDlgByName("GMManageDlg")
    if dlg then
        dlg:onCloseButton()
    else
        DlgMgr:openDlg("GMManageDlg")
    end
end

function GameFunctionDlg:onAchievementButton()
    if not DistMgr:checkCrossDist() then return end

    AchievementMgr:queryFirstSkill()
    AchievementMgr:queryAchieveCfg()
    AchievementMgr:queryAchieveOverView()
end

function GameFunctionDlg:onCommunityButton(sender, eventType, data, isRedDotRemoved)
    CommunityMgr:onCommunityButton(sender, eventType, data, isRedDotRemoved)
    self:setSocialState(true)
    self:tryToAutoHide()

    local notFirstLoginInZNQ = cc.UserDefault:getInstance():getIntegerForKey("LogClientActionForSheJiao" .. gf:getShowId(Me:queryBasic("gid"))) or 0
    if not gf:isSameDay5(notFirstLoginInZNQ, gf:getServerTime()) then
        gf:CmdToServer("CMD_LOG_CLIENT_ACTION", {[1] = {action = "clickbutton", para1 = "sheq", para2 = "", para3 = "", memo = ""}, count = 1})
        cc.UserDefault:getInstance():setIntegerForKey("LogClientActionForSheJiao" .. gf:getShowId(Me:queryBasic("gid")), gf:getServerTime())
    end
end


function GameFunctionDlg:onTeachButton(sender)
    if MasterMgr:isHasMasterRelation() then
        DlgMgr:openDlg("MasterRelationDlg")
    else
        DlgMgr:openDlg("MasterDlg")
    end


    self:setSocialState(true)
    self:tryToAutoHide()
end

function GameFunctionDlg:onFindLoveButton(sender)
    gf:CmdToServer("CMD_MATCH_MAKING_REQ_LIST", { type = 1, source = 0})

    self:setSocialState(true)
    self:tryToAutoHide()
end

function GameFunctionDlg:onMarryBookButton(sender)
    gf:CmdToServer("CMD_OPEN_WEDDING_BOOK")

    self:setSocialState(true)
    self:tryToAutoHide()
end


function GameFunctionDlg:onBagButton()



            local last = DlgMgr:getLastDlgByTabDlg('BagDlg') or 'BagDlg'
    DlgMgr:openDlg(last)

    local bagBtn = self:getControl("BagButton")
    self:setCtrlVisible("MarryBookTipsPanel", false)
    local ctrl = bagBtn:getChildByTag(Const.ARMATURE_MAGIC_TAG)
    if ctrl then
        if ctrl.guidePos then
            DlgMgr:sendMsg("BagDlg", "setItemAround", ctrl.guidePos, true)
        end
        ctrl:removeFromParent()
    end
end

function GameFunctionDlg:isContainIcon(ctrlName)
    for i = 1, #BtnList do
        if BtnList[i] == ctrlName then
            return true
        end
    end

    return false
end

function GameFunctionDlg:addListIcon(ctrlName)
    if not GameMgr:IsCrossDist() or not NEED_HIDE_IN_SERVER[ctrlName] then
        if nil ~= self:getControl(ctrlName) and nil ~= btnPosMap[ctrlName] and not self:isContainIcon(ctrlName) then
            table.insert(BtnList, ctrlName)
        end
    end
end


function GameFunctionDlg:removeListIcon(ctrlName)
    local count = 0
    for i = #BtnList, 1, -1 do
        if BtnList[i] == ctrlName then
            table.remove(BtnList, i)
            count = count + 1
        end
    end
    return count
end

function GameFunctionDlg:unVisibleAllCtrl()
    self:setEquipState(true)
    self:setSocialState(true)

    -- 重置按钮位置
    local basicBtn = self:getControl("StatusButton1", Const.UIButton)
    for k, v in pairs(btnPosMap) do
        local ctrl = self:getControl(k)
        if k ~= "BagButton" then
            ctrl:setPosition(basicBtn:getPosition())
            ctrl:setVisible(false)
        end
    end

    -- 收起状态默认在状态3
    self.curState = ButtonState.State3
    self:doShowOrHideButton()
end

-- 将所有控件进行排序
function GameFunctionDlg:sortIcon(list)
    -- 获取所有的控件进行排序
    table.sort(list, function(l, r)
        if btnPosMap[l] > btnPosMap[r] then
            return false
        end

        return true
    end)
end

function GameFunctionDlg:refreshIcon(isGuide, ctrlName)
    if isGuide then
        if ctrlName then
            -- 参数带有ctrlName，表示指定状态
            local state = self:getStateByBtnName(ctrlName)
            if state and state ~= self.curState then
                self.curState = state
            end
        end
    else
        self:unVisibleAllCtrl()
    end

    self:clearAllAction(true)

    self:sortIcon(BtnList)

    -- 首先排列横排
    local dlgContentSize = self.root:getContentSize()
    local topX = dlgContentSize.width
    local topY = 0
    local leftTop = nil
    for i = 1, #BtnList do
        if btnPosMap[BtnList[i]] < 100 then
            local ctrl = self:getControl(BtnList[i])
            local contentSize = ctrl:getContentSize()
            if self:btnIsInNowState(self.curState, BtnList[i]) then
                topX = topX - contentSize.width - BUTTON_MARGIN
                ctrl:setPosition(topX - contentSize.width / 2, topY / Const.UI_SCALE + contentSize.height / 2)
                --ctrl:setAnchorPoint(1, 0)
                if ctrl:getName() ~= "GMButton" then
                    ctrl:setVisible(true)
                else
                    if GMMgr:isGM() then ctrl:setVisible(true) end
                end
            end

            if nil == leftTop then
                leftTop = contentSize
            end
        end
    end

    if nil == leftTop then
        leftTop = {width = 0, height = 0}
    end


    -- 在排列竖排
    local y = (topY + leftTop.height) / Const.UI_SCALE
    local x = dlgContentSize.width
    for i = 1, #BtnList do
        if btnPosMap[BtnList[i]] >= 100 then
            local ctrl = self:getControl(BtnList[i])
            local contentSize = ctrl:getContentSize()
            --ctrl:setAnchorPoint(1, 0)
            ctrl:setPosition(x - contentSize.width / 2, y + BUTTON_MARGIN + contentSize.height / 2)
            y = y + contentSize.height
            ctrl:setVisible(true)

            if BtnList[i] == "BagButton" then
                -- 重置管理按钮的位置，WDSY-27514 修改
                local homeManageButton = self:getControl("HomeManageButton")
                local bx, by = ctrl:getPosition()
                homeManageButton:setPosition(bx - contentSize.width - BUTTON_MARGIN, by)
            end
        end
    end

    self.root:requestDoLayout()
    self:tryToAutoHide()
    self:doStateChangeButton(self.curState)
    self:doShowOrHideButton()

    -- 如果非引导通知，则应该关闭图标
    if not isGuide then
        if Me:queryInt("level") >= 50 then
            self:unVisibleAllCtrl()

            self:tryToAutoHide(true)

            -- 更新下小红点
            RedDotMgr:updateGFDShowBtnRedDot()
        else
            -- 小于50级的玩家默认显示状态1
            self:onStatusButton1()
        end
    end

    self.root:requestDoLayout()
end

function GameFunctionDlg:getIconCtrl(iconName)
    return self:getControl(iconName)
end

function GameFunctionDlg:getStateByBtnName(btnName)
    -- 通过按钮名获取“此按钮是哪一状态下的按钮”
    local key = btnName
    if SECOND_ICON_LIST[btnName] and SECOND_ICON_LIST[btnName]["parent"] then
        key = SECOND_ICON_LIST[btnName]["parent"]
    end

    for i = 1, #STATUS1_BTN do
        if key == STATUS1_BTN[i] then
            return ButtonState.State1
        end
    end

    for i = 1, #STATUS2_BTN do
        if key == STATUS2_BTN[i] then
            return ButtonState.State2
        end
    end
end

function GameFunctionDlg:btnIsInNowState(state, btnName)
    -- 判断当前按钮是否是对应状态下的按钮
    local btnState = self:getStateByBtnName(btnName)
    return btnState == state
end

-- 通知Dlg要添加一个icon了
function GameFunctionDlg:preAddIcon(iconName)
    local iconCtrl = self:getControl(iconName)

    if nil == iconCtrl then
        return
    end

    if not btnPosMap[iconName] and SECOND_ICON_LIST[iconName] then
        -- 二级图标，获取此图标应该放置的位置
        local pos
        local parentCtrl = self:getControl(SECOND_ICON_LIST[iconName].parent)
        local iconContentSize = parentCtrl:getContentSize()
        local anchorPoint = parentCtrl:getAnchorPoint()
        pos = parentCtrl:convertToWorldSpace(cc.p(
            iconContentSize.width * (1 - anchorPoint.x),
            iconContentSize.height * (1 - anchorPoint.y + SECOND_ICON_LIST[iconName].order)))
        return pos
    end

    -- 获取外侧Icon
    -- 判断是横排Icon还是竖排Icon
    local icons = {}
    local type = 0
    if btnPosMap[iconName] > 100 then
        -- 竖排Icon
        -- 获取大于它的Icon
        for k, v in pairs(btnPosMap) do
            if v > 100 and v > btnPosMap[iconName]
                  and self:isContainIcon(k)
                  and self:btnIsInNowState(self.curState, iconName)then
                table.insert(icons, k)
            end
        end

        type = TYPE_VERTICAL
    else
        -- 横排Icon
        -- 获取大于它的Icon
        for k, v in pairs(btnPosMap) do
            if v < 100 and v > btnPosMap[iconName]
                  and self:isContainIcon(k)
                  and self:btnIsInNowState(self.curState, k)then
                table.insert(icons, k)
            end
        end

        type = TYPE_HORIZONTAL
    end

    -- 获取控件的contentSize
    local iconContentSize = iconCtrl:getContentSize()

    -- 获取第一个icon的原始位置，即为当前需要移动的位置
    local pos = {}
    local anchorPoint = {}
    if 0 ~= #icons then
        self:sortIcon(icons)
        local ctrl = self:getControl(icons[1])
        pos.x, pos.y = ctrl:getPosition()
        anchorPoint = ctrl:getAnchorPoint()
    else
        -- 为最后一个位置
        -- 获取前一个已存在Icon的位置
        self:sortIcon(BtnList)
        local lastIcon = 0
        local lastIconCtrl = nil
        for i = 1, #BtnList do
            if btnPosMap[BtnList[i]] < btnPosMap[iconName]
                  and lastIcon < btnPosMap[BtnList[i]]
                  and math.floor(btnPosMap[iconName] / 100) == math.floor(btnPosMap[BtnList[i]] / 100)
                  and self:btnIsInNowState(self.curState, BtnList[i]) then
                lastIconCtrl = self:getControl(BtnList[i])
                lastIcon = btnPosMap[BtnList[i]]
            end
        end

        if nil ~= lastIconCtrl then
            anchorPoint = lastIconCtrl:getAnchorPoint()
            pos.x, pos.y = lastIconCtrl:getPosition()
            local contentSize = lastIconCtrl:getContentSize()
            if TYPE_HORIZONTAL == type then
                pos.x = pos.x - contentSize.width - BUTTON_MARGIN
            elseif TYPE_VERTICAL == type then
                pos.y = pos.y + contentSize.height
            end
        else
            -- 是第一个图标
            if TYPE_HORIZONTAL == type then
                local dlgContentSize = self.root:getContentSize()
                pos.x = dlgContentSize.width - iconContentSize.width - BUTTON_MARGIN
                pos.y = 0
                anchorPoint = {x = 1, y = 0}
            elseif TYPE_VERTICAL == type then
                local dlgContentSize = self.root:getContentSize()
                pos.y = (0 + 78) / Const.UI_SCALE
                pos.x = dlgContentSize.width
                anchorPoint = {x = 1, y = -0.5}
            end
        end
    end

    -- 集体向外移
    for i = 1, #icons do
        local ctrl = self:getControl(icons[i])
        local x, y = ctrl:getPosition()

        local action = nil
        if btnPosMap[icons[i]] > 100 then
            action = cc.MoveTo:create(0.2, cc.p(x, y + iconContentSize.height))
        else
            action = cc.MoveTo:create(0.2, cc.p(x - iconContentSize.width - BUTTON_MARGIN, y))
        end

        local seq = cc.Sequence:create(cc.DelayTime:create(2.6), action)
        ctrl:runAction(seq)
    end

    iconCtrl:setPosition(pos.x, pos.y)
    pos = iconCtrl:convertToWorldSpace(cc.p(iconContentSize.width * (1 - anchorPoint.x), iconContentSize.height * (1 - anchorPoint.y)))
    pos.x = pos.x / Const.UI_SCALE

    return pos
end

function GameFunctionDlg:tryToAutoHide(stopOnly)
    if self.autoHideSeq then
        self.root:stopAction(self.autoHideSeq)
    end

    if not stopOnly then
        self.autoHideSeq = performWithDelay(self.root, function()
            if not GuideMgr:isRunning() then
                -- 唯一的收起状态，状态3
                self:onStatusButton3()
            end
            self.autoHideSeq = nil
        end, LIMIT_SECONDS)
    else
        self.autoHideSeq = nil
    end

    self:onCloseHomePanelButton()
end

function GameFunctionDlg:onShowButton()
    self:onStatusButton1()
end

function GameFunctionDlg:onHideButton()
    self:onStatusButton3()
end

function GameFunctionDlg:openFastUseDlg(isRightNow)
    if self.fastUseItemName == "" then return end
    -- 强制立即使用（无物品限制）
    if isRightNow == 1 then
        local dlg = DlgMgr:getDlgByName("FastUseItemDlg")
        if dlg then
            dlg:forceUseItem()
        else
            dlg = DlgMgr:openDlg("FastUseItemDlg")
        end

        dlg:setInfo(self.fastUseItemName, self.fastUseItemParam)
        self.fastUseItemName = ""
        return
    end

    if Me:isInCombat() then return end
    local itemName = self.fastUseItemName
    local dlg

    if InventoryMgr:isCanFastUseByItemName(itemName) then
                dlg = DlgMgr:openDlg("FastUseItemDlg")
                dlg:setInfo(itemName, self.fastUseItemParam)
                self.fastUseItemName = ""
            end


    if DlgMgr.dlgs["DramaDlg"] and DlgMgr:sendMsg("DramaDlg", "getDramaState") == false then
        if nil ~= dlg then
            dlg:setVisible(false)
        end
    end

end

-- 是否添加小红点
function GameFunctionDlg:onCheckAddRedDot(ctlName)
    if "PartyButton" == ctlName then
        return not DlgMgr:isDlgOpened("PartyInfoTabDlg")
    else
        return true
    end
end

function GameFunctionDlg:MSG_PLAY_INSTRUCTION(data)
    self:setEquipState(true)
    self:setSocialState(true)
end

function GameFunctionDlg:MSG_RESET_FAST_USE_ITEM(data)
    DlgMgr:closeDlg("FastUseItemDlg")
    InventoryMgr:initFastUseItemFlag()
end

-- 获得物品动画
function GameFunctionDlg:MSG_ICON_CARTOON(data)
    -- 1为物品  3为金钱
    if data.type ~= 1 and data.type ~= 3 and data.type ~= 4 and data.type ~= 5 and data.type ~= 6 and data.type ~= 7 then return end

    if data.type == 6 then --存钱
        SoundMgr:playEffect("money")

        -- 存钱无需“金钱进入背包动画”，所以直接返回
        return
    end

    if data.type == 7 then -- 取钱
        SoundMgr:playEffect("money")
    end


    if data.type == 3 and tonumber(data.param) and tonumber(data.param) >= 1000000 then
        SoundMgr:playEffect("money")       -- 金钱的声音
    end

    self.fastUseItemName = data.name
    self.fastUseItemParam = data.param

    -- 快捷使用
    -- 动作效果
    if not Me:isInCombat() then
        self:openFastUseDlg(data.rightNow)
    else
        -- 将可便捷使用的道具加入便捷使用道具的列表中
        if InventoryMgr:isCanFastUseByItemName(self.fastUseItemName) then
                    local dlg = DlgMgr:openDlg("FastUseItemDlg")
                    dlg:setVisible(false)
                    dlg:setInfo(self.fastUseItemName, self.fastUseItemParam)
                    self.fastUseItemName = ""
                end
            end

    local image = cc.Sprite:create(ResMgr:getItemIconPath(InventoryMgr:getIconByName(data.name)))
    if InventoryMgr:getIsGuard(data.name) then
        -- 如果是获得守护的道具
        image = cc.Sprite:create(ResMgr:getSmallPortrait(InventoryMgr:getIconByName(data.name)))
    end

    if data.type == 3 then
        if data.name == CHS[3002646] then
            image = ccui.ImageView:create(ResMgr.ui.voucher, ccui.TextureResType.plistType)
        else
            image = ccui.ImageView:create(ResMgr.ui.big_cash, ccui.TextureResType.plistType)
        end
    elseif data.type == 4 then
        image = ccui.ImageView:create(ResMgr.ui.big_silver, ccui.TextureResType.plistType)
    elseif data.type == 5 then
        image = ccui.ImageView:create(ResMgr.ui.big_gold, ccui.TextureResType.plistType)
    end

    -- 无图片资源
    if not image then return end
    image.name = data.name

    -- 如果队列中已经有相同的物品，则直接返回
    if cartoonList[data.name] ~= nil and gf:getServerTime() - cartoonList[data.name] < 0.6 then
        return
    end
    cartoonList[data.name] = gf:getServerTime()

    local size = self:getControl("BagButton"):getContentSize()
    local pos = self:getBoundingBoxInWorldSpace(self:getControl("BagButton"))
    pos.x = pos.x + size.width * 0.5
    pos.y = pos.y + size.height * 0.5

    image:setAnchorPoint(0.5,0.5)
    image:setPosition((Const.WINSIZE.width * 0.5) / Const.UI_SCALE, (pos.y + image:getContentSize().height) / Const.UI_SCALE)
    gf:setItemImageSize(image, true)

    gf:getUILayer():addChild(image)
    image:setLocalZOrder(Const.ZORDER_SMALLTIP)
    self.actNum = self.actNum + 1

    -- 动作效果
    local disAct = cc.CallFunc:create(function()
        self.actNum = self.actNum - 1
        gf:getUILayer():removeChild(image)
        cartoonList[image.name] = nil
    end)

    local moveRight = cc.EaseSineIn:create(cc.MoveTo:create(1, cc.p(pos.x, pos.y)))
    local scale = cc.Spawn:create(cc.FadeOut:create(2.5), cc.ScaleTo:create(1, 0.7))
    local itemAct = cc.Spawn:create(moveRight,scale)

    image:runAction(cc.Sequence:create(cc.DelayTime:create(self.actNum * 0.4), cc.DelayTime:create(0.2),itemAct, disAct))
end

-- 如果需要使用指引通知类型，需要重载这个函数
function GameFunctionDlg:youMustGiveMeOneNotify(param, detail)
    if "isListShow" == param then
        self.param = param
        if detail and detail.oper and detail.oper.clickBtn then
            local state = self:getStateByBtnName(detail.oper.clickBtn)
            if state == ButtonState.State1 then
                self:onStatusButton1()
            elseif state == ButtonState.State2 then
                self:onStatusButton2()
            end
        end
    end
end

function GameFunctionDlg:setBackYardButtonVisible()
    local fishPosX = self:getControl("FishButton", nil, "HomePanel"):getPositionX()
    local takeButtonPosX = self:getControl("TakeButton", nil, "HomePanel"):getPositionX()
    local kidButton = self:getControl("KidButton", nil, "HomePanel")
    local childTipsPanel = self:getControl("ChildTipsPanel")
    if MapMgr:isInHouseBackYard(MapMgr:getCurrentMapName()) then
        -- 后院显示种植按钮
        self:setCtrlVisible("PlantButton", true, "HomePanel")
        self:setCtrlVisible("FishButton", true, "HomePanel")
        self:setCtrlVisible("KidButton", true, "HomePanel")

        kidButton:setPositionX(takeButtonPosX)
        self:setCtrlVisible("TakeButton", false, "HomePanel")
        childTipsPanel:setPositionX(takeButtonPosX - childTipsPanel:getContentSize().width / 2)

        self:setCtrlVisible("BKImage_1", true, "HomePanel")
        self:setCtrlVisible("BKImage", false, "HomePanel")
        self:setCtrlVisible("BKImage_2", false, "HomePanel")
    else
        self:setCtrlVisible("PlantButton", false, "HomePanel")
        self:setCtrlVisible("FishButton", false, "HomePanel")
        self:setCtrlVisible("KidButton", true, "HomePanel")

        kidButton:setPositionX(fishPosX)
        self:setCtrlVisible("TakeButton", true, "HomePanel")
        childTipsPanel:setPositionX(fishPosX - childTipsPanel:getContentSize().width / 2)

        self:setCtrlVisible("BKImage_1", false, "HomePanel")
        self:setCtrlVisible("BKImage", false, "HomePanel")
        self:setCtrlVisible("BKImage_2", true, "HomePanel")
    end
end

function GameFunctionDlg:showHouseButton()
    if HomeMgr:getHouseId() == Me:queryBasic("house/id") and MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
        local homePanel = self:getControl("HomePanel")
        local homeManageButton = self:getControl("HomeManageButton")
        if not homePanel:isVisible() and not homeManageButton:isVisible() then
            self:onStatusButton3()
            homePanel:setVisible(not GameMgr:isHideAllUI())
            homeManageButton:setVisible(GameMgr:isHideAllUI())
        end

        self:setBackYardButtonVisible()
        else
            self:setCtrlVisible("HomePanel", false)
            self:setCtrlVisible("HomeManageButton", false)
        end
end

function GameFunctionDlg:addEffectByButtonName(btnName)
    if MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
    self:onHomeManageButton()
    end

    local btn = self:getControl(btnName)
    local effect = btn:getChildByTag(ResMgr.magic.main_fish)
    if effect then
        return
    end

    effect =  gf:createLoopMagic(ResMgr.magic.main_fish, nil, {blendMode = "add"})

    btn:addChild(effect, 1, ResMgr.magic.main_fish)
end

function GameFunctionDlg:MSG_TASK_PROMPT(data)
    for k, task in ipairs(data) do
        if task.task_type == CHS[4200442]  then
            if tonumber(task.task_extra_para) and tonumber(task.task_extra_para) > 1 then
                local btn = self:getControl("FishButton")
                local effect = btn:getChildByTag(ResMgr.magic.main_fish)
                if effect then
                    effect:removeFromParent()
                end
            end

            if tonumber(task.task_extra_para) and tonumber(task.task_extra_para) > 3 then
                local btn = self:getControl("PlantButton")
                local effect = btn:getChildByTag(ResMgr.magic.main_fish)
                if effect then
                    effect:removeFromParent()
                end
            end

            if tonumber(task.task_extra_para) and tonumber(task.task_extra_para) > 7 then
                local btn = self:getControl("PuttingButton")
                local effect = btn:getChildByTag(ResMgr.magic.main_fish)
                if effect then
                    effect:removeFromParent()
                end
            end
        end
    end
end

function GameFunctionDlg:MSG_HOUSE_FURNITURE_DATA()
    self:MSG_HOUSE_DATA()
end

function GameFunctionDlg:MSG_HOUSE_DATA()
    self:showHouseButton()
end

-- GM按钮位置需要在居所外右移，居所内左移
function GameFunctionDlg:updateGMButtonPos()
    if GMMgr:isGM() then
        local gmButton = self:getControl("GMButton")
        if MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
            gmButton:setPosition(GM_BUTTON_POS[1])
        else
            gmButton:setPosition(GM_BUTTON_POS[2])
        end
    end
end

function GameFunctionDlg:MSG_ENTER_ROOM()
    self:updateGMButtonPos()
end


function GameFunctionDlg:MSG_MATCH_ADMIN_DATA(data)
    if not GameMgr:IsCrossDist() and data.count > 0 then
        self:setCtrlVisible("AdministratorsButton", true)
        return
    end

    if DistMgr:isInQMPKServer() and data.warData[CHS[4300464]] then
        self:setCtrlVisible("AdministratorsButton", true)
        return
    end

    if DistMgr:isInMRZBServer() and data.warData[CHS[4300465]] then
        self:setCtrlVisible("AdministratorsButton", true)
        return
    end

    self:setCtrlVisible("AdministratorsButton", false)
end

function GameFunctionDlg:onAdministratorsButton()
    DlgMgr:openDlg("AdministratorsDlg")
end

function GameFunctionDlg:removeMagicForKidButton()
    local btn = self:getControl("KidButton")
    local effect = btn and btn:getChildByTag(ResMgr.magic.main_fish)
    if effect then
        effect:removeFromParent()
    end

    self:setCtrlVisible("ChildTipsPanel", false)
end

function GameFunctionDlg:onKidButton(sender)

    local count = HomeChildMgr:getChildenCount()
    if not count then
        -- 数据没有收到，正常情况由于延迟，不给提示和反应
        return false
    elseif count <= 0 then
        gf:ShowSmallTips(CHS[4010394])  -- 你尚未拥有娃娃或天地灵石，可找#R风月谷#n的#Y送子娘娘#n了解如何获得娃娃。
        return false
    end

    local effect = sender and sender:getChildByTag(ResMgr.magic.main_fish)
    if effect then
        effect:removeFromParent()
        DlgMgr:openDlgEx("KidInfoDlg", {selectId = sender.id})
    else
        DlgMgr:openDlg("KidInfoDlg")
    end

    self:setCtrlVisible("ChildTipsPanel", false)
end


return GameFunctionDlg
