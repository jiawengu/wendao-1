-- SeekFriendWelfareDlg.lua
-- Created by songcw Oct/22/2018
-- 寻找好友界面-福利界面

local SeekFriendWelfareDlg = Singleton("SeekFriendWelfareDlg", Dialog)


local TIPS = {

    CHS[4101281],
    CHS[4101281],
    CHS[4101281],
    CHS[4101282],
    CHS[4101283],
}

function SeekFriendWelfareDlg:init(data)

    for i = 1, 5 do
        local panel = self:getControl("Panel_" .. i)
        panel:setTag(i)
        self:bindListener("GoButton", self.onGoButton, panel)

        self:bindListener("ItemPanel", self.onShowItem, panel)
        self:setUnitPanel(data.bonusData[i], panel, i)
    end

    -- 姓名
    self:setLabelText("NameLabel", data.name)
    local fullData = GiftMgr:getXYFLData()
    if fullData and fullData.end_time then
        local endTime = gf:getServerDate(CHS[4010221], fullData.end_time)

        -- 时间
        self:setLabelText("TimeLabel", endTime)
    end

    self.data = data

    self:hookMsg("MSG_BJTX_WELFARE")
end

-- 设置单个
function SeekFriendWelfareDlg:setUnitPanel(info, panel, i)
    -- 道具图标
    local img = self:setImage("ItemImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(info.item_name)), panel)

    -- 数量
    self:setNumImgForPanel("ItemPanel", ART_FONT_COLOR.NORMAL_TEXT, info.item_count, false, LOCATE_POSITION.RIGHT_BOTTOM, 21, panel)

    -- 限制交易
    InventoryMgr:addLogoBinding(img)

    -- 按钮
    self:setCtrlVisible("ReceiveImage", info.is_fetch == 1, panel)
    self:setCtrlVisible("GoButton", info.is_fetch == 0, panel)
    self:setCtrlEnabled("GoButton", info.num == info.num_max, panel)

    self:setLabelText("TeamLabel", string.format("%d/%d", info.num ,info.num_max), panel)

    self:setLabelText("GameNameLabel", string.format(TIPS[i], info.num_max), panel)

    panel.data = info
end

-- 道具悬浮框
function SeekFriendWelfareDlg:onShowItem(sender, eventType)
    local data = sender:getParent().data
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(data.item_name, rect)
end

-- 领取按钮
function SeekFriendWelfareDlg:onGoButton(sender, eventType)
    local tag = sender:getParent():getTag()
    gf:CmdToServer("CMD_BJTX_FETCH_BONUS", {char_gid = self.data.gid, index = tag})
end

-- 刷新数据
function SeekFriendWelfareDlg:MSG_BJTX_WELFARE(data)
    for i = 1, data.count do
        if self.data.gid == data[i].gid then
            for j = 1, 5 do
                local panel = self:getControl("Panel_" .. j)
                self:setUnitPanel(data[i].bonusData[j], panel, j)
            end
        end
    end
end

return SeekFriendWelfareDlg
