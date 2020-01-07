-- DropDoubleDlg.lua
-- Created by yangym Mar/14/2017
-- 掉落翻倍介绍界面

local DropDoubleDlg = Singleton("DropDoubleDlg", Dialog)

local ITEM_MARGIN = 0

local RES_LIST =
{
    -- 超级女娲石
    {
        CHS[2200008], -- 帮派日常挑战
        CHS[3000283], -- 帮派任务
        CHS[3001754], -- 八仙梦境
        CHS[7002143], -- 28变异星
        CHS[7002144], -- 10大鬼差
        CHS[4010374], -- 文曲星
        CHS[7002145], -- 万年老妖
        CHS[7002146], -- 超级大BOSS
        CHS[4100959],   -- 七杀试炼
        CHS[4200510],   -- 世界BOSS
        CHS[3000693], -- 海盗入侵
        CHS[7002147], -- 神仙下凡
        CHS[7000014], -- 活跃度宝箱
    },

    -- 首饰
    {
        CHS[7002143], -- 28变异星
        CHS[7002144], -- 10大鬼差
        CHS[4010374], -- 文曲星
        CHS[7002145], -- 万年老妖
        CHS[7002146], -- 超级大BOSS
        CHS[4100959],   -- 七杀试炼
        CHS[4200510],   -- 世界BOSS
        CHS[3000720], -- 铲除妖王
        CHS[7000014], -- 活跃度宝箱
    },

    -- 通天令牌
    {
        CHS[2000073], -- 通天塔
    },
}

local PANEL_NAME =
{
    "ItemPanel1",
    "ItemPanel2",
    "ItemPanel3",
}

function DropDoubleDlg:init()
    self.cell = self:getControl("FromPanel")
    self.cell:retain()
    self.cell:removeFromParent()

    self:bindResourceButton()
    self:setItemImage()
    self:onItemPanel(self:getControl("ItemPanel1"), 2)
end

function DropDoubleDlg:bindResourceButton()
    for i = 1, #PANEL_NAME do
        self:getControl(PANEL_NAME[i]):setTag(i)
        self:bindListener(PANEL_NAME[i], self.onItemPanel)
    end
end

function DropDoubleDlg:onItemPanel(sender, eventType)
    self:clearSelectEffect()
    self:setCtrlVisible("BChosenEffectImage", true, sender)
    self.type = sender:getTag()
    self:refreshResourcePanel(self.type)
end

function DropDoubleDlg:clearSelectEffect()
    for i = 1, #PANEL_NAME do
        self:setCtrlVisible("BChosenEffectImage", false, PANEL_NAME[i])
    end
end

function DropDoubleDlg:setItemImage()
    -- 设置图标
    self:setImage("ItemImage", InventoryMgr:getIconFileByName(CHS[3000666]), "ItemShapePanel1")
    self:setImagePlist("ItemImage", ResMgr.ui["big_jewelry"], "ItemShapePanel2")
    self:setImage("ItemImage", InventoryMgr:getIconFileByName(CHS[7000081]), "ItemShapePanel3")
end

function DropDoubleDlg:refreshResourcePanel()
    local listView = self:getControl("ListView")
    listView:removeAllChildren()
    listView:setItemsMargin(ITEM_MARGIN)

    local type = self.type
    if not type then
        return
    end

    local resList = RES_LIST[type]
    for i = 1, #resList do
        local cell = self.cell:clone()
        self:setLabelText("FromLabel", string.format(CHS[7003029], resList[i]), cell)
        listView:pushBackCustomItem(cell)
    end
end

function DropDoubleDlg:cleanup()
    self:releaseCloneCtrl("cell")
end

return DropDoubleDlg
