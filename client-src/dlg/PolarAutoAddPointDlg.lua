-- PolarAutoAddPointDlg.lua
-- Created by cheny Jan/08/2015
-- 相性自动加点对话框

local PolarAutoAddPointDlg = Singleton("PolarAutoAddPointDlg", Dialog)

local POLAR_TAB = {[1] = "Metal", [2] = "Wood", [3] = "Water", [4] = "Fire", [5] = "Earth"}
local POLAR_TAB_TEXT = {[1] = CHS[3003484], [2] = CHS[3003485], [3] = CHS[3003486], [4] = CHS[3003487], [5] = CHS[3003488]}
local PLAN_TYPE = {["PLAN_PHY"] = 1, ["PLAN_MAG"] = 2, ["PLAN_USER"] = 3}


function PolarAutoAddPointDlg:init()
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("ConfrimButton", self.onConfrimButton)
    self:bindNormalEvent()

    self.para1 = 0
    self.para2 = 0
    self.para3 = 0
    self.para4 = 0
    self.para5 = 0

    self:hookMsg("MSG_SEND_RECOMMEND_POLAR")
end

function PolarAutoAddPointDlg:initSwichButton(isOn)
    local statePanel = self:getControl("OpenStatePanel")
    self:createSwichButton(statePanel, isOn, self.onSwichButton)
    self.isOn = isOn
    self:swichTipsLabel()
end

function PolarAutoAddPointDlg:swichTipsLabel()
    if self.isOn == true then
        self:setCtrlVisible("EnableLabel", true)
        self:setCtrlVisible("UnableLabel", false)
    else
        self:setCtrlVisible("EnableLabel", false)
        self:setCtrlVisible("UnableLabel", true)
    end
end

function PolarAutoAddPointDlg:onSwichButton(isOn, key)
    if isOn == true then
        self.isOn = true
        self:swichTipsLabel()
    else
        self.isOn = false
        self:swichTipsLabel()
    end
end


function PolarAutoAddPointDlg:getPolarByDesc(desc)
    for k, v in pairs(POLAR_TAB_TEXT) do
        if v == desc then
            return k
        end
    end

    -- 不应该到这边
    assert(false)
end

function PolarAutoAddPointDlg:getMagicOrder(polar)
    if polar == POLAR.METAL then
        return POLAR.METAL, POLAR.FIRE, POLAR.WOOD, 0, 0
    elseif polar == POLAR.WOOD then
        return POLAR.METAL, POLAR.WOOD, POLAR.FIRE, 0, 0
    elseif polar == POLAR.WATER then
        return POLAR.METAL, POLAR.WATER, POLAR.FIRE, 0, 0
    elseif polar == POLAR.FIRE then
        return POLAR.METAL, POLAR.FIRE, POLAR.WOOD, 0, 0
    elseif polar == POLAR.EARTH then
        return POLAR.METAL, POLAR.EARTH, POLAR.FIRE, 0, 0
    end
end

function PolarAutoAddPointDlg:onMenuTouch(sender)
    -- 隐藏menu， 显示menu Title
    self:setCtrlVisible("PlanBKPanel", false)
    local strTitle = self:getLabelText("EnoughLabel", sender)
    self:setLabelText("TitleLabel", strTitle, "AutoAddPointButton")

    if sender:getName() == "CustomPanel" then
        self.plan = PLAN_TYPE.PLAN_USER
        --gf:CmdToServer("CMD_GENERAL_NOTIFY", { type = NOTIFY.GET_RECOMMEND_POLAR })
    elseif sender:getName() == "MagicPanel" then
        local polar = Me:queryInt("polar")
        local para1, para2, para3, para4, para5 = self:getMagicOrder(polar)
        self:resetInfo(para1, para2, para3, para4, para5, PLAN_TYPE.PLAN_MAG)
    elseif sender:getName() == "PhysicalPanel" then
        self:resetInfo(5, 4, 2, 4, 0, PLAN_TYPE.PLAN_PHY)
    end
end

function PolarAutoAddPointDlg:bindDropButton(buttonName, root)
    self:bindListener(buttonName, function(dlg, sender, eventType)
        self:showDropMenu(root)
    end, root)
end

function PolarAutoAddPointDlg:onDropMenu(sender, root)
    local tab = gf:split(root, "_")
    local polarText = self:getLabelText("EnoughLabel", sender)
    self:setLabelText("ValueLabel", polarText, "ShowPanel_" .. tab[2])
    self.plan = PLAN_TYPE.PLAN_USER
    if tab[2] == "1" then
        self.para1 = self:getPolarByDesc(polarText) or self.para1
    elseif tab[2] == "2" then
        self.para2 = self:getPolarByDesc(polarText) or self.para2
    elseif tab[2] == "3" then
        self.para3 = self:getPolarByDesc(polarText) or self.para3
    end

    self:setLabelText("TitleLabel", CHS[3003489], "AutoAddPointButton")
    self:setCtrlVisible(root, false)
end

function PolarAutoAddPointDlg:showDropMenu(name)
    self:setCtrlVisible("PlanBKImage_1", false)
    self:setCtrlVisible("PlanBKImage_2", false)
    self:setCtrlVisible("PlanBKImage_3", false)
    local tab = gf:split(name, "_")

    self:setCtrlVisible("PlanBKImage_" .. tab[2], true)
end

function PolarAutoAddPointDlg:bindFloatPanel(nodeName, closePanelNode)
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


function PolarAutoAddPointDlg:bindNormalEvent()
    self:bindListener("AutoAddPointButton", function(dlg, sender, eventType)
        self:setCtrlVisible("PlanBKPanel", true)
    end)

    self:bindFloatPanel("PlanBKPanel")

    self:bindListener("CustomPanel", function(dlg, sender, eventType)
        self:onMenuTouch(sender)
    end)

    self:bindListener("MagicPanel", function(dlg, sender, eventType)
        self:onMenuTouch(sender)
    end)

    self:bindListener("PhysicalPanel", function(dlg, sender, eventType)
        self:onMenuTouch(sender)
    end)

    self:bindListener("InfoButton", function(dlg, sender, eventType)
        DlgMgr:openDlg("XiangXinDlg")
    end)

    self:bindDropButton("DropButton", "ShowPanel_1")
    self:bindDropButton("DropButton", "ShowPanel_2")
    self:bindDropButton("DropButton", "ShowPanel_3")
    self:bindFloatPanel("PlanBKImage_1")
    self:bindFloatPanel("PlanBKImage_2")
    self:bindFloatPanel("PlanBKImage_3")

    for i = 1, 3 do
        local rootName = "PlanBKImage_" .. i
        for k, v in pairs(POLAR_TAB) do
            local nodeName = v .. "Panel"
            self:bindListener(nodeName, function(dlg, sender, eventType)
                self:onDropMenu(sender, rootName)
            end, rootName)
        end
    end

end

function PolarAutoAddPointDlg:resetInfo(para1, para2, para3, para4, para5, plan)
    if para1 <= 0 or para2 <= 0 or para3 <= 0 then
        return
    end

    self.para1 = para1
    self.para2 = para2
    self.para3 = para3
    self.para4 = para4
    self.para5 = para5
    self.plan = plan

    -- 设置第一个
    local strPolarText = POLAR_TAB_TEXT[para1]
    self:setLabelText("ValueLabel", strPolarText, "ShowPanel_1")

    -- 设置第二个
    strPolarText = POLAR_TAB_TEXT[para2]
    self:setLabelText("ValueLabel", strPolarText, "ShowPanel_2")

    -- 设置第三个
    strPolarText = POLAR_TAB_TEXT[para3]
    self:setLabelText("ValueLabel", strPolarText, "ShowPanel_3")

    -- 设置title
    if plan == PLAN_TYPE.PLAN_PHY then
        self:setLabelText("TitleLabel", CHS[3003490], "AutoAddPointButton")
    elseif plan == PLAN_TYPE.PLAN_MAG then
        self:setLabelText("TitleLabel", CHS[3003491], "AutoAddPointButton")
    elseif plan == PLAN_TYPE.PLAN_USER then
        self:setLabelText("TitleLabel", CHS[3003489], "AutoAddPointButton")
    end

end

function PolarAutoAddPointDlg:onInfoButton(sender, eventType)
    gf:ShowSmallTips(CHS[2000048])
end

function PolarAutoAddPointDlg:onConfrimButton(sender, eventType)
    if self.para1 <= 0 or self.para2 <= 0 or self.para3 <= 0 or not self.plan
    then return end

    if self.para1 == self.para2 or self.para1 == self.para3 or
        self.para2 == self.para3 then
        gf:ShowSmallTips(CHS[3003492])
        return
    end

    -- 安全锁判断
    if not GameMgr:IsCrossDist() and self:checkSafeLockRelease("onConfrimButton", sender, eventType) then
        return
    end

    self.para4 = 0
    self.para5 = 0
    local autoAdd = 0
    if self.isOn then autoAdd = 1 end
    gf:CmdToServer("CMD_SET_RECOMMEND_POLAR", {
        id = 0,
        para1 = self.para1,
        para2 = self.para2,
        para3 = self.para3,
        para4 = self.para4,
        para5 = self.para5,
        auto_add = autoAdd,
        plan = self.plan
    })
    DlgMgr:closeDlg("PolarAutoAddPointDlg")
end

function PolarAutoAddPointDlg:onCancelButton(sender, eventType)
    DlgMgr:closeDlg("PolarAutoAddPointDlg")
end

function PolarAutoAddPointDlg:onSchemeButton1(sender, eventType)
    local polar = Me:queryBasicInt("polar")
    if polar == POLAR.METAL then
        self:resetInfo(POLAR.METAL,POLAR.FIRE,POLAR.WOOD,POLAR.WATER,POLAR.EARTH)
    elseif polar == POLAR.WOOD then
        self:resetInfo(POLAR.WOOD,POLAR.METAL,POLAR.FIRE,POLAR.WATER,POLAR.EARTH)
    elseif polar == POLAR.WATER then
        self:resetInfo(POLAR.WATER,POLAR.METAL,POLAR.FIRE,POLAR.WOOD,POLAR.EARTH)
    elseif polar == POLAR.FIRE then
        self:resetInfo(POLAR.FIRE,POLAR.METAL,POLAR.WOOD,POLAR.WATER,POLAR.EARTH)
    elseif polar == POLAR.EARTH then
        self:resetInfo(POLAR.EARTH,POLAR.METAL,POLAR.FIRE,POLAR.WOOD,POLAR.WATER)
    end

    self:setCheck('SchemeCheckBox2', false)
end

function PolarAutoAddPointDlg:onSchemeButton2(sender, eventType)
    self:resetInfo(POLAR.EARTH,POLAR.WOOD,POLAR.WATER,POLAR.FIRE,POLAR.METAL)
    self:setCheck('SchemeCheckBox1', false)
end

function PolarAutoAddPointDlg:MSG_SEND_RECOMMEND_POLAR(data)
    if data.id ~= 0 then return end
    self:resetInfo(data.para1, data.para2, data.para3, data.para4, data.para5, data.plan)

    if self.isCreateSwichButton then return end

    if data.auto_add == 1 then
        self:initSwichButton(true)
    else
        self:initSwichButton(false)
    end

    self.isCreateSwichButton = true
end

-- 如果需要使用指引通知类型，需要重载这个函数
function PolarAutoAddPointDlg:youMustGiveMeOneNotify(param)
    if "TouchAutoCheck" == param then
        if self:isCheck("EnableCheckBox") then
            GuideMgr:youCanDoIt(self.name)
        else
            GuideMgr:youCanDoIt(self.name, param)
        end
    end
end

function PolarAutoAddPointDlg:cleanup()
    self.isCreateSwichButton = false
end

return PolarAutoAddPointDlg
