-- PartyWarScheduleDlg.lua
-- Created by liuhb Apr/7/2015
-- 帮战赛程

local RadioGroup = require("ctrl/RadioGroup")
local PartyWarScheduleDlg = Singleton("PartyWarScheduleDlg", Dialog)

local ZONE_LIST = {
    "ZoneACheckBox",
    "ZoneBCheckBox",
    "ZoneCCheckBox",
}

local GROUP_LIST = {
    "GroupACheckBox",
    "GroupBCheckBox",
    "KnockoutCheckBox",
}

-- 小组赛
local COMP_GROUP = {
    ["A"] = 1,            -- A组
    ["B"] = 2,            -- B组
    [""]  = 3,            -- 淘汰赛
}

-- 名字对应的区域编号
local ZONE_CHECK_BOX_MAP = {
    ["ZoneACheckBox"] = COMP_ZONE.A,
    ["ZoneBCheckBox"] = COMP_ZONE.B,
    ["ZoneCCheckBox"] = COMP_ZONE.C,
}

-- 小组对应的组别编号
local GROUP_CHECK_BOX_MAP = {
    ["GroupACheckBox"] = "A",
    ["GroupBCheckBox"] = "B",
    ["KnockoutCheckBox"] = "",
}

local KNOCK_CTRL_LIST = {
    [COMP_STAGE.KNOCKOUT_1] = {"FristTimeLabel", "FristFristPartyLabel", "FristSecondPartyLabel", "FristResultLabel", CHS[3003297], CHS[3003298]},  -- A组第一名 B组第二名
    [COMP_STAGE.KNOCKOUT_2] = {"SecondTimeLabel", "SecondFristPartyLabel", "SecondSecondPartyLabel", "SecondResultLabel", CHS[3003299], CHS[3003300]},
    [COMP_STAGE.KNOCKOUT_3] = {"ThridTimeLabel", "ThridFristPartyLabel", "ThridSecondPartyLabel", "ThridResultLabel", CHS[3003301], CHS[3003302]},
    [COMP_STAGE.KNOCKOUT_4] = {"FinalsTimeLabel", "FinalsFristPartyLabel", "FinalsSecondPartyLabel", "FinalsResultLabel", CHS[3003303], CHS[3003304]},
}

function PartyWarScheduleDlg:init()
    self:bindListener("ZoneButton", self.onZoneButton)
    self:bindListener("ScheduleButton", self.onScheduleButton)
    self:bindListener("BKPanel", self.onCloseFloat)

    for i = 1,3 do
        self:bindListener(ZONE_LIST[i], self.onZoneButtonIndex)
        self:bindListener(GROUP_LIST[i], self.onScheduleButtonIndex)
    end

  --  self:defaultSelect()

    -- 设置赛区可点击性
    self:setZoneEnable()
end

function PartyWarScheduleDlg:getMyParty()
    local myZone, myGroup
    local isInKnockOut

    for i = 1, #ZONE_LIST do

        local zone = ZONE_CHECK_BOX_MAP[ZONE_LIST[i]]

        for j = 1, #GROUP_LIST do
            local group = GROUP_CHECK_BOX_MAP[GROUP_LIST[j]]
            local warInfo = PartyWarMgr:getCompetitionInfo(zone, group)

            if group == "" then
                -- 淘汰赛
                warInfo =  PartyWarMgr:getKnockoutInfo(zone)
                if warInfo then
                    for n = 1, #warInfo do
                        local tempInfo = warInfo[n]
                        --
                        if (tempInfo.defenser == Me:queryBasic("party") or tempInfo.attacker == Me:queryBasic("party")) and Me:queryBasic("party") ~= "" and not myZone then
                            myZone = ZONE_LIST[i]

                        end


                        if tempInfo and tempInfo.time and tonumber(tempInfo.time) then
                            if gf:getServerTime() >= tonumber(tempInfo.time) and ZONE_LIST[i] == myZone then
                                isInKnockOut = true
                            end
                        end
                    end
                end
            else
                -- 小组赛
                if warInfo and warInfo.partysInfo then
                    for n = 1, #warInfo.partysInfo do
                        if warInfo.partysInfo[n].partyName == Me:queryBasic("party") and Me:queryBasic("party") ~= "" then
                            myZone = ZONE_LIST[i]
                            myGroup = GROUP_LIST[j]
                        end
                    end
                end
            end


        end
    end

    return myZone, myGroup, isInKnockOut
end

function PartyWarScheduleDlg:defaultSelect()
    local myZone, myGroup, isInKnockOut = self:getMyParty() -- 获取我所在的
    if myZone then
        -- 所在的赛区，即我帮派有参加
        self.zoneName = myZone

        if not self:getDefaultGroup() then
            -- 没有小组赛
            self:onScheduleButtonIndex(self:getControl("KnockoutCheckBox"))
        else
            -- 有小组赛
            if isInKnockOut then
                -- 淘汰赛进行中
                self:onScheduleButtonIndex(self:getControl("KnockoutCheckBox"))
            else
                -- 小组赛
                if not myGroup then myGroup = "GroupACheckBox" end
                self.groupName = myGroup
                self:onScheduleButtonIndex(self:getControl(myGroup))
            end
        end
    else
        -- 我的帮派没有参加

        -- A赛区小组赛A
        self.zoneName = "ZoneACheckBox"
        if self:getDefaultGroup() then
            -- 有小组赛
            local isKnockouting = false
            local knoDatat = PartyWarMgr:getKnockoutInfo(ZONE_CHECK_BOX_MAP[self.zoneName])
            if knoDatat and #knoDatat ~= 0 then
                for j = 1, #knoDatat do
                    if knoDatat[j] and gf:getServerTime() >= tonumber(knoDatat[j].time) then
                        -- 淘汰赛开始了
                        isKnockouting = true
                    end
                end

                if isKnockouting then
                    self:onScheduleButtonIndex(self:getControl("KnockoutCheckBox"))
                else
                    self.groupName = "GroupACheckBox"
                    self:onScheduleButtonIndex(self:getControl("GroupACheckBox"))
                end
            else
                self.groupName = "GroupACheckBox"
                self:onScheduleButtonIndex(self:getControl("GroupACheckBox"))
            end
        else
            -- 每小组赛
            self:onScheduleButtonIndex(self:getControl("KnockoutCheckBox"))
        end
    end

    local btnName = {
        ["ZoneACheckBox"] = CHS[3003305],
        ["ZoneBCheckBox"] = CHS[3003306],
        ["ZoneCCheckBox"] = CHS[3003307]
    }
    self:setButtonText("ZoneButton", btnName[self.zoneName])
end

function PartyWarScheduleDlg:setZoneEnable()
    local zones = PartyWarMgr:getZoneList()
    for i = 1, #ZONE_LIST do
        local ctrl = self:getControl(ZONE_LIST[i])
        local flag = false
        for j = 1, #zones do
            if ZONE_CHECK_BOX_MAP[ZONE_LIST[i]] == zones[j] then
                flag = true
            end
        end

        if flag then
            -- 有这个赛区，开放
            ctrl:setTouchEnabled(true)
            gf:resetImageView(ctrl)
        else
            -- 没有这个赛区，不开放
            ctrl:setTouchEnabled(false)
            gf:grayImageView(ctrl)
        end
    end
end

function PartyWarScheduleDlg:onCloseFloat(sender, eventType)
    local btn = self:getControl("ZoneButton")
    self:setCtrlVisible("ExpandImage", true, btn)
    self:setCtrlVisible("ShrinkImage", false, btn)
    self:setCtrlVisible("ZonePanel", false)

    btn = self:getControl("ScheduleButton")
    self:setCtrlVisible("ExpandImage", true, btn)
    self:setCtrlVisible("ShrinkImage", false, btn)
    self:setCtrlVisible("SchedulePanel", false)
end

-- 点击赛区按钮
function PartyWarScheduleDlg:onZoneButton(sender, eventType)
    if self:getCtrlVisible("ZonePanel") then
        self:setCtrlVisible("ExpandImage", true, sender)
        self:setCtrlVisible("ShrinkImage", false, sender)

        self:setCtrlVisible("ZonePanel", false)
    else
        self:setCtrlVisible("ExpandImage", false, sender)
        self:setCtrlVisible("ShrinkImage", true, sender)

        self:setCtrlVisible("ZonePanel", true)
    end

    local btn = self:getControl("ScheduleButton")
    self:setCtrlVisible("ExpandImage", true, btn)
    self:setCtrlVisible("ShrinkImage", false, btn)
    self:setCtrlVisible("SchedulePanel", false)
end

-- 点击小组按钮
function PartyWarScheduleDlg:onScheduleButton(sender, eventType)
    if self:getCtrlVisible("SchedulePanel") then
        self:setCtrlVisible("ExpandImage", true, sender)
        self:setCtrlVisible("ShrinkImage", false, sender)

        self:setCtrlVisible("SchedulePanel", false)
    else
        self:setCtrlVisible("ExpandImage", false, sender)
        self:setCtrlVisible("ShrinkImage", true, sender)

        self:setCtrlVisible("SchedulePanel", true)
    end

    local btn = self:getControl("ZoneButton")
    self:setCtrlVisible("ExpandImage", true, btn)
    self:setCtrlVisible("ShrinkImage", false, btn)
    self:setCtrlVisible("ZonePanel", false)
end

-- 点击赛区N按钮
function PartyWarScheduleDlg:onZoneButtonIndex(sender, eventType)
    local btnName = {
        ["ZoneACheckBox"] = CHS[3003305],
        ["ZoneBCheckBox"] = CHS[3003306],
        ["ZoneCCheckBox"] = CHS[3003307]
    }

    self.zoneName = sender:getName()
    self:selectCheckBox()
    self:setButtonText("ZoneButton", btnName[sender:getName()])
    self:onCloseFloat()

    if self:getDefaultGroup(self.groupName) then
        self:onScheduleButtonIndex(self:getControl(self.groupName))
    else
        self:onScheduleButtonIndex(self:getControl("KnockoutCheckBox"))
    end
end

-- 点击小组赛N按钮
function PartyWarScheduleDlg:onScheduleButtonIndex(sender, eventType)
    local btnName = {
        ["GroupACheckBox"] = CHS[3003308],
        ["GroupBCheckBox"] = CHS[3003309],
        ["KnockoutCheckBox"] = CHS[3003310]
    }

    local info = PartyWarMgr:getCompetitionInfo(ZONE_CHECK_BOX_MAP[self.zoneName], GROUP_CHECK_BOX_MAP[sender:getName()])
    if nil == info then return end
    local partysInfo = info.partysInfo
    if sender:getName() ~= "KnockoutCheckBox" and (not partysInfo or not next(partysInfo)) then
        gf:ShowSmallTips(CHS[4100782])
        self:onCloseFloat()
        return
    end

    self.groupName = sender:getName()
    self:selectCheckBox()
    self:setButtonText("ScheduleButton", btnName[sender:getName()])
    self:onCloseFloat()
end

-- checkBox点击回调
function PartyWarScheduleDlg:selectCheckBox(sender, eventType)
    local groupName = self.groupName
    local zoneName = self.zoneName

    if "" ~= GROUP_CHECK_BOX_MAP[groupName] then
        -- 显示小组赛
        self:setDetalInfo(ZONE_CHECK_BOX_MAP[zoneName], GROUP_CHECK_BOX_MAP[groupName])
    else
        -- 显示淘汰赛
        self:setKnockOutInfo(ZONE_CHECK_BOX_MAP[zoneName])
    end

    self:getControl("GroupPanel"):setVisible(GROUP_CHECK_BOX_MAP[groupName] ~= "")
    self:getControl("KnockoutPanel"):setVisible(GROUP_CHECK_BOX_MAP[groupName] == "")
end

-- 获取当前选择显示的界面
function PartyWarScheduleDlg:getCurrentSelect()
    return {zone = self.zone, group = self.group}
end

function PartyWarScheduleDlg:setLunkongDisplay(info, panel, timeLabelName)
    self:setCtrlVisible("LunkongPanel", true, panel)
    self:setCtrlVisible("TwoLunkongLabel", false, panel)
    self:setCtrlVisible("TwoLunkongLabel2", false, panel)
    self:setCtrlVisible("OneLunkongLabel", false, panel)
    self:setLabelText("OnePartyLabel", "", panel)
    self:setCtrlVisible("VictoryImage", false, panel)

    if info.time == "" then
        -- 没有时间，显示轮空
        self:setCtrlVisible("TwoLunkongLabel2", true, panel)
        return true
    else
        -- 有时间，服务器下发lunkong
        if info.result == "lunkong" then
            if info.attacker == "" and info.defenser == "" then
                self:setCtrlVisible("TwoLunkongLabel", true, panel)
                self:setLabelText(timeLabelName, gf:getServerDate("%m-%d %H:%M", tonumber(info.time)))
                return true
            else
            -- 单方轮空
                self:setCtrlVisible("OneLunkongLabel", true, panel)
                self:setCtrlVisible("VictoryImage", true, panel)
                local partyName = info.attacker
                if partyName == "" then partyName = info.defenser end

                self:setCtrlVisible("OnePartyLabel", true, panel)
                self:setLabelText("OnePartyLabel", partyName, panel)
                self:setLabelText(timeLabelName, gf:getServerDate("%m-%d %H:%M", tonumber(info.time)))
                return true
            end
        end
    end

    self:setCtrlVisible("LunkongPanel", false, panel)


    -- 新帮主系统要考虑三种情况。1 双方轮空。2单方轮空。3正常。三种情况显示的控件不同
    --[[
    if info.attacker == "" and info.defenser == "" then
        -- 双方轮空
        self:setCtrlVisible("LunkongPanel", true, panel)

        if info.time ~= "" then
            self:setCtrlVisible("TwoLunkongLabel", true, panel)
        else
            self:setCtrlVisible("TwoLunkongLabel2", true, panel)
        end

        if info.time and info.time ~= "" then
            self:setLabelText(timeLabelName, gf:getServerDate("%Y-%m-%d %H:%M", tonumber(info.time)))
        end
        return true
    elseif (info.attacker == "" and info.defenser ~= "") or (info.attacker ~= "" and info.defenser == "") then
        -- 单方轮空
        self:setCtrlVisible("LunkongPanel", true, panel)
        self:setCtrlVisible("OneLunkongLabel", true, panel)
        self:setCtrlVisible("VictoryImage", true, panel)
        local partyName = info.attacker
        if partyName == "" then partyName = info.defenser end

        self:setCtrlVisible("OnePartyLabel", true, panel)
        self:setLabelText("OnePartyLabel", partyName, panel)
        if info.time then
            self:setLabelText(timeLabelName, gf:getServerDate("%m-%d %H:%M", tonumber(info.time)))
        end
        return true
    end
    --]]
end

-- 设置淘汰赛的每一条信息
function PartyWarScheduleDlg:setKnockOutEveryInfo(ctrlNames, info, panel)
    self:setLabelText(ctrlNames[1], "")
    self:setLabelText(ctrlNames[2], "")
    self:setLabelText(ctrlNames[3], "")
    self:setCtrlVisible("ResultImage1", false, panel)
    self:setCtrlVisible("ResultImage2", false, panel)
    self:setCtrlVisible("VSImage", false, panel)

    -- 新帮主系统要考虑三种情况。1 双方轮空。2单方轮空。3正常。三种情况显示的控件不同
    if self:setLunkongDisplay(info, panel, ctrlNames[1]) then
        return
    end

    if info.time == "" then
        return
    end

    -- 3正常情况
    self:setCtrlVisible("VSImage", true, panel)
    self:setLabelText(ctrlNames[1], gf:getServerDate("%m-%d %H:%M", tonumber(info.time)))
    local partyName = info.defenser
    if partyName == "" then partyName = ctrlNames[5] end
    if partyName == Me:queryBasic("party/name") then
        self:setLabelText(ctrlNames[2], partyName, nil, COLOR3.GREEN)
    else
        self:setLabelText(ctrlNames[2], partyName, nil, COLOR3.TEXT_DEFAULT)
    end

    partyName = info.attacker
    if partyName == "" then partyName = ctrlNames[6] end
    if partyName == Me:queryBasic("party/name") then
        self:setLabelText(ctrlNames[3], partyName, nil, COLOR3.GREEN)
    else
        self:setLabelText(ctrlNames[3], partyName, nil, COLOR3.TEXT_DEFAULT)
    end

    self:setCtrlVisible("ResultImage1", true, panel)
    self:setCtrlVisible("ResultImage2", true, panel)
    if PARTY_COMPETITION_RESULT.ATTACKER_WIN == info.result then
        -- 攻击方获胜
        self:setImagePlist("ResultImage1", ResMgr.ui.party_war_lose, panel)
        self:setImagePlist("ResultImage2", ResMgr.ui.party_war_win, panel)
    elseif PARTY_COMPETITION_RESULT.DEFENSER_WIN == info.result then
        -- 防守方获胜
        self:setImagePlist("ResultImage1", ResMgr.ui.party_war_win, panel)
        self:setImagePlist("ResultImage2", ResMgr.ui.party_war_lose, panel)
    elseif PARTY_COMPETITION_RESULT.DRAW == info.result then
        -- 平局
        self:setImagePlist("ResultImage1", ResMgr.ui.party_war_draw, panel)
        self:setImagePlist("ResultImage2", ResMgr.ui.party_war_draw, panel)
    else
        self:setCtrlVisible("ResultImage1", false, panel)
        self:setCtrlVisible("ResultImage2", false, panel)
    end

    local time = info.time
    if time ~= "" and gf:getServerTime() <= tonumber(time) then
        self:setCtrlVisible("ResultImage1", false, panel)
        self:setCtrlVisible("ResultImage2", false, panel)
    end
end

-- 设置淘汰赛显示界面
function PartyWarScheduleDlg:setKnockOutInfo(zone)

    local knockOutInfo = PartyWarMgr:getKnockoutInfo(zone)
    if nil == knockOutInfo then
        -- 如果淘汰赛没有数据，显示默认内容
        self:setLabelText("FristFristPartyLabel", CHS[3003297])
        self:setLabelText("FristSecondPartyLabel", CHS[3003300])

        self:setLabelText("SecondFristPartyLabel", CHS[3003299])
        self:setLabelText("SecondSecondPartyLabel", CHS[3003298])

        self:setLabelText("ThridFristPartyLabel", CHS[3003301])
        self:setLabelText("ThridSecondPartyLabel", CHS[3003302])

        self:setLabelText("FinalsFristPartyLabel", CHS[3003303])
        self:setLabelText("FinalsSecondPartyLabel", CHS[3003304])
        return
    end

    local panelName = {
        [2] = "FristSemifinalsPanel",
        [3] = "SecondSemifinalsPanel",
        [4] = "ThridPanel",
        [5] = "FinalsPanel"
    }


    for i = 2, 5 do
        local data
        for j = 1, #knockOutInfo do
            if tonumber(knockOutInfo[j].stage) == i then
                data = knockOutInfo[j]
            end
        end

        local panel = self:getControl(panelName[i])
        self:setKnockOutEveryInfo(KNOCK_CTRL_LIST[tostring(i)], data, panel)
    end

    --[[
    for i = 1, #knockOutInfo do
        local panel = self:getControl(panelName[i])
        self:setKnockOutEveryInfo(KNOCK_CTRL_LIST[knockOutInfo[i].stage], knockOutInfo[i], panel)
    end
    --]]
end

-- 获取默认小组赛or淘汰赛       (COMP_ZONE.A, "A")
function PartyWarScheduleDlg:getDefaultGroup(group)
    if not group then group = "GroupACheckBox" end
    local info = PartyWarMgr:getCompetitionInfo(ZONE_CHECK_BOX_MAP[self.zoneName], GROUP_CHECK_BOX_MAP["GroupACheckBox"])
    if nil == info then return end
    local partysInfo = info.partysInfo
    if not partysInfo or not next(partysInfo) then
        return
    end

    return GROUP_CHECK_BOX_MAP["GroupACheckBox"]
end

-- 设置详细信息
function PartyWarScheduleDlg:setDetalInfo(zone, group)
    self.group = group
    self.zone = zone

    -- 获取更新界面信息
    local info = PartyWarMgr:getCompetitionInfo(zone, group)
    if nil == info and group ~= "" then return end

    -- 然后填充积分榜
    local partysInfo = info.partysInfo
    if partysInfo then
        table.sort(partysInfo, function(l, r)
            if tonumber(l.warScore) > tonumber(r.warScore) then return true end
            if tonumber(l.warScore) < tonumber(r.warScore) then return false end
            if l.win > r.win then return true end
            if l.win < r.win then return false end
        end)
    end

    self:updatePartysInfo(partysInfo)

    -- 最后填充赛程
    self:updateCompetitionList(info.competitionList)
end


-- 更新帮派积分
function PartyWarScheduleDlg:updatePartysInfo(info)
    if nil == info then return end

    -- 获取出线的帮派
    local winParty = PartyWarMgr:getOutletParty(self.zone) or {}

    for i = 1, 4 do
        if info[i] then
            local ctrlStr = "NameLabel_" .. i

            if info[i].partyName == Me:queryBasic("party/name") then
                self:setLabelText(ctrlStr, info[i].partyName, nil, COLOR3.GREEN)
            else
                self:setLabelText(ctrlStr, info[i].partyName, nil, COLOR3.TEXT_DEFAULT)
            end

            ctrlStr = "WinLabel_" .. i
            self:setLabelText(ctrlStr, info[i].win)
            ctrlStr = "LoseLabel_" .. i
            self:setLabelText(ctrlStr, info[i].lose)
            ctrlStr = "DrawLabel_" .. i
            self:setLabelText(ctrlStr, info[i].draw)
            ctrlStr = "ScoreLabel_" .. i
            self:setLabelText(ctrlStr, info[i].warScore)

            -- 出线标记
            local isGetOut = false
            for _, partyName in pairs(winParty) do
                if info[i].partyName == partyName then
                    isGetOut = true
                end
            end

            self:setCtrlVisible("WinImage", isGetOut, self:getControl("PartyInfoPanel_" .. i))
        else
            local ctrlStr = "NameLabel_" .. i
            self:setLabelText(ctrlStr, "", nil, COLOR3.TEXT_DEFAULT)

            ctrlStr = "WinLabel_" .. i
            self:setLabelText(ctrlStr, "")
            ctrlStr = "LoseLabel_" .. i
            self:setLabelText(ctrlStr, "")
            ctrlStr = "DrawLabel_" .. i
            self:setLabelText(ctrlStr, "")
            ctrlStr = "ScoreLabel_" .. i
            self:setLabelText(ctrlStr, "")

            -- 出线标记
            self:setCtrlVisible("WinImage", false, self:getControl("PartyInfoPanel_" .. i))
        end
    end
end

-- 更新赛程
function PartyWarScheduleDlg:updateCompetitionList(info)
    if nil == info then return end
    for i = 1, 6 do
        local panel = self:getControl("GroupScheduleInfoPanel_" .. i)
        self:setCtrlVisible("FristPartyResultPanel_" .. i, false, panel)
        self:setCtrlVisible("SecondPartyResultPanel_" .. i, false, panel)
        self:setCtrlVisible("VSImage", false, panel)

        self:setCtrlVisible("FristPartyResultImage_" .. i, false, panel)
        self:setCtrlVisible("SecondPartyResultImage_" .. i, false, panel)

        self:setCtrlVisible("GroupScheduleInfoPanel_" .. i, true)
        self:setLabelText("TimeLabel_" .. i, "")
        self:setLabelText("FristPartyLabel_" .. i, "")
        self:setLabelText("SecondPartyLabel_" .. i, "")

        if i > #info then
            self:setCtrlVisible("LunkongPanel", false, panel)
        else
            local ctrlStr = "TimeLabel_" .. i
            if not self:setLunkongDisplay(info[i], panel, ctrlStr) then
                self:setCtrlVisible("ResultPanel_" .. 1, true, panel)
                self:setCtrlVisible("ResultPanel_" .. 2, true, panel)
                self:setCtrlVisible("VSImage", true, panel)

                self:setCtrlVisible("GroupScheduleInfoPanel_" .. i, true)

                self:setLabelText(ctrlStr, gf:getServerDate("%m-%d %H:%M", tonumber(info[i].time)))
                ctrlStr = "FristPartyLabel_" .. i
                if info[i].defenser == Me:queryBasic("party/name") then
                    self:setLabelText(ctrlStr, info[i].defenser, nil, COLOR3.GREEN)
                else
                    self:setLabelText(ctrlStr, info[i].defenser, nil, COLOR3.TEXT_DEFAULT)
                end
                ctrlStr = "SecondPartyLabel_" .. i

                if info[i].attacker == Me:queryBasic("party/name") then
                    self:setLabelText(ctrlStr, info[i].attacker, nil, COLOR3.GREEN)
                else
                    self:setLabelText(ctrlStr, info[i].attacker, nil, COLOR3.TEXT_DEFAULT)
                end

                self:setCtrlVisible("FristPartyResultImage_" .. i, true, panel)
                self:setCtrlVisible("SecondPartyResultImage_" .. i, true, panel)
                if PARTY_COMPETITION_RESULT.ATTACKER_WIN == info[i].result then
                    -- 攻击方获胜
                    self:setImagePlist("FristPartyResultImage_" .. i, ResMgr.ui.party_war_lose, panel)
                    self:setImagePlist("SecondPartyResultImage_" .. i, ResMgr.ui.party_war_win, panel)
                elseif PARTY_COMPETITION_RESULT.DEFENSER_WIN == info[i].result then
                    -- 防守方获胜
                    self:setImagePlist("FristPartyResultImage_" .. i, ResMgr.ui.party_war_win, panel)
                    self:setImagePlist("SecondPartyResultImage_" .. i, ResMgr.ui.party_war_lose, panel)
                elseif PARTY_COMPETITION_RESULT.DRAW == info[i].result then
                    -- 平局
                    self:setImagePlist("FristPartyResultImage_" .. i, ResMgr.ui.party_war_draw, panel)
                    self:setImagePlist("SecondPartyResultImage_" .. i, ResMgr.ui.party_war_draw, panel)
                elseif PARTY_COMPETITION_RESULT.PREPARE == info[i].result then
                    self:setCtrlVisible("FristPartyResultImage_" .. i, false, panel)
                    self:setCtrlVisible("SecondPartyResultImage_" .. i, false, panel)
                end

                local time = info[i].time
                if time ~= "" and gf:getServerTime() <= tonumber(time) then
                    self:setCtrlVisible("FristPartyResultImage_" .. i, false, panel)
                    self:setCtrlVisible("SecondPartyResultImage_" .. i, false, panel)
                end
            end
        end
    end
end

return PartyWarScheduleDlg
