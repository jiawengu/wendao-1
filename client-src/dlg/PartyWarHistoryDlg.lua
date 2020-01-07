-- PartyWarHistoryDlg.lua
-- Created by liuhb Apr/7/2015
-- 历届帮战列表

local RadioGroup = require("ctrl/RadioGroup")
local PartyWarHistoryDlg = Singleton("PartyWarHistoryDlg", Dialog)

local MARGIN = 1
local ITEM_HEIGHT = 40
local ZONE = {
    A = "A",
    B = "B",
}

local ZONE_LIST = {
    "ZoneACheckBox",
    "ZoneBCheckBox",
    "ZoneCCheckBox",
}

local ZONE_CHECK_BOX_MAP = {
    ["ZoneACheckBox"] = COMP_ZONE.A,
    ["ZoneBCheckBox"] = COMP_ZONE.B,
    ["ZoneCCheckBox"] = COMP_ZONE.C,
    [COMP_ZONE.A] = "ZoneACheckBox",
    [COMP_ZONE.B] = "ZoneBCheckBox",
    [COMP_ZONE.C] = "ZoneCCheckBox",
}

local KNOCK_CTRL_LIST = {
    [COMP_STAGE.KNOCKOUT_1] = {"FristTimeLabel", "FristFristPartyLabel", "FristSecondPartyLabel", "FristResultLabel"},
    [COMP_STAGE.KNOCKOUT_2] = {"SecondTimeLabel", "SecondFristPartyLabel", "SecondSecondPartyLabel", "SecondResultLabel"},
    [COMP_STAGE.KNOCKOUT_3] = {"ThridTimeLabel", "ThridFristPartyLabel", "ThridSecondPartyLabel", "ThridResultLabel"},
    [COMP_STAGE.KNOCKOUT_4] = {"FinalsTimeLabel", "FinalsFristPartyLabel", "FinalsSecondPartyLabel", "FinalsResultLabel"},
}

local lastCheckZone = "ZoneACheckBox"  -- 上一次选中按钮，如果选择赛区没有数据，返回上一个
local curCheckZone = "ZoneACheckBox"

local PAGE_COUNT = 12

function PartyWarHistoryDlg:init()
    -- 初始化区组CheckBox
    self.zoneList = RadioGroup.new()
    self.zoneList:setItems(self, ZONE_LIST, function(sender, eventType)
        local zoneName = self.zoneList:getSelectedRadioName()
        PartyWarMgr:requestPartyWarInfo(self.histroyIdx, ZONE_CHECK_BOX_MAP[zoneName])
        curCheckZone = self.zoneList:getSelectedRadio():getName()
    end)
    
    self.sessionNumPanel = self:getControl("SessionNumPanel")
    self.sessionNumPanel:removeFromParent()
    self.sessionNumPanel:retain()

    self.selectImg = self:getControl("ChosenEffectImage", Const.UIImage, self.sessionNumPanel)
    self.selectImg:retain()
    self.selectImg:removeFromParent()
    self.selectImg:setVisible(true)
    
    -- 设置届数列表
    self.start = 1
    self.histroyIdx = nil
    -- 填充列表
    self.list, self.listSize = self:resetListView("ListView", MARGIN)
    self:setHistoryListInfo()    
    self:bindListViewByPageLoad("ListView", "TouchPanel", function(dlg, percent)
        if percent > 100 then
            -- 下拉获取下一页
            local hisInfo = PartyWarMgr:getPartyWarInfo(self.start, PAGE_COUNT)
            if not hisInfo or not next(hisInfo) then return end            
            self:pushData(hisInfo)
            self.start = self.start + #hisInfo
        end
    end)
    
    self:hookMsg("MSG_GENERAL_NOTIFY")
    self:hookMsg("MSG_PARTY_WAR_INFO")    
end

function PartyWarHistoryDlg:cleanup()
    self:releaseCloneCtrl("sessionNumPanel")
    self:releaseCloneCtrl("selectImg")
end

function PartyWarHistoryDlg:pushData(hisInfo)
    for i = 1, #hisInfo do
        self.list:pushBackCustomItem(self:createItem(hisInfo[i], not self.histroyIdx))
    end
    
    self.list:refreshView()
end

-- 初始化列表
function PartyWarHistoryDlg:setHistoryListInfo()
    local hisInfo = PartyWarMgr:getPartyWarInfo(self.start, PAGE_COUNT)    
    self:pushData(hisInfo)
    self.start = self.start + #hisInfo
end

-- 创建条目
function PartyWarHistoryDlg:createItem(info, isFocus)
    local idx = info.no
    local itemPanel = self.sessionNumPanel:clone()
    itemPanel.info = info

    -- 添加点击监听事件，默认单点
    itemPanel:setTouchEnabled(true)
    local function selectHistory(sender, eventType)
        if ccui.TouchEventType.ended == eventType then
            local no = sender.info.no

            local item = sender
            local img = self:getSelectImg()
            img:removeFromParent(false)
            item:addChild(img)
            self.histroyIdx = no
            self.zoneList:selectRadio(tonumber(COMP_ZONE.A))
        end
    end

    itemPanel:addTouchEventListener(selectHistory)

    self:setLabelText("SessionNumLabel", string.format(CHS[5000109], idx), itemPanel)

    if isFocus then
        local img = self:getSelectImg()
        img:removeFromParent(false)
        itemPanel:addChild(img)
        self.histroyIdx = idx
        self.zoneList:selectRadio(tonumber(COMP_ZONE.A))
    end

    return itemPanel
end

-- 选择框
function PartyWarHistoryDlg:getSelectImg()
    return self.selectImg
end

-- 设置右侧具体信息
function PartyWarHistoryDlg:setHistoryDetail(info)
    if nil == info then return end
end

-- 设置淘汰赛的每一条信息
function PartyWarHistoryDlg:setKnockOutEveryInfo(ctrlNames, info, index)

    local panelName = {
        [1] = "FristSemifinalsPanel",
        [2] = "SecondSemifinalsPanel",
        [3] = "ThridPanel",
        [4] = "FinalsPanel",
        }
    local panel = self:getControl(panelName[index])
    
    self:setCtrlVisible("VSImage", false, panel)
    self:setCtrlVisible("SecondWinImage", false, panel)
    self:setCtrlVisible("FristWinImage", false, panel)
    for _, name in pairs(ctrlNames) do
        self:setLabelText(name, "")
    end
    
    -- 新帮主系统要考虑三种情况。1 双方轮空。2单方轮空。3正常。三种情况显示的控件不同    
    if self:setLunkongDisplay(info, panel, ctrlNames[1]) then
        return
    end
    
    if info.time == "" then
        return
    end
    
    self:setCtrlVisible("VSImage", true, panel)
    
    self:setLabelText(ctrlNames[1], gf:getServerDate("%Y-%m-%d %H:%M", tonumber(info.time)))
    if info.defenser == Me:queryBasic("party/name") then
        self:setLabelText(ctrlNames[2], info.defenser, nil, COLOR3.GREEN)
    else
        self:setLabelText(ctrlNames[2], info.defenser, nil, COLOR3.TEXT_DEFAULT)
    end
    
    if info.attacker == Me:queryBasic("party/name") then
        self:setLabelText(ctrlNames[3], info.attacker, nil, COLOR3.GREEN)
    else
        self:setLabelText(ctrlNames[3], info.attacker, nil, COLOR3.TEXT_DEFAULT)
    end
    local resultStr = ""
    self:setCtrlVisible("SecondWinImage", true, panel)
    self:setCtrlVisible("FristWinImage", true, panel)
    if PARTY_COMPETITION_RESULT.ATTACKER_WIN == info.result then
        -- 攻击方获胜         
        self:setImagePlist("FristWinImage", ResMgr.ui.party_war_lose, panel)
        self:setImagePlist("SecondWinImage", ResMgr.ui.party_war_win, panel)
    elseif PARTY_COMPETITION_RESULT.DEFENSER_WIN == info.result then
        -- 防守方获胜
        self:setImagePlist("FristWinImage", ResMgr.ui.party_war_win, panel)
        self:setImagePlist("SecondWinImage", ResMgr.ui.party_war_lose, panel)
    elseif PARTY_COMPETITION_RESULT.DRAW == info.result then
        -- 平局
        self:setCtrlVisible("SecondWinImage", false, panel)
        self:setCtrlVisible("FristWinImage", false, panel)
    end
end

-- 设置淘汰赛显示界面
function PartyWarHistoryDlg:setKnockOutInfo(knockOutInfo)
    if nil == knockOutInfo then return end

    for i = 1, #knockOutInfo do
        self:setKnockOutEveryInfo(KNOCK_CTRL_LIST[knockOutInfo[i].stage], knockOutInfo[i], i)
    end
end

function PartyWarHistoryDlg:MSG_GENERAL_NOTIFY(data)
    if NOTIFY.NOTIFY_PW_AREA_NO_DATA == data.notify then
        local info = gf:split(data.para, "|")
        local hasData = info[1]
        local no = info[2]
        local dist = info[3]
        if tonumber(no) ~= self.histroyIdx then return end
        
        if hasData == "1" then
            lastCheckZone = ZONE_CHECK_BOX_MAP[dist]
        else
            self.zoneList:setSetlctByName(lastCheckZone)
            curCheckZone = lastCheckZone
        end
    end    
end

function PartyWarHistoryDlg:setLunkongDisplay(info, panel, timeLabelName)
    self:setCtrlVisible("LunkongPanel", true, panel)
    self:setCtrlVisible("TwoLunkongLabel", false, panel)
    self:setCtrlVisible("TwoLunkongLabel2", false, panel)
    self:setCtrlVisible("OneLunkongLabel", false, panel)
    self:setLabelText("OnePartyLabel", "", panel)
    self:setLabelText(timeLabelName, "", panel)
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
                self:setLabelText(timeLabelName, gf:getServerDate("%Y-%m-%d %H:%M", tonumber(info.time)))
            else
                -- 单方轮空
                self:setCtrlVisible("OneLunkongLabel", true, panel)
                self:setCtrlVisible("VictoryImage", true, panel)
                local partyName = info.attacker
                if partyName == "" then partyName = info.defenser end

                self:setCtrlVisible("OnePartyLabel", true, panel)
                self:setLabelText("OnePartyLabel", partyName, panel)
                self:setLabelText(timeLabelName, gf:getServerDate("%Y-%m-%d %H:%M", tonumber(info.time)))
                return true
            end
        end
    end

    self:setCtrlVisible("LunkongPanel", false, panel)
    --[[
    
    -- 新帮主系统要考虑三种情况。1 双方轮空。2单方轮空。3正常。三种情况显示的控件不同    
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
            self:setLabelText(timeLabelName, gf:getServerDate("%Y-%m-%d %H:%M", tonumber(info.time)))
        end
        return true
    end 
--]]
end

function PartyWarHistoryDlg:MSG_PARTY_WAR_INFO(data)
    -- 设置左边列表菜单，当no == "1"即收完成（服务器可能分页）
    if data.type == PARTY_TYPE.HISTORY_INFO_TYPE and data.count > 0 and data.info[data.count].no == "1" then
        self:setHistoryListInfo()    
    end
    
    -- 请求的具体数据
    if data.type == PARTY_TYPE.HISTORY_DETAL_SCHEDULE_EX then
        local hisInfo = {}
        for i = 1, #data.info do
            table.insert(hisInfo, {                
                stage       = data.info[i].stage,
                time        = data.info[i].time,
                defenser    = data.info[i].defenser,
                attacker    = data.info[i].attacker,
                result      = data.info[i].result})
        end
        self:setKnockOutInfo(hisInfo)
    end
end

return PartyWarHistoryDlg
