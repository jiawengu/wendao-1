-- ShengSiDetailsDlg.lua
-- Created by huangzz Apr/28/2018
-- 生死状-对决详情界面

local ShengSiDetailsDlg = Singleton("ShengSiDetailsDlg", Dialog)

local ICON_MAP = {
    [6001] = ResMgr.ui.watch_centre_tag1, [7001] = ResMgr.ui.watch_centre_tag6, -- 金
    [6002] = ResMgr.ui.watch_centre_tag2, [7002] = ResMgr.ui.watch_centre_tag7, -- 木
    [7003] = ResMgr.ui.watch_centre_tag3, [6003] = ResMgr.ui.watch_centre_tag8, -- 水
    [7004] = ResMgr.ui.watch_centre_tag4, [6004] = ResMgr.ui.watch_centre_tag9, -- 水
    [7005] = ResMgr.ui.watch_centre_tag5, [6005] = ResMgr.ui.watch_centre_tag10, -- 水
}


function ShengSiDetailsDlg:init()
end

-- 设置界面数据
function ShengSiDetailsDlg:setData(data)
    self:setRightInfo(data)

    self:setLeftInfo(data)
end

-- 设置界面左侧比赛信息
function ShengSiDetailsDlg:setLeftInfo(data)
    -- 阵容
    local teamPanel1 = self:getControl("TeamPanel1")
    local teamPanel2 = self:getControl("TeamPanel2")

    teamPanel1.data = data.att_members
    teamPanel2.data = data.def_members

    if data.result == "atk" then
        -- 攻击方赢
        self:setImagePlist("ResultImage", ResMgr.ui.party_war_win, teamPanel1)
        self:setImagePlist("ResultImage", ResMgr.ui.party_war_lose, teamPanel2)
    elseif data.result == "def" or data.result == "draw" then
        -- 防御方赢
        self:setImagePlist("ResultImage", ResMgr.ui.party_war_lose, teamPanel1)
        self:setImagePlist("ResultImage", ResMgr.ui.party_war_win, teamPanel2)
    else
        -- 都输
        self:setImagePlist("ResultImage", ResMgr.ui.party_war_lose, teamPanel1)
        self:setImagePlist("ResultImage", ResMgr.ui.party_war_lose, teamPanel2)
    end

    for i = 1, 5 do
        local shapePanel1 = self:getControl("TeamerPanel" .. i, nil, teamPanel1)
        local shapePanel2 = self:getControl("TeamerPanel" .. i, nil, teamPanel2)

        self:setMemberInfo(data.att_members[i], shapePanel1, 1)

        -- 单人不显示队长标识
        if data.att_count == 1 then
            self:setCtrlVisible("LeaderImage", false, shapePanel1)
            self:setCtrlVisible("NameBkImage", false, shapePanel1)
        end

        local num = 5 - i + 1
        self:setMemberInfo(data.def_members[num], shapePanel2, 2)

        if num ~= 1 or data.def_count == 1 then
            self:setCtrlVisible("LeaderImage", false, shapePanel2)
            self:setCtrlVisible("NameBkImage", false, shapePanel2)
        end
    end
end

function ShengSiDetailsDlg:setMemberInfo(data, cell, type)
    if data then
        self:setImage("HeadImage", ICON_MAP[data.icon], cell)

        self:setLabelText("PartyLabel", "", cell)

        self:setLabelText("NameLabel", data.name, cell)

        if type == 1 then
            self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 17, cell)
        else
            self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.RIGHT_TOP, 17, cell)
        end
    else
        self:setImagePlist("HeadImage", ResMgr.ui.touming, cell)
        self:setLabelText("PartyLabel", "", cell)
        self:setLabelText("NameLabel", "", cell)
        self:removeNumImgForPanel("LevelPanel", LOCATE_POSITION.RIGHT_TOP, cell)
        self:setCtrlVisible("LeaderImage", false, cell)
        self:setCtrlVisible("NameBkImage", false, cell)
    end
end

-- 设置界面右侧比赛信息
function ShengSiDetailsDlg:setRightInfo(data)
     -- 模式
    self:setLabelText("Label", data.mode, "TypePanel")

    -- 对决是时间
    self:setLabelText("Label", gf:getServerDate("%m-%d %H:%M", data.time), "TimePanel")

    -- 赌注
    self:setCtrlVisible("CoinImage", false, "BetPanel")
    self:setCtrlVisible("CashImage", false, "BetPanel")
    if data.bet_type == "cash" then
        self:setCtrlVisible("CashImage", true, "BetPanel")
    elseif data.bet_type == "coin" then
        self:setCtrlVisible("CoinImage", true, "BetPanel")
    end

    local cashText, fontColor = gf:getArtFontMoneyDesc(data.bet_num)
    self:setNumImgForPanel("NumPanel", fontColor, cashText, false, LOCATE_POSITION.MID, 21)
end

return ShengSiDetailsDlg
