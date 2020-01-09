-- UserAutoAddPointDlg.lua
-- Created by cheny Dec/22/2014
-- 自动加点界面

local UserAutoAddPointDlg = Singleton("UserAutoAddPointDlg", Dialog)

local PLAN_TYPE = {["PLAN_PHY"] = 1, ["PLAN_MAG"] = 2, ["PLAN_USER"] = 3}

function UserAutoAddPointDlg:init()
    self:bindListener("AutoAddPointButton", function(dlg, sender, eventType)
        self:setCtrlVisible("PlanBKImage", true)
    end)

    self:bindFloatPanel("PlanBKImage")

    self:bindListener("CustomPanel", function(dlg, sender, eventType)
        self:onMenuTouch(sender)
    end)

    self:bindListener("MagicPanel", function(dlg, sender, eventType)
        self:onMenuTouch(sender)
    end)

    self:bindListener("PhysicalPanel", function(dlg, sender, eventType)
        self:onMenuTouch(sender)
    end)

    self:bindFloatPanel("TouchPanel", "InfoPanel")
    self:bindListener("InfoButton", function(dlg, sender, eventType)
        self:setCtrlVisible("InfoPanel", true)
    end)

    self:bindListener("ConAddButton", self.onConAddButton)
    self:bindListener("ConReduceButton", self.onConReduceButton)
    self:bindListener("WizAddButton", self.onWizAddButton)
    self:bindListener("WizReduceButton", self.onWizReduceButton)
    self:bindListener("StrAddButton", self.onStrAddButton)
    self:bindListener("StrReduceButton", self.onStrReduceButton)
    self:bindListener("DexAddButton", self.onDexAddButton)
    self:bindListener("DexReduceButton", self.onDexReduceButton)
    self:bindListener("RecommendButton", self.onRecommendButton)
    self:bindListener("SchemeCheckBox1", self.onSchemeButton1)
    self:bindListener("SchemeCheckBox2", self.onSchemeButton2)
    self:bindListener("ConfrimButton", self.onConfrimButton)
    self:bindListener("CancelButton", self.onCancelButton)
    self:onRecommendButton()

    self:hookMsg("MSG_SEND_RECOMMEND_ATTRIB")
end

function UserAutoAddPointDlg:initSwichButton(isOn)
    local statePanel = self:getControl("OpenStatePanel")
    self:createSwichButton(statePanel, isOn, self.onSwichButton)
    self.isOn = isOn
    self:swichTipsLabel()
end

function UserAutoAddPointDlg:swichTipsLabel()
    if self.isOn == true then
        self:setCtrlVisible("EnableLabel", true)
        self:setCtrlVisible("UnableLabel", false)
    else
        self:setCtrlVisible("EnableLabel", false)
        self:setCtrlVisible("UnableLabel", true)
    end
end
function UserAutoAddPointDlg:onSwichButton(isOn, key)
    if isOn == true then
        self.isOn = true
        self:swichTipsLabel()
    else
        self.isOn = false
        self:swichTipsLabel()
    end
end

function UserAutoAddPointDlg:bindFloatPanel(nodeName, closePanelNode)
    local panel = self:getControl(nodeName)

    local function onTouchBegan(touch, event)
        return true
    end

    local function onTouchMove(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()

    end

    local function onTouchEnd(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()
        if closePanelNode then
            panel = self:getControl(closePanelNode, Const.UIPanel)
        end
        panel:setVisible(false)
    end


    -- 创建监听事件
    local listener = cc.EventListenerTouchOneByOne:create()

    -- 设置是否需要传递
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_CANCELLED)

    -- 添加监听
    local dispatcher = panel:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, panel)
end

function UserAutoAddPointDlg:onMenuTouch(sender)
    -- 隐藏menu， 显示menu Title
    self:setCtrlVisible("PlanBKImage", false)
    local strTitle = self:getLabelText("EnoughLabel", sender)
    self:setLabelText("TitleLabel", strTitle)

    if sender:getName() == "CustomPanel" then
        self.plan = PLAN_TYPE.PLAN_USER
        --gf:CmdToServer("CMD_GENERAL_NOTIFY", { type = NOTIFY.GET_RECOMMEND_ATTRIB })
    elseif sender:getName() == "MagicPanel" then
        self:resetInfo(0,3,0,1, PLAN_TYPE.PLAN_MAG)
    elseif sender:getName() == "PhysicalPanel" then
        self:resetInfo(0,0,3,1, PLAN_TYPE.PLAN_PHY)
    end
end

function UserAutoAddPointDlg:cleanup()
    self.id = 0
end

function UserAutoAddPointDlg:setAutoAddObject(id)
    if nil == id then
        self.id = 0
        return
    end

    self.id = id
end

function UserAutoAddPointDlg:resetCtrlStatus()
    local con = tonumber(self:getLabelText('ConValueLabel'))
    local wiz = tonumber(self:getLabelText('WizValueLabel'))
    local str = tonumber(self:getLabelText('StrValueLabel'))
    local dex = tonumber(self:getLabelText('DexValueLabel'))

    local total = con + wiz + str + dex
    if total >= 4 then
        self:setCtrlEnabled('ConAddButton', false)
        self:setCtrlEnabled('WizAddButton', false)
        self:setCtrlEnabled('StrAddButton', false)
        self:setCtrlEnabled('DexAddButton', false)
    else
        self:setCtrlEnabled('ConAddButton', true)
        self:setCtrlEnabled('WizAddButton', true)
        self:setCtrlEnabled('StrAddButton', true)
        self:setCtrlEnabled('DexAddButton', true)
    end

    self:setCtrlEnabled('ConReduceButton', con > 0)
    self:setCtrlEnabled('WizReduceButton', wiz > 0)
    self:setCtrlEnabled('StrReduceButton', str > 0)
    self:setCtrlEnabled('DexReduceButton', dex > 0)
end

function UserAutoAddPointDlg:resetInfo(con, wiz, str, dex, plan)

    if  con < 0 or wiz < 0 or str < 0 or dex < 0 or
        con + wiz + str + dex > 4 then return end

    if con + wiz + str + dex == 0 then
        str = 3
        dex = 1
    end

    self.conAdd = con
    self.wizAdd = wiz
    self.strAdd = str
    self.dexAdd = dex
    self.plan = plan
    self.attribPoint = 4 - con - wiz - str - dex
    self:setLabelText("ConValueLabel", con)
    self:setLabelText("WizValueLabel", wiz)
    self:setLabelText("StrValueLabel", str)
    self:setLabelText("DexValueLabel", dex)

    if plan == PLAN_TYPE.PLAN_PHY then
        self:setLabelText("TitleLabel", CHS[3003764])
    elseif plan == PLAN_TYPE.PLAN_MAG then
        self:setLabelText("TitleLabel", CHS[3003765])
    elseif plan == PLAN_TYPE.PLAN_USER then
        self:setLabelText("TitleLabel", CHS[3003766])
    end

    self:resetCtrlStatus()
end

function UserAutoAddPointDlg:tryAddPoint(key, addLabel, delta)
    local value = self[key.."Add"]
    if value == nil then return false end

    -- 修正加点值
    if delta > self.attribPoint then delta = self.attribPoint end
    if delta == 0 then return false end
    if value + delta < 0 then return false end

    -- 显示加点
    value = value + delta
    self[key.."Add"] = value
    self.attribPoint = self.attribPoint - delta

    -- 设置颜色
    self:setLabelText(addLabel, value)

    self.plan = PLAN_TYPE.PLAN_USER
    self:setLabelText("TitleLabel", CHS[3003766])

    self:resetCtrlStatus()

    return true
end

function UserAutoAddPointDlg:onConAddButton(sender, eventType)
    self:tryAddPoint("con", "ConValueLabel", 1)
end

function UserAutoAddPointDlg:onConReduceButton(sender, eventType)
    self:tryAddPoint("con", "ConValueLabel", -1)
end

function UserAutoAddPointDlg:onWizAddButton(sender, eventType)
    self:tryAddPoint("wiz", "WizValueLabel", 1)
end

function UserAutoAddPointDlg:onWizReduceButton(sender, eventType)
    self:tryAddPoint("wiz", "WizValueLabel", -1)
end

function UserAutoAddPointDlg:onStrAddButton(sender, eventType)
    self:tryAddPoint("str", "StrValueLabel", 1)
end

function UserAutoAddPointDlg:onStrReduceButton(sender, eventType)
    self:tryAddPoint("str", "StrValueLabel", -1)
end

function UserAutoAddPointDlg:onDexAddButton(sender, eventType)
    self:tryAddPoint("dex", "DexValueLabel", 1)
end

function UserAutoAddPointDlg:onDexReduceButton(sender, eventType)
    self:tryAddPoint("dex", "DexValueLabel", -1)
end

function UserAutoAddPointDlg:onRecommendButton(sender, eventType)
    self:resetInfo(0,0,3,1)
end

function UserAutoAddPointDlg:onSchemeButton1(sender, eventType)
    self:resetInfo(0,3,0,1)
end

function UserAutoAddPointDlg:onSchemeButton2(sender, eventType)
    self:resetInfo(0,0,3,1)
end

function UserAutoAddPointDlg:onConfrimButton(sender, eventType)
    if nil == self.id then
        self.id = 0
    end

    local autoAdd = 0
    if self.isOn then autoAdd = 1 end

    if (self.conAdd + self.wizAdd + self.strAdd + self.dexAdd) < 4 then
        gf:ShowSmallTips(CHS[3003767])
        return
    end

    -- 安全锁判断
    if not GameMgr:IsCrossDist() and self:checkSafeLockRelease("onConfrimButton", sender, eventType) then
        return
    end

    gf:CmdToServer("CMD_SET_RECOMMEND_ATTRIB", {
        id = self.id,
        con = self.conAdd,
        wiz = self.wizAdd,
        str = self.strAdd,
        dex = self.dexAdd,
        auto_add = autoAdd,
        plan = self.plan,
    })

    if autoAdd > 0 then
        if self.id > 0 then
            DlgMgr:sendMsg('PetGetAttribDlg', 'autoPreAssign', self.conAdd, self.wizAdd, self.strAdd, self.dexAdd)
        else
            DlgMgr:sendMsg('UserAddPointDlg', 'autoPreAssign', self.conAdd, self.wizAdd, self.strAdd, self.dexAdd)
        end
    end

    DlgMgr:closeDlg("UserAutoAddPointDlg")
end

function UserAutoAddPointDlg:onCancelButton(sender, eventType)
    DlgMgr:closeDlg("UserAutoAddPointDlg")
end

function UserAutoAddPointDlg:MSG_SEND_RECOMMEND_ATTRIB(data)
    -- if data.id ~= 0 then return end
    self:resetInfo(data.con, data.wiz, data.str, data.dex, data.plan)

    if  self.isCreateSwichButton then return end
    if data.auto_add == 1 then
        self:initSwichButton(true)
    else
        self:initSwichButton(false)
    end

    self.isCreateSwichButton = true
end

-- 新手指引
function UserAutoAddPointDlg:getSelectItemBox(param)
    if param == "physicAddPoint" then
        return self.physciRect
    elseif param == "magicAddPoint" then
        return self.magicRect
    end
end

-- 如果需要使用指引通知类型，需要重载这个函数
function UserAutoAddPointDlg:youMustGiveMeOneNotify(param)
    if "TouchAutoCheck" == param then
        if self:isCheck("EnableCheckBox") then
            GuideMgr:youCanDoIt(self.name)
        else
            GuideMgr:youCanDoIt(self.name, param)
        end
    end
end

function UserAutoAddPointDlg:cleanup()
    self.isCreateSwichButton = false
end

return UserAutoAddPointDlg
