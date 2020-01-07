-- QuickUseOneDlg.lua
-- Created by lixh Mar/05/2018
-- 快捷使用界面(设置1种点数)

local QuickUseOneDlg = Singleton("QuickUseOneDlg", Dialog)

function QuickUseOneDlg:init(data)
    self:bindListener("UseButton", self.onUseButton)
    self:bindListener("AddButton", self.onAddDoubleButton, "SetPanel")
    self.pos = data.pos

    -- 物品信息
    local item = InventoryMgr:getItemByPos(self.pos)
    if item then
        self:setLabelText("ItemNameLabel", item.name)
        self:updateItemNum()
        local img = self:setImage("ItemImage", InventoryMgr:getIconFileByName(item.name))
        self:setItemImageSize("ItemImage")
        if item and InventoryMgr:isTimeLimitedItem(item) then
            InventoryMgr:removeLogoBinding(img)
            InventoryMgr:addLogoTimeLimit(img)
        elseif item and InventoryMgr:isLimitedItem(item) then
            InventoryMgr:removeLogoTimeLimit(img)
            InventoryMgr:addLogoBinding(img)
        else
            InventoryMgr:removeLogoTimeLimit(img)
            InventoryMgr:removeLogoBinding(img)
        end

        if item.level and item.level > 0 then
            self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, item.level, false, LOCATE_POSITION.CENTER, 21)
        end

        self:bindListener("ItemImage", self.onItemPanel)
    end

    -- 双倍选项
    self:setCheck("DoublePointCheckBox", data.doubleEnable == 1, "SetPanel")

    -- 双倍点数
    self:updateDoubelPointNum()

    OnlineMallMgr:openOnlineMall(nil, "notOpenDlg")

    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_UPDATE")
end

-- 悬浮框
function QuickUseOneDlg:onItemPanel(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    local item = InventoryMgr:getItemByPos(self.pos)
    if item then
        InventoryMgr:showBasicMessageDlg(item.name, rect)
    end
end

-- 购买双倍点数
function QuickUseOneDlg:onAddDoubleButton(sender, envetType)
    if not DistMgr:checkCrossDist() then return end

    if Me:queryBasicInt("double_points") > PracticeMgr:getDoublePointLimit() - 200 then
        gf:ShowSmallTips(CHS[3003496])

    else
        DlgMgr:openDlg("PracticeBuyDoubleDlg")
    end
end

-- 刷新物品数量
function QuickUseOneDlg:updateItemNum()
    local item = InventoryMgr:getItemByPos(self.pos)
    if item then
        self:setLabelText("ItemNumLabel", string.format(CHS[7120049], item.amount))
    else
        -- 物品数量变未0时，关闭界面
        self:onCloseButton()
    end
end

-- 刷新双倍点数
function QuickUseOneDlg:updateDoubelPointNum()
    local item = InventoryMgr:getItemByPos(self.pos)
    local num = GetTaoMgr:getAllDoublePoint()
    local quickUseItemCfg = InventoryMgr:getQuickUseItemCfg()
    if item and quickUseItemCfg[item.name] and quickUseItemCfg[item.name].needDoublePoint
        and num < quickUseItemCfg[item.name].needDoublePoint then
        -- 小于该物品最低点数要求，显示红色
        self:setLabelText("NumLabel2", num, "SetPanel", COLOR3.RED)
    else
        self:setLabelText("NumLabel2", num, "SetPanel", COLOR3.TEXT_DEFAULT)
    end
end
 
function QuickUseOneDlg:onUseButton(sender, eventType)
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003462])
        return
    end
    
    local doubleTag = self:isCheck("DoublePointCheckBox", "SetPanel") and 1 or 0
    gf:CmdToServer("CMD_QUICK_USE_ITEM", {pos = self.pos, doubleEnabel = doubleTag, chongfsEnable = 0})
end

function QuickUseOneDlg:MSG_INVENTORY()
    self:updateItemNum()
end

function QuickUseOneDlg:MSG_UPDATE()
    self:updateDoubelPointNum()
end

return QuickUseOneDlg

