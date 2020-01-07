-- SystemConfigDlg.lua
-- Created by zhengjh Sep/9/2015
-- 系统设置

local SystemConfigDlg = Singleton("SystemConfigDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")
local Bitset = require("core/Bitset")

local CHECKBOX_CONFIG =
{
   ["FriendVerifyCheckBox"] = "verify_be_added",
   ["InterchangeCheckBox"] = "refuse_fight",
   ["PartyVoiceCheckBox"] = "autoplay_party_voice",
   ["TeamVoiceCheckBox"] = "autoplay_team_voice",
   ["FliterVoiceCheckBox"] = "forbidden_play_voice",
   ["RefuseStrangerCheckBox"] = "refuse_stranger_msg",
}

-- 以下部分互相关联，json中若删除某个控件，也应删除相应配置
local RADIOGROUP_PANEL =
{
    ["LevelStatuesPanel"] = "sight_scope",      -- 历史遗留，此处其实是游戏效果
    ["CheckEquipPanel"]   = "refuse_look_equip",
    ["PartyLogoPanel"] = "refuse_party_image",
    ["HomePanel"] = "visit_house",
}

local RADIOGROUP_CHECKBOX =
{
    ["LevelStatuesPanel"] = { ["CheckBox1"] = 0, ["CheckBox2"] = 1, ["CheckBox3"] = 2 },
    ["CheckEquipPanel"]   = { ["OpenCheckBox"] = 0, ["CloseCheckBox"] = 1 },
    ["PartyLogoPanel"]    = { ["OpenCheckBox"] = 0, ["CloseCheckBox"] = 1 },
    ["HomePanel"]        =  { ["CheckBox1"] = 0, ["CheckBox2"] = 1, ["CheckBox3"] = 2 },
}

function SystemConfigDlg:init()
    local basePanel = "PublicPanel"
    if DebugMgr:enableFightMsgRecord() then
        basePanel = "TestPanel"
    else
        basePanel = "PublicPanel"
    end

    self:setCtrlVisible("TestPanel", DebugMgr:enableFightMsgRecord())
    self:setCtrlVisible("PublicPanel", not DebugMgr:enableFightMsgRecord())

    self:bindListener("ConversionCodeButton", self.onConversionCodeButton, basePanel)
    self:bindListener("ConversionCodeButton_1", self.onConversionCodeButton, basePanel)
    self:bindListener("ConversionCodeButton_2", self.onConversionCodeButton, basePanel)
    self:bindListener("LockScreenButton",self.OnLockScreenButton, basePanel)
    self:bindListener("UpdateButton", self.onUpdateButton, basePanel)
    self:bindListener("UpdateButton_1", self.onUpdateButton, basePanel)
    self:bindListener("ConnectCheckButton", self.onConnectCheckButton, basePanel)
    self:createShareButton(self:getControl("ShareButton", nil, basePanel), SHARE_FLAG.SYSCONFIG, function()
        if not Me or string.isNilOrEmpty(Me:queryBasic("name")) then
            return
        end

        local info = {
            {"isOffice", tostring(ShareMgr:isOffice())},
            {"dist", Client:getWantLoginDistName()},
            {"name", Me:queryBasic("name")},
            {"level", Me:queryBasicInt("level")},
            {"polar", Me:queryBasicInt("polar")},
            {"gender", Me:queryBasicInt("gender")},
            {"tao", math.floor(Me:queryBasicInt("tao") / Const.ONE_YEAR_TAO)},
            {"phyPower", Me:queryInt("phy_power")},
            {"magPower", Me:queryInt("mag_power")},
            {"life", Me:queryInt("max_life")},
            {"mana", Me:queryInt("max_mana")},
            {"speed", Me:queryInt("speed")},
            {"def", Me:queryInt("def")},
        }
        local paramStr = ""
        local sign = ""
        local count = #info
        for i = 1, count do
            paramStr = paramStr .. string.format("%s=%s&", info[i][1], info[i][2])
            sign = sign .. info[i][2] .. "_"
        end

        sign = string.lower(gfGetMd5(sign .. "loTW_D*m$"))
        paramStr = paramStr .. string.format("sign=%s", sign)

        local data = {}
        data.url = "http://activity.leiting.com/wd/201901/h5" .. string.format("?%s",paramStr)
        data.title = string.format(CHS[5430000], Me:queryBasic("name"))
        data.desc = CHS[5430027]
        data.thumbPath = cc.FileUtils:getInstance():fullPathForFilename(ResMgr.ui.atm_share_url_icon)
        data.shareFlag = SHARE_FLAG.SYSCONFIG
        ShareMgr:shareUrl(data)
    end)

    if DebugMgr:enableFightMsgRecord() then
        self:bindListener("FeedbackButton", self.onFeedbackButton, basePanel)
    else
        self:setCtrlVisible("UpdateButton", CheckNetMgr:isEnabled(), basePanel)
        self:setCtrlVisible("UpdateButton_1", not CheckNetMgr:isEnabled(), basePanel)
        self:setCtrlVisible("ConnectCheckButton", CheckNetMgr:isEnabled(), basePanel)
    end

    if gf:isIos() or gf:isWindows() then
        self:setCtrlVisible("CommentButton", true, basePanel)
        self:bindListener("CommentButton", self.onCommentButton, basePanel)
        self:setCtrlVisible("ConversionCodeButton_1", false, basePanel)
        self:setCtrlVisible("ConversionCodeButton_2", false, basePanel)
    else
        self:setCtrlVisible("ConversionCodeButton_1", not ShareMgr:isShowShareBtn(), basePanel)
        self:setCtrlVisible("ConversionCodeButton_2", ShareMgr:isShowShareBtn(), basePanel)
        self:setCtrlVisible("CommentButton", false, basePanel)
    end

    self:bindSliderListener("Slider",self.OnMusicSlider)
    self:bindSliderListener("SoundSlider",self.OnSoundSlider)

    self:bindListViewListener("VoiceListView", self.onSelectVoiceListView)
    self:bindListViewListener("SystemListView", self.onSelectSystemListView)

    -- 高级设置面板
    self:bindSettingPanelListener()
    self:bindSettingCheckBoxListener()
    self:bindListener("SettingButton", function()
        self:setCtrlVisible("SettingPanel", true)
    end)

    local userDefault = cc.UserDefault:getInstance()

    -- 设置音量
    local musicVolumeValue  = SystemSettingMgr:getVolumeValue()
    self:setSliderPercent("Slider", musicVolumeValue)

    -- 获取系统设置状态
    local settingTable = SystemSettingMgr:getSettingStatus()

    -- 拒绝切磋
    local interchangeOn = settingTable["refuse_fight"] == 1 and true or false
    local interchangePanel = self:getControl("InterchangePanel")
    local interchangeStatePanel = self:getControl("OpenStatePanel", nil, interchangePanel)
    self:createSwichButton(interchangeStatePanel, interchangeOn, self.onSystemSwichBtn, "refuse_fight")

    -- 拒绝陌生消息
    local refuseStrangerOn = settingTable["refuse_stranger_msg"] == 1 and true or false
    local refuseStrangerPanel = self:getControl("RefuseStrangerPanel")
    local refuseStrangeStatePanel = self:getControl("OpenStatePanel", nil, refuseStrangerPanel)
    self:createSwichButton(refuseStrangeStatePanel, refuseStrangerOn, self.onSystemSwichBtn, "refuse_stranger_msg")

    -- 游戏录屏
    local screenRecordOn = userDefault:getBoolForKey("screenRecordOn", false) and ScreenRecordMgr:supportRecordScreen()
    local screenRecordPanel = self:getControl("ScreenRecordPanel")
    local screenRecordStatePanel = self:getControl("OpenStatePanel", nil, screenRecordPanel)
    self:createSwichButton(screenRecordStatePanel, screenRecordOn, self.onScreenRecordButton, nil, self.openScreenRecordLimit)
    screenRecordPanel:setVisible(not ScreenRecordMgr:isRecording())

    -- 拒绝震动
    local refuseShock = settingTable["refuse_shock"] == 1 and true or false;
    local refuseNotifyPanel = self:getControl("RefuseNotifyPanel")
    local refuseNofifyStatePanel = self:getControl("OpenStatePanel", nil, refuseNotifyPanel)
    self:createSwichButton(refuseNofifyStatePanel, refuseShock, self.onSystemSwichBtn, "refuse_shock")

    -- 帮派图标
    self:setCtrlVisible("PartyLogoPanel", true, "MainBodyPanel")

    -- 单选框开关
    self:bindCheckBoxListener("FriendVerifyCheckBox", self.checkBoxClick)
    self:bindCheckBoxListener("InterchangeCheckBox", self.checkBoxClick)
    self:bindCheckBoxListener("PartyVoiceCheckBox", self.checkBoxClick)
    self:bindCheckBoxListener("TeamVoiceCheckBox", self.checkBoxClick)
    self:bindCheckBoxListener("FliterVoiceCheckBox", self.checkBoxClick)
    self:bindCheckBoxListener("RefuseStrangerCheckBox", self.checkBoxClick)
    self:initCheckBox()

    --     WDSY-37577 海外版需屏蔽语音仅发送文字的设置选项
    if LeitingSdkMgr:isOverseas() then
        self:setCtrlVisible("FliterVoiceCheckBox", false)
        self:setCtrlVisible("FliterVoiceLabel", false)
        SystemSettingMgr:sendSeting("forbidden_play_voice", 0)
    end

    -- 绑定单选框组
    self.checkBoxTable = {}
    self:bindRadioGroup()

    -- 为IOS评审
    self:forIOSReview()
end

function SystemConfigDlg:bindSettingPanelListener()
    local panel = self:getControl("SettingPanel")
    panel:setVisible(false)
    local function onTouchBegan(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()
        Log:D("location : x = %d, y = %d, name:%s", touchPos.x, touchPos.y, event:getCurrentTarget():getName())

        if not panel or not panel:isVisible() then
            return false
        end

        touchPos = panel:getParent():convertToNodeSpace(touchPos)
        local box = panel:getBoundingBox()
        if nil == box then
            return false
        end

        if cc.rectContainsPoint(box, touchPos) then
            return true
        else
            panel:setVisible(false)
        end
    end

    local function onTouchEnd(touch, event)
        return true
    end

    -- 创建监听事件
    local listener = cc.EventListenerTouchOneByOne:create()

    -- 设置是否需要传递
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_CANCELLED)

    -- 添加监听
    local dispatcher = panel:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, panel)
end

function SystemConfigDlg:bindSettingCheckBoxListener()
    -- 游戏音乐、游戏音效、游戏配音和提醒音效
    local settingTable = {"Music", "Sound", "Dubbing", "Hint"}

    for i = 1, 4 do
        local panel = self:getControl("ConfigPanel" .. i)
        local checkBox = self:getControl("VoiceCheckBox", Const.UICheckBox, panel)

        -- 给checkbox进行初始化操作
        local getEnable = SystemSettingMgr["get" .. settingTable[i] .. "Enable"]
        if getEnable and "function" == type(getEnable) then
            -- 分别调用了getMusicEnable, getSoundEnable, getDubbingEnable, getHintEnable
            checkBox:setSelectedState(getEnable(SystemSettingMgr))
        end

        -- 给checkbox添加改变事件
        self:bindCheckBoxWidgetListener(checkBox, function(self, sender, eventType)
            local isOn = eventType == ccui.CheckBoxEventType.selected
            local setEnable = SystemSettingMgr["set" .. settingTable[i] .. "Enable"]
            if setEnable and "function" == type(setEnable) then
                -- 分别调用了setMusicEnable, setSoundEnable, setDubbingEnable, setHintEnable
                setEnable(SystemSettingMgr, isOn)
            end

            if isOn then
                gf:ShowSmallTips(CHS[3003682])  -- 设置成功
            else
                gf:ShowSmallTips(CHS[3003687])  -- 取消成功
            end
        end)
    end
end

function SystemConfigDlg:addMagic()
    local addPanel = self:getControl("EffectPanel")
    gf:createArmatureMagic(ResMgr.ArmatureMagic.system_config_btn, addPanel, Const.ARMATURE_MAGIC_TAG, 28, 1)
end

function SystemConfigDlg:removeMagic()
    local panel = self:getControl("EffectPanel")
    self:removeArmatureMagicFromCtrl("EffectPanel", Const.ARMATURE_MAGIC_TAG, panel)
end

function SystemConfigDlg:forIOSReview()
    self:setCtrlVisible("ConversionCodeButton", not gf:isIos())
end

-- 绑定单选框组
function SystemConfigDlg:bindRadioGroup()
    for k, v in pairs(RADIOGROUP_PANEL) do
        local panel = self:getControl(k)
        self.checkBoxTable[k] = RadioGroup.new()

        local checkBoxes = {}
        local allCheckGroup = RADIOGROUP_CHECKBOX[k]
        local v2i = {}
        local i = 1
        for k, v in pairs(allCheckGroup) do
            table.insert(checkBoxes, k)
            v2i[v] = i
            i = i + 1
        end

        self.checkBoxTable[k]:setItems(self, checkBoxes, self.onCheckBox, panel)

        -- 初值选中状态
        local settingTable = SystemSettingMgr:getSettingStatus()
        local status = settingTable[v] or 0
        local index = v2i[status]
        self.checkBoxTable[k]:selectRadio(index, true)
        --[[
        if status == 0 then
            self.checkBoxTable[k]:selectRadio(2, true)
        else
            self.checkBoxTable[k]:selectRadio(1, true)
        end]]
    end
end

function SystemConfigDlg:onCheckBox(sender, eventType)
    local name = sender:getName()
	local panelName = sender:getParent():getName()
    local key = RADIOGROUP_PANEL[panelName]
    local checkBoxes = RADIOGROUP_CHECKBOX[panelName]
    local value = checkBoxes[name]
    local isLocalStorge = Bitset.new(SystemSettingMgr:getConfigByKey(key) or 0)
    if value and isLocalStorge then
        if isLocalStorge:isSet(2) then
            SystemSettingMgr:saveSetting(key, value)
        end

        if isLocalStorge:isSet(1) then
            SystemSettingMgr:sendSeting(key, value)
        end

        if panelName ~= "CheckEquipPanel" then
            gf:ShowSmallTips(CHS[3003682])
        elseif value == 0 then
            gf:ShowSmallTips(CHS[7000004])
        elseif value == 1 then
            gf:ShowSmallTips(CHS[7000005])
        end
    end


    if key == "sight_scope"  and sender:getName() == "CheckBox3"then
        self:removeMagic()
    end
end

-- 设置系统设置
function SystemConfigDlg:onSystemSwichBtn(isOn, key)
    SystemSettingMgr:sendSeting(key, isOn and 1 or 0)
    gf:ShowSmallTips(CHS[3003682])
end

-- statePanel 滑动控件
-- isOn 开启状态
-- func 回调
-- key 回调传回去的 key
--[[
function SystemConfigDlg:createSwichButton(statePanel, isOn, func, key)
    -- 创建滑动开关
    local isOn = isOn
    local bkImage1 = self:getControl("BKImage1", nil, statePanel)
    local bkImage2 = self:getControl("BKImage2", nil, statePanel)
    local image = self:getControl("Image", nil, statePanel)
    local onPositionX = image:getPositionX()
    local isAtionEnd = true
    local function swichButtonAction()
        local action
        if isAtionEnd then
            if isOn  then
                local moveto = cc.MoveTo:create(0.5,cc.p(0, image:getPositionY()))
                isAtionEnd = false
                local fuc = cc.CallFunc:create(function ()
                    local fadeIn = cc.FadeIn:create(0.5)
                    bkImage1:setOpacity(0)
                    bkImage1:runAction(fadeIn)
                    local fadeout = cc.FadeOut:create(0.5)
                    local delayFunc  = cc.CallFunc:create(function () isAtionEnd = true   func(self, isOn, key) end)
                    local sq = cc.Sequence:create(fadeout, delayFunc)

                    bkImage2:runAction(sq)
                end)

                local deily = cc.DelayTime:create(0.5)

                action = cc.Spawn:create(moveto, fuc)
                image:runAction(action)

                isOn = not isOn
            else
                local moveto = cc.MoveTo:create(0.5,cc.p(onPositionX, image:getPositionY()))
                isAtionEnd = false
                local fuc = cc.CallFunc:create(function ()
                    local fadeIn = cc.FadeIn:create(0.5)
                    bkImage2:setOpacity(0)
                    bkImage2:runAction(fadeIn)

                    local fadeout = cc.FadeOut:create(0.5)
                    local delayFunc  = cc.CallFunc:create(function () isAtionEnd= true func(self, isOn, key) end)
                    local sq = cc.Sequence:create(fadeout, delayFunc)

                    bkImage1:runAction(sq)

                end)

                action = cc.Spawn:create(moveto, fuc)
                image:runAction(action)
                isOn = not isOn
            end

        end
    end

    self:bindTouchEndEventListener(statePanel, swichButtonAction)

    if isOn then
        bkImage1:setOpacity(0)
        image:setPositionX(onPositionX)
    else
        bkImage2:setOpacity(0)
        image:setPositionX(0)
    end

end
]]
function SystemConfigDlg:onConversionCodeButton(sender, eventType)
    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[3003684])
        return
    end
    DlgMgr:openDlg("ConversionCodeDlg")
end

--[[
function SystemConfigDlg:onDelCharButton(sender, eventType)
    if 1 then
        gf:ShowSmallTips(CHS[3003685])
        return
    end

    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[3003686])
        return
    end


    if Me:queryBasicInt("to_be_deleted") == 1 then
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_CANCEL_DELETE_CHAR)
    else
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_DELETE_CHAR)
    end

   -- if gf:isGD() then DlgMgr:openDlg("DebugDlg") end ---- cyq to be delete
end
--]]

function SystemConfigDlg:OnLockScreenButton(sender, eventType)
    DlgMgr:openDlg("LockScreenDlg")
    self:onCloseButton()
end

function SystemConfigDlg:onFeedbackButton(sender, eventType)
    local function confirmFunc(text)
        DebugMgr:uploadFightMgrData(text)
        DebugMgr:uploadFightMsg(text)
    end

    gf:confirm(CHS[2000114], confirmFunc, nil, true)
end

function SystemConfigDlg:onSelectVoiceListView(sender, eventType)
end

function SystemConfigDlg:onSelectSystemListView(sender, eventType)
end

-- 游戏录屏功能
function SystemConfigDlg:onScreenRecordButton(isOn, key)
    if isOn then
        -- 显示录屏按钮
        DlgMgr:openDlg("ScreenRecordingDlg")
    else
        -- 关闭录屏按钮
        DlgMgr:closeDlg("ScreenRecordingDlg")
    end

    -- 保存数据
    local userDefault = cc.UserDefault:getInstance()
    userDefault:setBoolForKey("screenRecordOn", isOn)
    gf:ShowSmallTips(CHS[3003682])
end

function SystemConfigDlg:openScreenRecordLimit(isOn)
    if not ScreenRecordMgr:supportRecordScreen() then
        if gf:isIos() then
            gf:ShowSmallTips(CHS[2000213])
        else
            gf:ShowSmallTips(CHS[2000214])
        end

        return true
    end
end

function SystemConfigDlg:OnMusicSlider(sender, eventType)
    local value = sender:getPercent()
    SystemSettingMgr:setVolumeValue(value)
end

function SystemConfigDlg:OnSoundSlider(sender, eventType)
    local value = sender:getPercent()
    SystemSettingMgr:setVolumeValue(value)
end


function SystemConfigDlg:checkBoxClick(sender, eventType)
    local key = CHECKBOX_CONFIG[sender:getName()]
    if eventType == ccui.CheckBoxEventType.selected then
        SystemSettingMgr:sendSeting(key, 1)
        gf:ShowSmallTips(CHS[3003682])
    elseif eventType == ccui.CheckBoxEventType.unselected then
        SystemSettingMgr:sendSeting(key, 0)
        gf:ShowSmallTips(CHS[3003687])
    end
end

function SystemConfigDlg:initCheckBox()
    local settingTable = SystemSettingMgr:getSettingStatus()

    for k, v in pairs(CHECKBOX_CONFIG) do
        self:setCheckBoxStaus(k, settingTable[v])
    end
end

function SystemConfigDlg:setCheckBoxStaus(name, status)
    local radio = self:getControl(name, Const.UICheckBox)

    if status == 1 then
        if radio then
            radio:setSelectedState(true)
        end
    elseif status == 0 or status == nil then
        if radio then
            radio:setSelectedState(false)
        end
    end

end

-- 评论
function SystemConfigDlg:onCommentButton(sender, eventType)
    ShareMgr:comment()
end

-- 更新说明
function SystemConfigDlg:onUpdateButton(sender, eventType)
    NoticeMgr:showDescDlg()
    DlgMgr:closeDlg("SystemConfigDlg")
end

-- 网络检查
function SystemConfigDlg:onConnectCheckButton(sender, eventType)
    gf:confirm(CHS[2200065], function()
    local CheckNetDlg = require('dlg/CheckNetDlg')
    local checkNetDlg = CheckNetDlg.create(2)
    gf:getUILayer():addChild(checkNetDlg)
    end, 0)
end

--[[
function SystemConfigDlg:onExitGameButton(sender , eventType)
    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[3003688])
        return
    end

    gf:CmdToServer("CMD_LOGOUT")
    CommThread:stop()
    local map = {}
    Client:clientDisconnectedServer(map)
end
]]
return SystemConfigDlg
