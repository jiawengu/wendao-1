-- TradingSpotRankDlg.lua
-- Created by lixh Des/26/2018
-- 商贾货站十大巨商界面

local TradingSpotRankDlg = Singleton("TradingSpotRankDlg", Dialog)
local Bitset = require("core/Bitset")

function TradingSpotRankDlg:init()
    self:bindListViewListener("ItemsListView", self.onSelectItemsListView)
    
    self.listView = self:getControl("ItemsListView")
    self.selectEffect = self:retainCtrl("SChosenEffectImage")
    self.itemPanel = self:retainCtrl("ItemsUnitPanel")

    self:createShareButton(self:getControl("ShareButton", nil, "MyProfitPanel"), SHARE_FLAG.TRADINGSPOTRANK)

    self:hookMsg("MSG_FIND_CHAR_MENU_FAIL")
    self:hookMsg("MSG_CHAR_INFO")
end

function TradingSpotRankDlg:setData(data)
    local meRank = 0
    local meGid = Me:queryBasic("gid") 
    if data.count > 0 then
        self.listView:setVisible(true)
        self:setCtrlVisible("NoticePanel", false)

        self.listView:removeAllItems()

        for i = 1, data.count do
            local item = self.itemPanel:clone()
            data.list[i].rank = i
            self:setSingleItemInfo(item, data.list[i])

            self:setCtrlVisible("BackImage1", i % 2 ~= 0, item)
            self:setCtrlVisible("BackImage2", i % 2 == 0, item)

            self.listView:pushBackCustomItem(item)

            if data.list[i].char_gid == meGid then
                meRank = data.list[i].rank
            end
        end
    else
        self.listView:setVisible(false)
        self:setCtrlVisible("NoticePanel", true)
    end

    -- Me的数据
    local panel = self:getControl("MyProfitPanel")
    self:setLabelText("NameLabel", Me:getName(), panel)
    self:setLabelText("LevelLabel", Me:getLevel(), panel)
    self:setLabelText("MenpaiLabel", gf:getPolar(Me:queryBasicInt('polar')), panel)
    local profitStr, profitColor = TradingSpotMgr:getProfitTextInfo(tonumber(data.me_profit))
    self:setLabelText("ProfitNumLabel", profitStr, panel, profitColor)
    if meRank > 0 then
        self:setLabelText("RankLabel", meRank, panel)
    else
        self:setLabelText("RankLabel", CHS[7190489], panel)
    end
end

function TradingSpotRankDlg:setSingleItemInfo(panel, info)
    -- 排名
    self:setLabelText("RankLabel", info.rank, panel)

    -- 名称
    self:setLabelText("NameLabel", info.char_name, panel)

    -- 等级
    self:setLabelText("LevelLabel", info.level, panel)

    -- 门派
    self:setLabelText("MenpaiLabel", gf:getPolar(info.polar), panel)

    -- 盈利
    local profitStr, profitColor = TradingSpotMgr:getProfitTextInfo(tonumber(info.sum_profit))
    self:setLabelText("ProfitNumLabel", profitStr, panel, profitColor)

    panel.info = info
end

-- 设置选中
function TradingSpotRankDlg:setSelectItem(panel)
    if self.selectEffect:getParent() then
        self.selectEffect:removeFromParent()
    end

    panel:addChild(self.selectEffect)

    -- 点击自己不弹菜单
    if panel.info.char_gid == Me:queryBasic("gid") then return end

    self.menuInfo = { CHS[3000056], CHS[3000057] }
    if not (FriendMgr:isBlackByGId(panel.info.char_gid) or FriendMgr:hasFriend(panel.info.char_gid)) then
        -- 不在黑名单中也不在好友列表中，添加“加为好友”菜单项
        table.insert(self.menuInfo, CHS[3000058])
    end

    table.insert(self.menuInfo, CHS[5400270])

    self.menuInfo.name = panel.info.char_name
    self.menuInfo.gid = panel.info.char_gid
    self.menuInfo.icon = panel.info.icon
    self.menuInfo.level = panel.info.level

    -- 弹出菜单
    self:popupMenus(self.menuInfo)
end

-- 设置点击查看好友菜单
function TradingSpotRankDlg:onClickMenu(idx)
    if not self.menuInfo then return end

    local menu = self.menuInfo[idx]
    if menu == CHS[3000056] then
        -- 查看装备
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_LOOK_PLAYER_EQUIP, self.menuInfo.gid)
    elseif menu == CHS[3000057] then
        -- 交流
        FriendMgr:communicat(self.menuInfo.name, self.menuInfo.gid, self.menuInfo.icon, self.menuInfo.level)
        self.menuInfo = nil
    elseif menu == CHS[3000058] then
        -- 发送数据请求
        FriendMgr:requestCharMenuInfo(self.menuInfo.gid)
        return
    elseif menu == CHS[5400270] then
        -- 查看空间
        BlogMgr:openBlog(self.menuInfo.gid)
    end

    self:closeMenuDlg()
end

function TradingSpotRankDlg:cleanup()
    self.menuInfo = nil
end

function TradingSpotRankDlg:onSelectItemsListView(sender, eventType)
    local item = self:getListViewSelectedItem(sender)
    if not item then return end

    -- 选中
    self:setSelectItem(item)
end

function TradingSpotRankDlg:MSG_CHAR_INFO(data)
    if not self.menuInfo then return end
    if self.menuInfo.gid ~= data.gid then return end

    self:closeMenuDlg()

    -- 尝试加为好友
    FriendMgr:tryToAddFriend(data.name, data.gid, Bitset.new(data.setting_flag))
    self.menuInfo = nil
end

function TradingSpotRankDlg:MSG_FIND_CHAR_MENU_FAIL(data)
    if not self.menuInfo then return end
    if self.menuInfo.gid ~= data.char_id then return end

    self:closeMenuDlg()

    gf:ShowSmallTips(string.format(CHS[5400576], self.menuInfo.name))
    self.menuInfo = nil
end

return TradingSpotRankDlg
