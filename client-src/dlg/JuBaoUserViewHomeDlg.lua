-- JuBaoUserViewHomeDlg.lua
-- Created by huangzz Nov/15/2017
-- 角色信息之居所界面

local JuBaoUserViewHomeDlg = Singleton("JuBaoUserViewHomeDlg", Dialog)

local HomeShowDlg = require('dlg/HomeShowDlg')
local JuBaoUserViewHomeDlg = Singleton("JuBaoUserViewHomeDlg", HomeShowDlg)

local HOME_ICON = {
    [HOME_TYPE.xiaoshe] = "ui/Icon0982.png",
    [HOME_TYPE.yazhu] = "ui/Icon0983.png",
    [HOME_TYPE.haozhai] = "ui/Icon0984.png",
}

function JuBaoUserViewHomeDlg:init()
    self:bindListener("HomeButton1", self.onHomeButton1)
    self:bindListener("HomeButton3", self.onHomeButton3)
    self:bindListener("HomeButton5", self.onHomeButton5)
    self:bindListener("ReduceButton", self.onReduceButton)
    self:bindListener("AddButton", self.onAddButton)
    self:bindListener("BuyButton", self.onBuyButton)
    self:bindListener("BuyButton", self.onBuyButton, "DesignatedSellPanel")
    self:bindListener("NoteButton", self.onNoteButton, "DesignatedSellPanel")
    
    -- 获取gid
    self.goods_gid = DlgMgr:sendMsg("JuBaoUserViewTabDlg", "getGid")

    -- 价格信息
    TradingMgr:setPriceInfo(self)
    
    self:setCtrlVisible("NoticePanel", false)
    self:setCtrlVisible("HomePanel", false)
    self:setCtrlVisible("NohomeKidsNoticePanel", false)
    local userData = TradingMgr:getTradGoodsData(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT)
    local childData = TradingMgr:getTradGoodsData(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_CHILD)
    if userData and not string.isNilOrEmpty(userData.house_id) then
        self.houseData = {}
        self.lifeLevel = {}
        self.houseData.house_id = userData.house_id
        self.lifeLevel.plant_level = userData.plant_level
        self.lifeLevel.fish_level = userData.fish_level

        self:setCtrlVisible("HomePanel", true)
        local kidListPanel = self:getControl("KidListPanel", nil, "HomePanel")
        if childData and #childData > 0 then
            -- 娃娃数据
            kidListPanel:setVisible(true)
            self:setChildInfo(kidListPanel, childData, true)
        else
            kidListPanel:setVisible(false)
        end

        gf:CmdToServer("CMD_TRADING_HOUSE_DATA", {house_id = userData.house_id})
    else
        if childData and #childData > 0 then
            -- 无居所，有孩子
            self:setCtrlVisible("NohomeKidsNoticePanel", true)
            self:setChildInfo(self:getControl("KidListPanel", nil, "NohomeKidsNoticePanel"), childData)
        else
            -- 无居所，无孩子
            self:setCtrlVisible("NoticePanel", true)
            
            self.lifeLevel = nil
            self.houseData = nil
        end

        return
    end

    self:bindScorllPanelEventListener("MapImage")

    self:checkButton(1)
    self:doCheck(1)

    -- 显示预览信息
    self.contentSize = self:getControl("MapImage", nil, "MapPanel"):getContentSize()

    -- 记录一下原始尺寸用于计算缩放
    self.oriW = self.contentSize.width
    self.oriH = self.contentSize.height

    self:hookMsg("MSG_HOUSE_ROOM_SHOW_DATA")
    self:hookMsg("MSG_VISIT_HOUSE_FAILED")
    self:hookMsg("MSG_HOUSE_SHOW_FARM_DATA")
    self:hookMsg("MSG_TRADING_HOUSE_DATA")
end

-- 设置居所数据
function JuBaoUserViewHomeDlg:setHomeInfo(data)
    -- 类型
    self:setLabelText("TitleLabel_1", HomeMgr:getHomeTypeCHS(data.house_type), "TitlePanel")
    
    self:setImage("HouseImage", HOME_ICON[data.house_type])
    
    -- 舒适度
    self:setLabelText("TimeLabel_1", data.comfort, "ComfortPanel")
    
    if self.lifeLevel then
        
        -- 种植等级
        local plant_level = self.lifeLevel.plant_level or 1
        plant_level = plant_level == 0 and 1 or plant_level
        self:setLabelText("TimeLabel_1", plant_level .. CHS[7002280], "PlantPanel")
        
        -- 钓鱼等级
        local fish_level = self.lifeLevel.fish_level or 1
        fish_level = fish_level == 0 and 1 or fish_level
        self:setLabelText("TimeLabel_1", fish_level .. CHS[7002280], "FishPanel")
    end
    
    -- 空间方案
    self:setLabelText("TimeLabel_1", data.total_space .. "/" .. data.max_space, "SpacePanel")
    self:setLabelText("WosLabel_2", HomeMgr:getLevelStr(data.wos_level), "WosPanel")
    self:setLabelText("WosLabel_2", HomeMgr:getLevelStr(data.chuws_level), "ChuwsPanel")
    self:setLabelText("WosLabel_2", HomeMgr:getLevelStr(data.xiuls_level), "XiulsPanel")
    self:setLabelText("WosLabel_2", HomeMgr:getLevelStr(data.lianqs_level), "LianqsPanel")
    
    
    self:setLabelText("TimeLabel_1", (data.guanjia_count + data.yahuan_count) .. "/" .. (2 + HomeMgr:getHomeMaidNumLimitByType(data.house_type)), "HirePanel")
    -- 雇佣管家
    if data.guanjia_count > 0 then
        self:setLabelText("WosLabel_2", data.guanjia_names[1] or "", "GuanjPanel_1")
        self:setLabelText("WosLabel_2", data.guanjia_names[2] or "", "GuanjPanel_2")
    else
        self:setLabelText("WosLabel_2", CHS[7002255], "GuanjPanel_1")
        self:setLabelText("WosLabel_2", CHS[7002255], "GuanjPanel_2")
    end
    
    -- 雇佣丫鬟
    if data.yahuan_count > 0 then
        self:setLabelText("WosLabel_2", data.yahuan_names[1] or CHS[7002255], "YahPanel_1")
        self:setLabelText("WosLabel_2", data.yahuan_names[2] or CHS[7002255], "YahPanel_2")
    else
        self:setLabelText("WosLabel_2", CHS[7002255], "YahPanel_1")
        self:setLabelText("WosLabel_2", CHS[7002255], "YahPanel_2")
    end
end

-- 设置孩子数据
function JuBaoUserViewHomeDlg:setChildInfo(panel, data, updateLabelFlag)
    if updateLabelFlag then
        self:setLabelText("BKLabel", string.format(CHS[7120232], #data), panel)
    end

    local function setSingleChildInfo(root, info)
        self:setCtrlVisible("ChosenImage", false, root)
        self:setImage("GoodsImage", HomeChildMgr:getChildSmallPortrait(info), root)
        self:setImageSize("GoodsImage", {width = 64, height = 64}, root)

        if info.stage == HomeChildMgr.CHILD_TYPE.FETUS then
            self:setLabelText("NameLabel", CHS[7120227], root)
        elseif info.stage == HomeChildMgr.CHILD_TYPE.STONE then
            self:setLabelText("NameLabel", CHS[7120228], root)
        else
            self:setLabelText("NameLabel", info.name, root)
        end

        root.cid = info.child_id

        root:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if sender.cid then
                    HomeChildMgr:requestChildCard(sender.cid)
                end
            end
        end)
    end

    for i = 1, 3 do
        local childPanel = self:getControl("PetInfoPanel_" .. i, nil, panel)
        local childInfo = data[i]
        if childInfo then
            childPanel:setVisible(true)
            setSingleChildInfo(childPanel, childInfo)
        else
            childPanel:setVisible(false)
        end
    end
end

function JuBaoUserViewHomeDlg:onNoteButton(sender, eventType)    
    gf:showTipInfo(CHS[4100945], sender)
end

function JuBaoUserViewHomeDlg:onBuyButton(sender, eventType)
    if not self.goods_gid then return end
    TradingMgr:tryBuyItem(self.goods_gid, self.name)
end

function JuBaoUserViewHomeDlg:onCloseButton(sender, eventType)
    TradingMgr:cleanAutoLoginInfo()
    DlgMgr:closeDlg(self.name)
end

function JuBaoUserViewHomeDlg:MSG_TRADING_HOUSE_DATA(data)
    self:setHomeInfo(data)
end

return JuBaoUserViewHomeDlg
