-- PetAutoAttribDlg.lua
-- Created by liuhb Sep/24/2015
-- 宠物自动加点界面

local PetAutoAttribDlg = Singleton("PetAutoAttribDlg", Dialog)

local PLAN_TYPE = {["PLAN_RECOMMAND"] = 1, ["PLAN_USER"] = 2}
function PetAutoAttribDlg:init()
    self:bindListener("ConAddButton", self.onConAddButton)
    self:bindListener("ConReduceButton", self.onConReduceButton)
    self:bindListener("WizAddButton", self.onWizAddButton)
    self:bindListener("WizReduceButton", self.onWizReduceButton)
    self:bindListener("StrAddButton", self.onStrAddButton)
    self:bindListener("StrReduceButton", self.onStrReduceButton)
    self:bindListener("DexAddButton", self.onDexAddButton)
    self:bindListener("DexReduceButton", self.onDexReduceButton)
    self:bindListener("RecommendButton", self.onConfirmButton)

    self:bindListener("AutoAddPointButton", function(dlg, sender, eventType)
        self:setCtrlVisible("PlanBKImage", true)
    end)

    self:bindFloatPanel("PlanBKImage")

    self:bindListener("CustomPanel", function(dlg, sender, eventType)
        self:onMenuTouch(sender)
    end)

    self:bindListener("PhysicalPanel", function(dlg, sender, eventType)
        self:onMenuTouch(sender)
    end)

    self:createSwichButton(self:getControl("OpenStatePanel"), false, function(self, isOn)
        self.autoAdd = isOn

        if self.autoAdd then
            gf:ShowSmallTips(CHS[2000079])
        else
            gf:ShowSmallTips(CHS[2000080])
        end
    end)

    self:hookMsg("MSG_SEND_RECOMMEND_ATTRIB")
end

function PetAutoAttribDlg:cleanup()
    self.id = 0
    self.autoAdd = nil
    self.selectPetNo = nil
end

function PetAutoAttribDlg:setAutoAddObject(id)
    if nil == id then
        self.id = 0
        return
    end

    self.id = id

    -- 设置基本信息
    local pet = PetMgr:getPetById(id)
    self.selectPetNo = pet:queryBasicInt("no")
    if nil == pet then return end

    -- 珍贵、点化标记
    self:setPetLogoPanel(pet)

    -- 设置类型：野生、宝宝
    self:setImage("SuffixImage", ResMgr:getPetRankImagePath(pet))

    local nameLevel = string.format(CHS[4000391], pet:getShowName(), pet:queryBasicInt("level"))
    self:setLabelText("PetNameLabel", nameLevel)

    self:setLabelText("levelLabel", string.format(CHS[3003355], pet:queryInt("level")))
    self:setLabelText("PetPolarLabel", gf:getPolar(pet:queryInt("polar")))
    self:setPortrait("PetIconPanel", pet:getDlgIcon(nil, nil, true), 0, self.root, true, nil, nil, cc.p(0, -63))
end

function PetAutoAttribDlg:resetCtrlStatus()
    local con = tonumber(self:getLabelText('ConLabel'))
    local wiz = tonumber(self:getLabelText('WizLabel'))
    local str = tonumber(self:getLabelText('StrLabel'))
    local dex = tonumber(self:getLabelText('DexLabel'))

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

function PetAutoAttribDlg:tryAddPoint(key, addLabel, delta)
    local value = self[key .. "Add"]
    if value == nil then return false end

    -- 修正加点值
    if delta > self.attribPoint then delta = self.attribPoint end
    if delta == 0 then return false end
    if value + delta < 0 then return false end

    -- 显示加点
    value = value + delta
    self[key .. "Add"] = value
    self.attribPoint = self.attribPoint - delta

    -- 设置颜色
    self:setLabelText(addLabel, value)

    -- 设置剩余点数
    self:setLabelText("NoAllotLabel", self.attribPoint)

    self.plan = PLAN_TYPE.PLAN_USER
    self:setLabelText("TitleLabel", CHS[3003766])

    self:resetCtrlStatus()

    return true
end

function PetAutoAttribDlg:resetInfo(con, wiz, str, dex, plan)
    if  con < 0 or wiz < 0 or str < 0 or dex < 0 or
        con + wiz + str + dex > 4 then return end

    self.conAdd = con
    self.wizAdd = wiz
    self.strAdd = str
    self.dexAdd = dex
    self.plan = plan
    self.attribPoint = 4 - con - wiz - str - dex
    self:setLabelText("ConLabel", con)
    self:setLabelText("WizLabel", wiz)
    self:setLabelText("StrLabel", str)
    self:setLabelText("DexLabel", dex)

    if plan == PLAN_TYPE.PLAN_RECOMMAND then
        self:setLabelText("TitleLabel", CHS[2000078])
    elseif plan == PLAN_TYPE.PLAN_USER then
        self:setLabelText("TitleLabel", CHS[3003766])
    end

    self:resetCtrlStatus()
end

function PetAutoAttribDlg:onConAddButton(sender, eventType)
    self:tryAddPoint("con", "ConLabel", 1)
end

function PetAutoAttribDlg:onConReduceButton(sender, eventType)
    self:tryAddPoint("con", "ConLabel", -1)
end

function PetAutoAttribDlg:onWizAddButton(sender, eventType)
    self:tryAddPoint("wiz", "WizLabel", 1)
end

function PetAutoAttribDlg:onWizReduceButton(sender, eventType)
    self:tryAddPoint("wiz", "WizLabel", -1)
end

function PetAutoAttribDlg:onStrAddButton(sender, eventType)
    self:tryAddPoint("str", "StrLabel", 1)
end

function PetAutoAttribDlg:onStrReduceButton(sender, eventType)
    self:tryAddPoint("str", "StrLabel", -1)
end

function PetAutoAttribDlg:onDexAddButton(sender, eventType)
    self:tryAddPoint("dex", "DexLabel", 1)
end

function PetAutoAttribDlg:onDexReduceButton(sender, eventType)
    self:tryAddPoint("dex", "DexLabel", -1)
end

function PetAutoAttribDlg:onConfirmButton(sender, eventType)
    if nil == self.id then
        self.id = 0
    end

    if self.selectPetNo and PetMgr:getPetByNo(self.selectPetNo) then
        self.id = PetMgr:getPetByNo(self.selectPetNo):getId()
    end

    local con = tonumber(self:getLabelText('ConLabel'))
    local wiz = tonumber(self:getLabelText('WizLabel'))
    local str = tonumber(self:getLabelText('StrLabel'))
    local dex = tonumber(self:getLabelText('DexLabel'))

    local total = con + wiz + str + dex
    if total < 4 then
        gf:ShowSmallTips(CHS[3003767])
        return
    end

    -- 安全锁判断
    if not GameMgr:IsCrossDist() and self:checkSafeLockRelease("onConfirmButton", sender, eventType) then
        return
    end

    local autoAdd = 0
    if self.autoAdd then autoAdd = 1 end

    gf:CmdToServer("CMD_SET_RECOMMEND_ATTRIB", {
        id = self.id,
        con = self.conAdd,
        wiz = self.wizAdd,
        str = self.strAdd,
        dex = self.dexAdd,
        auto_add = autoAdd,
        plan = self.plan,
    })

    if self.autoAdd and self.id > 0 then
        DlgMgr:sendMsg('PetGetAttribDlg', 'autoPreAssign', self.conAdd, self.wizAdd, self.strAdd, self.dexAdd)
    end

    DlgMgr:closeDlg("PetAutoAttribDlg")
end

function PetAutoAttribDlg:onMenuTouch(sender)
    -- 隐藏menu， 显示menu Title
    self:setCtrlVisible("PlanBKImage", false)
    local strTitle = self:getLabelText("EnoughLabel", sender)
    self:setLabelText("TitleLabel", strTitle)

    if sender:getName() == "CustomPanel" then
        self.plan = PLAN_TYPE.PLAN_USER
    elseif sender:getName() == "PhysicalPanel" then
        if self.id == nil then return end
        local pet = PetMgr:getPetById(self.id)
        if nil == pet then return end
        if 0 == pet:queryBasicInt("polar") then
            self:resetInfo(0,0,3,1, PLAN_TYPE.PLAN_RECOMMAND)
        else
            self:resetInfo(0,3,0,1, PLAN_TYPE.PLAN_RECOMMAND)
        end
    end
end

function PetAutoAttribDlg:bindFloatPanel(nodeName)
    local panel = self:getControl(nodeName)

    local function onTouchBegan(touch, event)
        return true
    end

    local function onTouchEnd(touch, event)
        panel:setVisible(false)
    end

    -- 创建监听事件
    local listener = cc.EventListenerTouchOneByOne:create()

    -- 设置是否需要传递
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_CANCELLED)

    -- 添加监听
    local dispatcher = panel:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, panel)
end

-- 设置相性，贵重，点化标记
function PetAutoAttribDlg:setPetLogoPanel(pet)
    PetMgr:setPetLogo(self, pet)
end

function PetAutoAttribDlg:MSG_SEND_RECOMMEND_ATTRIB(data)
    self:resetInfo(data.con, data.wiz, data.str, data.dex, data.plan)
    self:setLabelText("NoAllotLabel", self.attribPoint)

    self.orgCon = data.con
    self.orgWiz = data.wiz
    self.orgStr = data.str
    self.orgDex = data.dex

    local state = 1 == data.auto_add and true or false
    self.autoAdd = state

    if self.autoAdd then
        self:switchButtonStatus(self:getControl("OpenStatePanel"), true)
    else
        self:switchButtonStatus(self:getControl("OpenStatePanel"), false)
    end
end

return PetAutoAttribDlg
