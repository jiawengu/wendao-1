-- WatchCentreDlg.lua
-- Created by songcw Feb/07/2017
-- 观战中心 - 赛事详情界面

local WatchCentreDetailsDlg = Singleton("WatchCentreDetailsDlg", Dialog)

local json = require('json')

local COST_CASH = 100000


local ICON_MAP = {
    [6001] = ResMgr.ui.watch_centre_tag1, [7001] = ResMgr.ui.watch_centre_tag6, -- 金    
    [6002] = ResMgr.ui.watch_centre_tag2, [7002] = ResMgr.ui.watch_centre_tag7, -- 木    
    [7003] = ResMgr.ui.watch_centre_tag3, [6003] = ResMgr.ui.watch_centre_tag8, -- 水
    [7004] = ResMgr.ui.watch_centre_tag4, [6004] = ResMgr.ui.watch_centre_tag9, -- 水
    [7005] = ResMgr.ui.watch_centre_tag5, [6005] = ResMgr.ui.watch_centre_tag10, -- 水
}

function WatchCentreDetailsDlg:init()
    self:bindListener("PlayButton", self.onPlayButton)    
    self:bindListener("Collection1", self.onCollection2)
    self:bindListener("Collection2", self.onCollection1)
    
    self.combat_id = nil
    self.combat_play_type = nil
end

-- 设置界面数据
function WatchCentreDetailsDlg:setData(data)   
    self.combat_id = data.combat_id
    self.combat_play_type = data.combat_play_type
    self.combat_type = data.combat_type

    self:setRightInfo(data)
    
    self:setLeftInfo(data)
    
    
    if data.combat_play_type == 1 then
        -- 直播
        self:setCtrlVisible("Collection1", false)
        self:setCtrlVisible("Collection2", false)
    else    
        if WatchCenterMgr:isCollected(data.combat_id) then
            self:setCtrlVisible("Collection1", true)
            self:setCtrlVisible("Collection2", false)
        else
            self:setCtrlVisible("Collection1", false)
            self:setCtrlVisible("Collection2", true)
        end
    end
end

-- 设置界面左侧比赛信息
function WatchCentreDetailsDlg:setLeftInfo(data)    
    self:setImage("PlayNumImage", WatchCenterMgr:getWatchIconForPlayType(data.combat_play_type))
    
    -- 对阵    
    if data.att_dist == "" then
        -- 旧数据
        self:setLabelText("MatchAgainstLabel1", data.att_name)
        self:setLabelText("MatchAgainstLabel2", data.def_name)
    else
        self:setLabelText("MatchAgainstLabel1", data.att_dist .. "-" .. data.att_name)
        self:setLabelText("MatchAgainstLabel2", data.def_name .. "-" .. data.def_dist)
    end
    
    -- 阵容
    local teamPanel1 = self:getControl("TeamPanel1")
    local teamPanel2 = self:getControl("TeamPanel2")
    
    teamPanel1.data = data.att
    teamPanel2.data = data.def
    
    if data.combat_play_type == 1 then
        -- 直播不显示
        self:setImagePlist("ResultImage", ResMgr.ui.touming, teamPanel1)
        self:setImagePlist("ResultImage", ResMgr.ui.touming, teamPanel2)
    elseif not data.result or data.result == 0 then
        -- 无结果   或者旧数据
        self:setImagePlist("ResultImage", ResMgr.ui.touming, teamPanel1)
        self:setImagePlist("ResultImage", ResMgr.ui.touming, teamPanel2)
    elseif data.result == 1 then
        -- 攻击方赢
        self:setImagePlist("ResultImage", ResMgr.ui.party_war_win, teamPanel1)
        self:setImagePlist("ResultImage", ResMgr.ui.party_war_lose, teamPanel2)
    elseif data.result == 2 then
        -- 防御方赢
        self:setImagePlist("ResultImage", ResMgr.ui.party_war_lose, teamPanel1)
        self:setImagePlist("ResultImage", ResMgr.ui.party_war_win, teamPanel2)
    elseif data.result == 3 then
        -- 平局
        self:setImagePlist("ResultImage", ResMgr.ui.party_war_draw, teamPanel1)
        self:setImagePlist("ResultImage", ResMgr.ui.party_war_draw, teamPanel2)
    end
    
    self:bindTouchEndEventListener(teamPanel1, self.onSelectTeam)
    self:bindTouchEndEventListener(teamPanel2, self.onSelectTeam)
    
    for i = 1, 5 do       
        local shapePanel1 = self:getControl("TeamerPanel" .. i, nil, teamPanel1)
        local shapePanel2 = self:getControl("TeamerPanel" .. i, nil, teamPanel2)
        
        if data.att[i] then
            self:setImage("HeadImage", ICON_MAP[data.att[i].icon], shapePanel1)
            
            if data.combat_type == CHS[3000217] then
                self:setLabelText("PartyLabel", data.att[i].party, shapePanel1)
            else
                self:setLabelText("PartyLabel", "", shapePanel1)
            end

            self:setLabelText("NameLabel", data.att[i].name, shapePanel1)
            self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, data.att[i].level, false, LOCATE_POSITION.LEFT_TOP, 17, shapePanel1)
        else
            self:setImagePlist("HeadImage", ResMgr.ui.touming, shapePanel1) 
            self:setLabelText("PartyLabel", "", shapePanel1)
            self:setLabelText("NameLabel", "", shapePanel1)      
            self:removeNumImgForPanel("LevelPanel", LOCATE_POSITION.LEFT_TOP, shapePanel1)
            self:setCtrlVisible("LeaderImage", false, shapePanel1)
            self:setCtrlVisible("NameBkImage", false, shapePanel1)
        end

        -- WDSY-29163 固定右边最后一个显示队长
        local num = 6 - i
        if data.def[num] then
            self:setImage("HeadImage", ICON_MAP[data.def[num].icon], shapePanel2) 
            
            if data.combat_type == CHS[3000217] then
                self:setLabelText("PartyLabel", data.def[num].party, shapePanel2)
            else
                self:setLabelText("PartyLabel", "", shapePanel2)
            end
            self:setLabelText("NameLabel", data.def[num].name, shapePanel2)      
            self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, data.def[num].level, false, LOCATE_POSITION.RIGHT_TOP, 17, shapePanel2)
            
            if num == 1 then
                self:setCtrlVisible("LeaderImage", true, shapePanel2)
                self:setCtrlVisible("NameBkImage", true, shapePanel2)
            else
                self:setCtrlVisible("LeaderImage", false, shapePanel2)
                self:setCtrlVisible("NameBkImage", false, shapePanel2)
            end
        else
            self:setImagePlist("HeadImage", ResMgr.ui.touming, shapePanel2) 
            self:setLabelText("PartyLabel", "", shapePanel2)
            self:setLabelText("NameLabel", "", shapePanel2)      
            self:removeNumImgForPanel("LevelPanel", LOCATE_POSITION.RIGHT_TOP, shapePanel2)
            self:setCtrlVisible("LeaderImage", false, shapePanel2)
            self:setCtrlVisible("NameBkImage", false, shapePanel2)
        end
    end    
end

-- 点击某个战斗
function WatchCentreDetailsDlg:onSelectTeam(sender, eventType)
--[[
    local data = sender.data
    local dlg = DlgMgr:openDlg("WatchCentreTeamDlg")
    dlg:setData(data)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    dlg:setFloatingFramePos(rect)
    --]]
end

-- 设置界面右侧比赛信息
function WatchCentreDetailsDlg:setRightInfo(data)    
    local cell = self:getControl("MatchPanel")

    -- 比赛类型
    if data.combat_play_type == 1 then
        self:setLabelText("MatchTypeLabel", CHS[4100447], cell)
    else
        self:setLabelText("MatchTypeLabel", CHS[4100448], cell)
    end

    local icon, warName = WatchCenterMgr:getWatchIconAndName(data.combat_type)
    self:setImage("MatchImage", icon, cell)

    -- 时间
    self:setLabelText("TimeLabel", gf:getServerDate("%Y-%m-%d %H:%M", data.start_time), cell)

    -- 比赛玩家
    self:setLabelText("PlayerNameLabel1", gf:getRealName(data.att_name), cell)
    self:setLabelText("PlayerNameLabel2", gf:getRealName(data.def_name), cell)

    -- 观看次数
    self:setLabelText("NumLabel", data.view_times, cell)

    -- 回合数
    if data.combat_play_type == 1 then
        self:setLabelText("RoundLabel", "", cell)
    else
        self:setLabelText("RoundLabel", data.total_round .. CHS[4100449], cell)
    end

    -- 比赛名称
    self:setLabelText("MatchNameLabel", data.combat_type, cell)

    local cashText, fontColor = gf:getArtFontMoneyDesc(self:getCost())
    self:setNumImgForPanel("MoneyPanel", fontColor, cashText, false, LOCATE_POSITION.LEFT_TOP, 23)

    local showFree = WatchCenterMgr:isFreeToWatch(data.combat_type)
    self:setCtrlVisible("FreeLabel", showFree, "MainPanel")
    self:setCtrlVisible("CashLabel1", not showFree, "MainPanel")
    self:setCtrlVisible("MoneyImage", not showFree, "MainPanel")
    self:setCtrlVisible("MoneyPanel", not showFree, "MainPanel")
    self:setCtrlVisible("CashLabel2", not showFree, "MainPanel")
end

-- 计算观战花费
function WatchCentreDetailsDlg:getCost()
    if WatchCenterMgr:isFreeToWatch(self.combat_type) then
        return 0
    else
        -- 手续费受神算子占卜任务影响
        return COST_CASH * TaskMgr:getNumerologyEffect(NUMEROLOGY.STICK_WFQ_CY_GZZX)
    end
end

function WatchCentreDetailsDlg:onPlayButton(sender, eventType)
    if not GMMgr:isGM() then    
        if not gf:checkHasEnoughMoney(self:getCost()) then
            return
        end
    end

    WatchCenterMgr:lookOnWatchCombatById(self.combat_id, self.combat_play_type)    
    self:onCloseButton()
 --   DlgMgr:closeDlg("WatchCentreDlg")
end

-- 收藏
function WatchCentreDetailsDlg:onCollection1(sender, eventType)
    if not self.combat_id then return end
    
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    elseif GameMgr.inCombat then
        gf:ShowSmallTips(CHS[3002257])
        return
    end
    
    if WatchCenterMgr:addCollectionCombat(self.combat_id) then    
        sender:setVisible(false)
        self:setCtrlVisible("Collection1", true)
        gf:ShowSmallTips(CHS[4300220])
        
        DlgMgr:sendMsg("WatchCentreDlg", "onSelectMenuByName", CHS[4300219])
    end
end

-- 取消收藏
function WatchCentreDetailsDlg:onCollection2(sender, eventType)
    if not self.combat_id then return end    
    
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    elseif GameMgr.inCombat then
        gf:ShowSmallTips(CHS[3002257])
        return
    end
    
    WatchCenterMgr:removeCollectionsCombats(self.combat_id)
    gf:ShowSmallTips(CHS[4300221])
    DlgMgr:sendMsg("WatchCentreDlg", "onSelectMenuByName", CHS[4300219])
    sender:setVisible(false)
    self:setCtrlVisible("Collection2", true)
end

return WatchCentreDetailsDlg
