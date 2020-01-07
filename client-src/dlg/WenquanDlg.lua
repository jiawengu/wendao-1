-- WenquanDlg.lua
-- Created by huangzz Jan/21/2019
-- 玉露仙池-温泉主界面

local WenquanDlg = Singleton("WenquanDlg", Dialog)

local COLORS = {
    cc.c3b(0x4d, 0x59, 0xfe),
    cc.c3b(0x5f, 0xfd, 0xf6),
    cc.c3b(0x60, 0xff, 0x7a),
    cc.c3b(0xff, 0xe8, 0x66),
    cc.c3b(0xff, 0x56, 0x4a),
}

function WenquanDlg:init()
    self:setFullScreen()
    self:bindListener("InforButton", self.onInforButton)
    self:bindListener("ChuibeiButton", self.onChuibeiButton, nil, true)
    self:bindListener("DiufzButton", self.onDiufzButton)
    self:bindListener("RuleImage", self.onRuleImage)
    self:bindListener("ViewImage", self.onViewImage)
    self:bindListener("JianButton", self.onJianButton)
    self:bindListener("JiaButton", self.onJiaButton)
    self:bindListener("Panel11", self.onGoto)
    self:bindListener("InforPanel", self.onInforPanel)

    self:bindFloatPanelListener("InforPanel")

    self:setCtrlVisible("NoticePanel", false)

    DlgMgr:showDlg("SystemFunctionDlg", true)
    DlgMgr:showDlg("HeadDlg", true)
    DlgMgr:showDlg("ChatDlg", true)

    DlgMgr:showDlg("GameFunctionDlg", false)
    DlgMgr:showDlg("MissionDlg", false)

    local dlg = DlgMgr:openDlg("CombatViewDlg")
    DlgMgr:upDlg("CombatViewDlg", -40)
    -- self:hideAllDlgs({["LoadingDlg"] = 1, ["ChatDlg"] = 1, ["SystemFunctionDlg"] = 1, ["HeadDlg"] = 1, ["CombatViewDlg"] = 1})

    self:setCtrlVisible("TipsPanel", false)

    self.hasClickDiufzButton = InventoryMgr:getLimitItemFlag(self.name, 0)
    self.lastTalkTime = 0;

    local tempPanel = self:getControl("TemperaturePanel")
    local x, y = tempPanel:getPosition()
    tempPanel:setPositionX(math.max(x, self.root:getContentSize().width / 2 - tempPanel:getContentSize().width / 2))

    WenQuanMgr:setCanThrowSoap(false)

    self:createFZArmature()
    self:createBarArmature()

    local cbBtn = self:getControl("ChuibeiButton")
    local  function touch(touch, event)
        local rect = self:getBoundingBoxInWorldSpace(cbBtn)
        local toPos = touch:getLocation()

        if not cc.rectContainsPoint(rect, toPos) then
            WenQuanMgr:setSelectChar()
            return false
        end
    end

    gf:bindTouchListener(self:getControl("TouchPanel"), touch, nil, true)

    self:hookMsg("MSG_GENERAL_NOTIFY")
end

function WenquanDlg:playUseYLJHAction(name)
    local panel = self:getControl("NoticePanel")
    local textPanel = self:getControl("Panel", nil, panel)
    self:setLabelText("Label_2", name, textPanel)
    local childs = textPanel:getChildren()
    local totalWidth = 0
    for _, v in pairs(childs) do
        local size = v:getContentSize()
        totalWidth = totalWidth + size.width
    end

    textPanel:setContentSize(totalWidth, textPanel:getContentSize().height)
    self:setCtrlVisible("NoticePanel", true)
    panel:requestDoLayout()
    panel:setOpacity(0)
    panel:stopAllActions()
    local action = cc.Sequence:create(
        cc.FadeIn:create(0.5),
        cc.DelayTime:create(6),
        cc.FadeOut:create(0.5),
        cc.CallFunc:create(function()
            self:setCtrlVisible("NoticePanel", false)
        end)
    )

    panel:runAction(action)
end

function WenquanDlg:setData(data)
    DlgMgr:showDlg("SystemFunctionDlg", true)
    DlgMgr:showDlg("HeadDlg", true)
    DlgMgr:showDlg("ChatDlg", true)

    DlgMgr:showDlg("GameFunctionDlg", false)
    DlgMgr:showDlg("MissionDlg", false)

    self.data = data

    self:setProgressBar(data.water_temp)

    self:setRuleData(data)

    if self.schduleId then return end

    self.schduleId = self:startSchedule(function()
        local lastTime = self.data.end_time - gf:getServerTime()
        if lastTime < 0 then
            self:stopSchedule(self.schduleId)
            self.schduleId = nil
            return
        end

        local m = math.floor(lastTime / 60)
        local s = lastTime % 60
        self:setLabelText("TimeLabel_2", string.format(CHS[5450469], m, s))

        if self.lastTalkTime % 30 == 0 then
            local char = CharMgr:getCharByName(CHS[5410332])
            if char then
                char:setChat({msg = CHS[5410331], show_time = 3})
            end
        end

        self.lastTalkTime = self.lastTalkTime + 1
    end, 1)
end

function WenquanDlg:setProgressBar(temp)
    -- 温度百分比
    local bar = self:getControl("ProgressBar")
    local percent = math.min(temp / 70 * 100, 100)
    if temp < 30 then
        self:playBarMagic("Bottom02")
        self.barMagic:setVisible(true)
    elseif temp <= 50 then
        self.barMagic:setVisible(false)
    else
        self:playBarMagic("Bottom01")
        self.barMagic:setVisible(true)
    end

    local index = math.max(math.min(5, math.ceil(percent / 20)), 1)
    local backColor = COLORS[index - 1]
    local frontColor = COLORS[index]
    local opacity = ((percent - 1) % 20 + 1) / 20
    if percent > 100 then opacity = 1 end
    if percent < 20 then opacity = 1 end
    if not backColor then backColor = cc.c3b(0xff, 0xff, 0xff) end
    local r = frontColor.r * opacity + backColor.r * (1 - opacity)
    local g = frontColor.g * opacity + backColor.g * (1 - opacity)
    local b = frontColor.b * opacity + backColor.b * (1 - opacity)

    bar:setColor(cc.c3b(r, g, b))

    bar:setPercent(percent)

    self:setLabelText("NumLabel", temp .. "/70", "TempPanel")
end

function WenquanDlg:playBarMagic(action)
    if self.lastAction == action then return end

    self.barMagic:getAnimation():play(action, -1, 1)
    self.lastAction = action
end

function WenquanDlg:setRuleData(data)
    self:setLabelText("Label3", data.guaji_reward_cou, "InforPanel")
    self:setLabelText("Label5", data.hudong_reward_cou, "InforPanel")
    self:setLabelText("Label7", data.beidong_reward_cou, "InforPanel")

    if data.water_temp < 30 then
        self:setLabelText("Label9", CHS[5450471], "InforPanel")
    elseif data.water_temp <= 50 then
        self:setLabelText("Label9", CHS[5450472], "InforPanel")
    else
        self:setLabelText("Label9", CHS[5450473], "InforPanel")
    end

    if data.player_name ~= "" then
        self:setColorText(string.format(CHS[5450475], data.player_name), "Panel11", "InforPanel", nil, nil , COLOR3.WHITE, 21)
    else
        self:setColorText(CHS[5450474], "Panel11", "InforPanel", nil, nil, COLOR3.WHITE, 21)
    end
end

-- 创建肥皂骨骼动画
function WenquanDlg:createFZArmature()
    local btn = self:getControl("DiufzButton")
    local panel = btn:getParent()
    local magic = ArmatureMgr:createArmature(ResMgr.ArmatureMagic.wenquan_soap_tip.name)
    magic:setAnchorPoint(btn:getAnchorPoint())
    magic:setPosition(btn:getPosition())
    magic:setVisible(false)
    panel:addChild(magic)

    magic:getAnimation():play("Top", -1, 1)

    self.fzMagic = magic
end

-- 创建进度条骨骼动画
function WenquanDlg:createBarArmature()
    local bar = self:getControl("ProgressBarBackImage")
    local magic = ArmatureMgr:createArmature(ResMgr.ArmatureMagic.wenquan_temp_tip.name)
    local size = bar:getContentSize()
    magic:setAnchorPoint(0.5, 0.5)
    magic:setPosition(size.width / 2, size.height / 2)
    magic:setVisible(false)
    bar:addChild(magic, 10, 10)

    -- magic:getAnimation():play("Top", -1, 1)

    self.barMagic = magic
end

-- 记录
function WenquanDlg:onInforButton(sender, eventType)
    DlgMgr:openDlg("WenquanRecordDlg")
end

-- 捶背
function WenquanDlg:onChuibeiButton(sender, eventType)
    if WenQuanMgr.isPlayAction then
        return
    end

    if eventType == ccui.TouchEventType.began then
        -- gf:ShowSmallTips(strUTF8)
    elseif eventType == ccui.TouchEventType.ended then
        WenQuanMgr:gotoPlayFlapBack()
    end
end

-- 丢肥皂
function WenquanDlg:onDiufzButton(sender, eventType)
    if WenQuanMgr.isPlayAction then
        return
    end

    local flag = not WenQuanMgr:isInThrowSoap()
    WenQuanMgr:setCanThrowSoap(flag)
    self.fzMagic:setVisible(flag)

    sender:setOpacity(flag and 0 or 255)

    if self.hasClickDiufzButton == 0 and flag then
        InventoryMgr:setLimitItemDlgs(self.name, 1)
        self.hasClickDiufzButton = 1
        self:setCtrlVisible("TipsPanel", true)
    end

    if not flag then
        self:setCtrlVisible("TipsPanel", false)
    end
end

-- 查看温泉规则
function WenquanDlg:onRuleImage(sender, eventType)
    DlgMgr:openDlg("WenquangzDlg")
end

-- 查看温泉信息
function WenquanDlg:onViewImage(sender, eventType)
    self:setCtrlVisible("InforPanel", true)
end

-- 降温
function WenquanDlg:onJianButton(sender, eventType)
    gf:CmdToServer("CMD_XCWQ_ADJUST_TEMPERATURE", {type = 0})
end

-- 加温
function WenquanDlg:onJiaButton(sender, eventType)
    gf:CmdToServer("CMD_XCWQ_ADJUST_TEMPERATURE", {type = 1})
end

function WenquanDlg:onGoto(sender, eventType)
    if self.data and self.data.player_gid and self.data.player_gid ~= "" then
        FriendMgr:requestCharMenuInfo(self.data.player_gid, {
            needCallWhenFail = true,
            gid = self.data.player_gid,
            requestDlg = self.name,
        })

        self.selectSender = sender
    else
        AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[5450477]))
    end
end

function WenquanDlg:onCharInfo(gid, isFail)
    if not self.selectSender then return end

    if isFail then
        gf:ShowSmallTips(CHS[6000139])
    else
        local dlg = DlgMgr:openDlg("CharMenuContentDlg")
        if dlg then
            dlg:setMuneType()
            dlg:setting(gid)
            local rect = self:getBoundingBoxInWorldSpace(self.selectSender)
            dlg:setFloatingFramePos(rect)
        end
    end
end

function WenquanDlg:onInforPanel(sender, eventType)
    sender:setVisible(false)
end

function WenquanDlg:onCloseButton()
    gf:confirm(CHS[5450464], function()
        gf:CmdToServer("CMD_XCWQ_LEAVE", {})
    end)
end

function WenquanDlg:cleanup()
    DlgMgr:closeDlg("CombatViewDlg")

    self.schduleId = nil
    self.lastAction = nil
end

function WenquanDlg:MSG_GENERAL_NOTIFY(data)
    if NOTIFY.NOTIFY_SEND_INIT_DATA_DONE == data.notify then
        -- 等号登录时，由于部分数据未刷新会出现显示不全的情况，故重现打开
        DlgMgr:closeDlg("CombatViewDlg")

        local dlg = DlgMgr:openDlg("CombatViewDlg")
        DlgMgr:upDlg("CombatViewDlg", -40)
    end
end

return WenquanDlg
