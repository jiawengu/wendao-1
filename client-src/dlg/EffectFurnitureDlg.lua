-- EffectFurnitureDlg.lua
-- Created by lixh Sep/08/2017
-- 金丝鸟笼，白玉观音像，七宝如意

local EffectFurnitureDlg = Singleton("EffectFurnitureDlg", Dialog)

-- 金丝鸟笼，白玉观音像，七宝如意
local TYPE_TO_NAME = {CHS[7190000], CHS[7190001], CHS[7190002]}

-- 宠物饲养，人物修炼，法宝修炼
local TYPE_TO_EFFECT_NAME = {CHS[7190004], CHS[7190005], CHS[7190006]}

-- 未通灵，未请神，未聚气
local TYPE_TO_NO_EFFECT_NAME = {CHS[7190010], CHS[7190011], CHS[7190012]}

-- 通    灵，请    神，聚    气
local TYPE_TO_BTN_NAME = {CHS[7190007], CHS[7190008], CHS[7190009]}

-- 金 丝 鸟 笼，白 玉 观 音 像，七 宝 如 意
local TYPE_TO_TITLE_NAME = {CHS[7190015], CHS[7190016], CHS[7190017]}

function EffectFurnitureDlg:init(data)
    self:bindListener("RuleButton", self.onRuleButton)
    self:bindListener("WaitButton", self.onWaitButton)
    self:bindListener("StartButton", self.onStartButton)
    self:bindListener("EndButton", self.onEndButton)
    self:bindListener("CancelButton", self.onCancelButton)
    self:bindListener("OpenButton", self.onOpenButton)

    self.dlgType = data.type
    self.furniturePos = data.pos
    self.furnitureX, self.furnitureY = data.pX, data.pY

    self.usingBuffValue = 0

    self:setData()

    self:hookMsg("MSG_HOUSE_PRACTICE_BUFF_DATA")
    self:hookMsg("MSG_HOUSE_REFRESH_PRACTICE_BUFF_DATA")
end

function EffectFurnitureDlg:onRuleButton(sender, eventType)
    local dlg = DlgMgr:openDlg("EffectFurnitureRuleDlg")
    dlg:setRuleByType(self.dlgType)
end

function EffectFurnitureDlg:sendMessageToServer(action)
    HomeMgr:cmdHouseUseFurniture(self.furniturePos, "practice_buff", action)
end

function EffectFurnitureDlg:canOper()
    if not HomeMgr:isInMyHouse() then
        gf:ShowSmallTips(CHS[5410115])
        return
    end

    local info = HomeMgr:getFurnitureInfo(TYPE_TO_NAME[self.dlgType])
    if info then
        local place = string.match(info.furniture_type, "(.-)-.+")
        if not string.match(MapMgr:getCurrentMapName(), place) then
            gf:ShowSmallTips(string.format(CHS[5410116], place))
            return
        end
    end

    return true
end

function EffectFurnitureDlg:onWaitButton(sender, eventType)
    if not self:canOper() then
        return
    end

    local furn = HomeMgr:getFurnitureById(self.furniturePos)
    -- 目标家具已消失
    if not furn then
        gf:ShowSmallTips(CHS[5410041])
        self:onCloseButton()
        return
    end

    -- 对应家具位置已发生改变
    if self.furnitureX ~= furn.curX or self.furnitureY ~= furn.curY then
        gf:ShowSmallTips(CHS[4200418])
        self:onCloseButton()
        return
    end

    self:sendMessageToServer("wait")
end

function EffectFurnitureDlg:onStartButton(sender, eventType)
    if not self:canOper() then
        return
    end

    local furn = HomeMgr:getFurnitureById(self.furniturePos)
    -- 目标家具已消失
    if not furn then
        gf:ShowSmallTips(CHS[5410041])
        self:onCloseButton()
        return
    end

    -- 对应家具位置已发生改变
    if self.furnitureX ~= furn.curX or self.furnitureY ~= furn.curY then
        gf:ShowSmallTips(CHS[4200418])
        self:onCloseButton()
        return
    end

    self:sendMessageToServer("start")
end

function EffectFurnitureDlg:onEndButton(sender, eventType)
    if not self:canOper() then
        return
    end

    if MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
        local furn = HomeMgr:getFurnitureById(self.furniturePos)
        -- 目标家具已消失
        if not furn then
            gf:ShowSmallTips(CHS[5410041])
            self:onCloseButton()
            return
        end

        -- 对应家具位置已发生改变
        if self.furnitureX ~= furn.curX or self.furnitureY ~= furn.curY then
            gf:ShowSmallTips(CHS[4200418])
            self:onCloseButton()
            return
        end        
    end
    
    self:sendMessageToServer("stop")
end

function EffectFurnitureDlg:onCancelButton(sender, eventType)
    if not self:canOper() then
        return
    end

    local furn = HomeMgr:getFurnitureById(self.furniturePos)
    -- 目标家具已消失
    if not furn then
        gf:ShowSmallTips(CHS[5410041])
        self:onCloseButton()
        return
    end

    -- 对应家具位置已发生改变
    if self.furnitureX ~= furn.curX or self.furnitureY ~= furn.curY then
        gf:ShowSmallTips(CHS[4200418])
        self:onCloseButton()
        return
    end

    self:sendMessageToServer("nowait")
end

function EffectFurnitureDlg:onOpenButton(sender, eventType)
    if not self:canOper() then
        return
    end
    
    local furn = HomeMgr:getFurnitureById(self.furniturePos)
    -- 目标家具已消失
    if not furn then
        gf:ShowSmallTips(CHS[5410041])
        self:onCloseButton()
        return
    end

    -- 对应家具位置已发生改变
    if self.furnitureX ~= furn.curX or self.furnitureY ~= furn.curY then
        gf:ShowSmallTips(CHS[4200418])
        self:onCloseButton()
        return
    end

    self:sendMessageToServer("active")
end

function EffectFurnitureDlg:setData()
    local type = self.dlgType
    local effectFurnitureData = HomeMgr:getEffectFurnitureData()
    local furnitureStaus = effectFurnitureData.status
    local buffValue = effectFurnitureData.buffValue
    local tolerance = effectFurnitureData.tolerance

    self.furniturePos = effectFurnitureData.pos
    self.usingBuffValue = effectFurnitureData.startupBuffValue

    -- 服务器返回数据中：家具状态，BUFF加成值，耐久度不能为nil
    if not furnitureStaus or not buffValue or not tolerance then
        return
    end

    if furnitureStaus == 0 then
        if buffValue== 0 then
            -- 未请神，通灵，聚气
            self:setCtrlVisible("OpenButton", true)
            self:setCtrlVisible("WaitButton", false)
            self:setCtrlVisible("StartButton", false)
            self:setLabelText("EffectLabel_1", TYPE_TO_NO_EFFECT_NAME[type], "EffectPanel_1")

            self:setLabelText("Label_1", TYPE_TO_BTN_NAME[type], "OpenButton")
            self:setLabelText("Label_2", TYPE_TO_BTN_NAME[type], "OpenButton")
        else
            self:setCtrlVisible("OpenButton", false)
            self:setCtrlVisible("WaitButton", true)
            self:setCtrlVisible("StartButton", true)
            self:setLabelText("EffectLabel_1", string.format("%d%%",buffValue), "EffectPanel_1")
        end

        self:setCtrlVisible("EndButton", false)
        self:setCtrlVisible("CancelButton", false)
    elseif furnitureStaus == 1 then
        -- 等待中，只显示取消等待
        self:setCtrlVisible("WaitButton", false)
        self:setCtrlVisible("StartButton", false)
        self:setCtrlVisible("EndButton", false)
        self:setCtrlVisible("CancelButton", true)
        self:setCtrlVisible("OpenButton", false)

        self:setLabelText("EffectLabel_1", string.format("%d%%",buffValue), "EffectPanel_1")
    elseif furnitureStaus == 2 then
        -- 使用中，只显示停止按钮
        self:setCtrlVisible("WaitButton", false)
        self:setCtrlVisible("StartButton", false)
        self:setCtrlVisible("EndButton", true)
        self:setCtrlVisible("CancelButton", false)
        self:setCtrlVisible("OpenButton", false)

        self:setLabelText("EffectLabel_1", string.format("%d%%",buffValue), "EffectPanel_1")
    end

    local maxTolerance = HomeMgr:getMaxDur(TYPE_TO_NAME[type])
    self:setLabelText("NaijiuLabel_1", string.format("%d/%d", tolerance, maxTolerance), "NaijiuPanel")
    self:setLabelText("Label_2", TYPE_TO_TITLE_NAME[type], "TitleNamePanel")

    self:setIconAndLabel(TYPE_TO_NAME[type], TYPE_TO_EFFECT_NAME[type])
end

function EffectFurnitureDlg:setIconAndLabel(name, effectName)
    local path = ResMgr:getItemIconPath(InventoryMgr:getIconByName(name))
    self:setImage("ShowImage", path, "ShowPanel")

    self:setLabelText("NameLabel_1", name, "NamePanel")
    self:setLabelText("EffectLabel_1", effectName, "EffectPanel")
end

-- 刷新界面信息
function EffectFurnitureDlg:MSG_HOUSE_PRACTICE_BUFF_DATA()
    self:setData()
end

-- 特殊情况，A,B两人打开界面时，因为管理器里面MSG_HOUSE_PRACTICE_BUFF_DATA会打开界面
-- 所以新增以下消息刷新界面
function EffectFurnitureDlg:MSG_HOUSE_REFRESH_PRACTICE_BUFF_DATA(data)
    if data.pos == self.furniturePos then
        -- 同一界面
        local type = self.dlgType
        if data.status == 0 then
            if data.buffValue== 0 then
                -- 未请神，通灵，聚气
                self:setCtrlVisible("OpenButton", true)
                self:setCtrlVisible("WaitButton", false)
                self:setCtrlVisible("StartButton", false)
                self:setLabelText("EffectLabel_1", TYPE_TO_NO_EFFECT_NAME[type], "EffectPanel_1")

                self:setLabelText("Label_1", TYPE_TO_BTN_NAME[type], "OpenButton")
                self:setLabelText("Label_2", TYPE_TO_BTN_NAME[type], "OpenButton")
            else
                self:setCtrlVisible("OpenButton", false)
                self:setCtrlVisible("WaitButton", true)
                self:setCtrlVisible("StartButton", true)
                self:setLabelText("EffectLabel_1", string.format("%d%%", data.buffValue), "EffectPanel_1")
            end

            self:setCtrlVisible("EndButton", false)
            self:setCtrlVisible("CancelButton", false)
        elseif data.status == 1 then
            -- 等待中，只显示取消等待
            self:setCtrlVisible("WaitButton", false)
            self:setCtrlVisible("StartButton", false)
            self:setCtrlVisible("EndButton", false)
            self:setCtrlVisible("CancelButton", true)
            self:setCtrlVisible("OpenButton", false)

            self:setLabelText("EffectLabel_1", string.format("%d%%", data.buffValue), "EffectPanel_1")
        elseif data.status == 2 then
            -- 使用中，只显示停止按钮
            self:setCtrlVisible("WaitButton", false)
            self:setCtrlVisible("StartButton", false)
            self:setCtrlVisible("EndButton", true)
            self:setCtrlVisible("CancelButton", false)
            self:setCtrlVisible("OpenButton", false)

            self:setLabelText("EffectLabel_1", string.format("%d%%", data.buffValue), "EffectPanel_1")
            self.usingBuffValue = data.buffValue
        end

        local maxTolerance = HomeMgr:getMaxDur(TYPE_TO_NAME[type])
        self:setLabelText("NaijiuLabel_1", string.format("%d/%d", data.tolerance, maxTolerance), "NaijiuPanel")
    else
        self.usingBuffValue = data.buffValue
    end
end

return EffectFurnitureDlg
