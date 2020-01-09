-- NpcCardDlg.lua
-- Created by songcw June/26/2018
-- npc名片界面

local NpcCardDlg = Singleton("NpcCardDlg", Dialog)

function NpcCardDlg:init(data)
    self:bindListener("SourceButton", self.onSourceButton)
    self:bindListener("ApplyButton", self.onApplyButton)

    self:setData(data)

    self:hookMsg("MSG_INVENTORY")
end

function NpcCardDlg:MSG_INVENTORY(data)
    if data.count == 0 then return end
    for i = 1, data.count do
        if data[i].pos == self.data.pos then
            if not data[i].name then
                self:onCloseButton()
            end
        end
    end
end

--
function NpcCardDlg:setData(data)
    self.data = data
    -- 头像
    self:setImage("ItemImage", ResMgr:getSmallPortrait(data.icon))

    -- 名字
    self:setLabelText("NameLabel", data.npcName)

    -- 性别
    self:setLabelText("SexLabel", string.format(CHS[4010174], gf:getGenderChs(data.gender)))

    -- 住址
    self:setLabelText("AddressLabel_2", data.address)

    -- 爱好
    self:setLabelText("HobbyLabel_2", data.hobby)

    -- 特征
    self:setLabelText("MeLabel_2", data.myTrait)

    -- 心仪人特征
    self:setLabelText("MindLabel_2", data.loverTrait)

    -- 备注
    self:setLabelText("TimeLabel", gf:getServerDate(CHS[4010175], data.deadline))
end

function NpcCardDlg:onSourceButton(sender, eventType)
    gf:ShowSmallTips(CHS[4010176])    -- 光棍节喜结姻缘活动产出。
end

function NpcCardDlg:onApplyButton(sender, eventType)
        -- 判断物品是否已经超时
    local item = InventoryMgr:getItemByPos(self.data.pos)
    if InventoryMgr:isItemTimeout(item) then
        InventoryMgr:notifyItemTimeout(item)
        self:close()
        return
    end

    gf:ShowSmallTips(CHS[4010177]) -- 前往#R桃柳林、官道南、官道北、北海沙滩、揽仙镇外和卧龙坡#n将名片赠送给合适的异性青年。
end

return NpcCardDlg
