-- FastUseItemDlg.lua
-- Created by songcw Api/27/2015
-- 快速使用物品界面

local FastUseItemForWawaDlg = Singleton("FastUseItemForWawaDlg", Dialog)

function FastUseItemForWawaDlg:getCfgFileName()
    return ResMgr:getDlgCfg("FastUseItemDlg")
end


function FastUseItemForWawaDlg:init(data)
    self:setCtrlVisible("CloseButton", false)
  --  self:bindListener("ItemImage", self.onItemCardButton)
    self.blank:setLocalZOrder(Const.FAST_USE_ITEM_DLG_ZORDER)
    self:bindListener("UseButton", self.onLongUseButton, self.onUseButton)
    self.itemName = nil
    self.applyTime = 0

    self:setData(data)

    self.root:setAnchorPoint(0, 0)
    local dlgSize = self.root:getContentSize()
    self.root:setPosition(Const.WINSIZE.width, 0)

    -- 动作结束回调
    local actCallBack = cc.CallFunc:create(function()

    end)

    local move = cc.MoveTo:create(0.5, cc.p(Const.WINSIZE.width / Const.UI_SCALE - dlgSize.width - (Const.WINSIZE.width - self:getWinSize().width) / 2, 0))
    local moveAct = cc.EaseBounceOut:create(move)
    self.root:runAction(cc.Sequence:create(moveAct, actCallBack))


    self:setImage("ItemImage", ResMgr.ui.dashui_image)
    self:setItemImageSize("ItemImage")
end

function FastUseItemForWawaDlg:setData(data)
    self.data = data
end

function FastUseItemForWawaDlg:onLongUseButton(sender, eventType)

    local houseData = HomeMgr:getMyHomeData()
    if not houseData then
        self:onCloseButton()
        return
    end


    if self.data.water_stage == 1 then
        local destStr = "#Z" .. HomeMgr:getHomeTypeCHS(houseData.house_type) .. "-" .. CHS[7002330] .. string.format("|H=%s|Dlg=dashui1#Z", self.data.home_id )
        AutoWalkMgr:beginAutoWalk(gf:findDest(destStr))
    elseif self.data.water_stage == 2 then
        local destStr = "#Z" .. self.data.room .. string.format("|H=%s#Z", self.data.home_id )
        local dest = gf:findDest(destStr)
        dest.x = self.data.x
        dest.y = self.data.y

        local roomName = self.data.room
        local function endWalk( para )
            if MapMgr.mapData.map_name == roomName then
                gf:CmdToServer("CMD_CHILD_BIRTH_WATER", {state = 2})
            end
        end

        dest.destCallback = {func = endWalk, para = ""}
        AutoWalkMgr:beginAutoWalk(dest)
    end
end

return FastUseItemForWawaDlg
