-- LuckIdentifyDlg.lua
-- Created by songcw Oct/26/2017
-- 好运鉴宝

local LuckIdentifyDlg = Singleton("LuckIdentifyDlg", Dialog)

function LuckIdentifyDlg:init()
    self:bindListener("IdentifyButton", self.onIdentifyButton, "UnIdentifyPanel")
    self:bindListener("IdentifyButton", self.onIdentifyButton, "IdentifiedPanel")
    self:bindListener("NoteButton", self.onNoteButton)
    self:bindListener("GetBonusButton", self.onGetBonusButton)

    self:bindListener("ItemPanel_1", self.onDefaultItem)
    self:bindListener("ItemPanel_2", self.onIdentifyItem)

    self:bindFloatPanelListener("LuckIdentifyRulePanel")

    self:hookMsg("MSG_NEWYEAR_2018_HYJB")
    self:hookMsg("MSG_ENTER_ROOM")

    self.data = nil
end

-- 与策划沟通，此界面需要在玩家远离npc后被关闭
function LuckIdentifyDlg:onUpdate()
    if not self.data then return end
    if not CharMgr:getChar(self.data.npcId) then
        -- 远离NPC了
        self:onCloseButton()
        gf:ShowSmallTips(CHS[4100877])
    end
end

function LuckIdentifyDlg:cleanup()
        gf:CmdToServer("CMD_NEWYEAR_2018_HYJB", {type = 3})
    gf:closeConfirmByType("haoyun_jianbao")
end

function LuckIdentifyDlg:onIdentifyButton(sender, eventType)
    if not self.data then return end
    if self.data.result == "" then
        gf:CmdToServer("CMD_NEWYEAR_2018_HYJB", {type = 0})
    else
        gf:CmdToServer("CMD_NEWYEAR_2018_HYJB", {type = 1})
    end
end

function LuckIdentifyDlg:onNoteButton(sender, eventType)
    self:setCtrlVisible("LuckIdentifyRulePanel", true)
end


function LuckIdentifyDlg:onIdentifyItem(sender, eventType)
    if not self.data or self.data.result == "" or self.data.process ~= 0 then return end
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(self.data.result, rect)
end

function LuckIdentifyDlg:onDefaultItem(sender, eventType)
    if not self.data then return end
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(self.data.itemName, rect)
end

function LuckIdentifyDlg:onGetBonusButton(sender, eventType)
    gf:CmdToServer("CMD_NEWYEAR_2018_HYJB", {type = 2})
end

function LuckIdentifyDlg:MSG_ENTER_ROOM(data)
    self:onCloseButton()
    gf:ShowSmallTips(CHS[4100877])
end

function LuckIdentifyDlg:MSG_NEWYEAR_2018_HYJB(data)
    self.data = data
    self:setImage("ItemImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(data.itemName)))

    local image = self:getControl("ItemImage", nil, "ItemPanel_2")

    InventoryMgr:removeLogoBinding(image)
    if data.result == "" then
        -- 第一次鉴定
        self:setCtrlVisible("UnIdentifyPanel", true)
        self:setCtrlVisible("IdentifiedPanel", false)

        local cashText, fontColor = gf:getArtFontMoneyDesc(data.cost)
        self:setNumImgForPanel("CostCashPanel", fontColor, cashText, false, LOCATE_POSITION.LEFT_TOP, 23, "UnIdentifyPanel")
    else
        self:setCtrlVisible("UnIdentifyPanel", false)
        self:setCtrlVisible("IdentifiedPanel", true)
        local cashText, fontColor = gf:getArtFontMoneyDesc(data.cost)
        self:setNumImgForPanel("CostCashPanel", fontColor, cashText, false, LOCATE_POSITION.LEFT_TOP, 23, "IdentifiedPanel")
        self:setImage("ItemImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(data.result)), "ItemPanel_2")

        self:setProgressBar("ProgressBar", data.process * 0.01, 100)
        self:setLabelText("ProgressValueLabel", string.format("%.02f%%", data.process * 0.01))

        if data.isLimit == 1 then
            InventoryMgr:addLogoBinding(image)
        end
    end


    -- 没有进度，显示问号
    if data.process ~= 0 then
        self:setImage("ItemImage", ResMgr.ui.quest_mark, "ItemPanel_2")
        InventoryMgr:removeLogoBinding(image)
    end

    self:setLabelText("ItemLabel", data.result, "IdentifiedPanel")
end

return LuckIdentifyDlg
