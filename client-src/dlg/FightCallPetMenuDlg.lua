-- FightCallPetMenuDlg.lua
-- Created by cheny Dec/2/2014
-- 战斗中召唤宠物界面

local FightCallPetMenuDlg = Singleton("FightCallPetMenuDlg", Dialog)

function FightCallPetMenuDlg:init()
    self:setFullScreen()
    self:bindListener("ReturnButton", self.onReturnButton)
    self.clonePanel = self:getControl("PetPanel", Const.UIPanel)
    self.clonePanel:retain()
    self.clonePanel:removeFromParent()
    self.listView = self:getControl("PetListView", Const.UIListView)
    self.listView:removeAllItems()
    self.curId = nil
    self:setPetList()

end

function FightCallPetMenuDlg:onCallPetButton(sender, eventType)
    if not self.curId then
        gf:ShowSmallTips(CHS[3002606])
        return
    end

    self:close()
    local id = self.curId
    gf:sendFightCmd(Me:getId(), id, FIGHT_ACTION.SELECT_PET, 0)
    FightMgr:changeMeActionFinished()
end

function FightCallPetMenuDlg:onReturnButton(sender, eventType)
    self:close()
    FightMgr:openFightMeMenuDlg()
end

function FightCallPetMenuDlg:onSelectPetListView(sender, eventType, id)
    self:close()
    local id = self:getListViewSelectedItemTag(sender)
    gf:sendFightCmd(Me:getId(), id, FIGHT_ACTION.SELECT_PET, 0)
    FightMgr:changeMeActionFinished()
end

function FightCallPetMenuDlg:onLongTouchListView(sender, eventType, id)

    local pet = PetMgr:getPetById(id)
    if pet then
        local dlg =  DlgMgr:openDlg("PetCardDlg")
        dlg:setPetInfo(pet, true)
    end
end

function FightCallPetMenuDlg:cleanup()
    if self.clonePanel then
        self.clonePanel:release()
        self.clonePanel = nil
    end
end

function FightCallPetMenuDlg:clearSelect()
    local items = self.listView:getItems()
    for k, v in pairs(items) do
        self:setCtrlVisible("ChosenEffectImage", false, v)
    end
end

-- 设置宠物列表
function FightCallPetMenuDlg:setPetList()
    local list = PetMgr:getCanCallPets()
    for k, v in pairs(list) do
        local pet = PetMgr:getPetById(v.id)
        local panel = self.clonePanel:clone()
        local path = ResMgr:getSmallPortrait(pet:queryBasicInt("portrait"))
        local name = gf:getPetName(pet.basic)
        local level = "LV.".. pet:queryBasic("level")
        local polarName = gf:getPolar(pet:queryBasicInt("polar"))
        self:setImage("GuardImage", path, panel)
        self:setItemImageSize("GuardImage", panel)
        self:setLabelText("NameLabel", name, panel)
        self:setLabelText("LevelLabel", level, panel)
        self:setLabelText("PolarValueLabel", polarName, panel)
        self.listView:pushBackCustomItem(panel)

        self:blindLongPressListView(panel, function(dlg, sender, eventType)
            self:clearSelect()
            self.curId = v.id
            self:onLongTouchListView(sender,eventType, v.id)


        end,
        function(dlg, sender, eventType)
            self:clearSelect()
            self.curId = v.id
            self:onCallPetButton()
        end, true)
    end
end

-- 控件长按
function FightCallPetMenuDlg:blindLongPressListView(widget, OneSecondLaterFunc, func, resFunc)
    if not widget then
        return
    end

    self:blindLongPressWithCtrl(widget, OneSecondLaterFunc, func, true)

    --[[local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            local callFunc = cc.CallFunc:create(function()
                if OneSecondLaterFunc and self.longPress then
                    OneSecondLaterFunc(self, sender, eventType)
                end
                self.root:stopAction(self.longPress)
                self.longPress = nil
            end)
            self.longPress = cc.Sequence:create(cc.DelayTime:create(GameMgr:getLongPressTime()),callFunc)
            self.root:runAction(self.longPress)
        elseif eventType == ccui.TouchEventType.ended then
            if self.longPress ~= nil then
                self.root:stopAction(self.longPress)
                self.longPress = nil
                func(sender, eventType)
            end
        else
            self.root:stopAction(self.longPress)
            self.longPress = nil
        end
    end

    widget:addTouchEventListener(listener)]]
end


return FightCallPetMenuDlg
