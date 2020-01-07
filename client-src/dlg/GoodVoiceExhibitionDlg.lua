-- GoodVoiceExhibitionDlg.lua
-- Created by songcw Mar/14/2019
-- 问道好声音



local GoodVoiceExhibitionDlg = Singleton("GoodVoiceExhibitionDlg", Dialog)

local SEARCH_LIMINT = 7 * 2
local REFRESH_TIME = 15000  -- 15s

local BUTTON_TYPE = {
    VoiceButtonPanel1 = GoodVoiceMgr.LIST_DATA_TYPE.RANDOM,              -- "发现声音",
    VoiceButtonPanel2 = GoodVoiceMgr.LIST_DATA_TYPE.POPULAR,             -- "人气声音",
    VoiceButtonPanel3 = GoodVoiceMgr.LIST_DATA_TYPE.NEW,                 -- "今日声音",
}

GoodVoiceExhibitionDlg.cache = {}

function GoodVoiceExhibitionDlg:init()
    self:bindListener("SearchButton", self.onSearchButton)
    self:bindListener("MyVoiceButton", self.onMyVoiceButton)
    self:bindListener("RefreshButton", self.onRefreshButton)
    self:bindListener("ViewPanel", self.onViewPanel)
    self:bindListViewListener("ListView", self.onSelectListView)

    -- 搜索
    local searchPanel = self:getControl("SearchPanel")

    self:bindListener("CleanFieldButton", self.onCleanFieldButton, searchPanel)
    self:bindListener("SearchButton", self.onSearchButton, searchPanel)

    self.choosenImage = self:retainCtrl("ChoosenImage")
    self.rowPanel = self:retainCtrl("RowPanel")
    self.selectType = nil

    for i = 1, 3 do
        local panel = self:getControl("VoiceButtonPanel" .. i)
        self:bindTouchEndEventListener(panel, self.onTypeButton)

        local voicePanel = self:getControl("VoicePanel" .. i, nil, self.rowPanel)
        self:bindTouchEndEventListener(voicePanel, self.onUnitVoiceButton)
    end

    -- 隐藏莲花姑娘
    self:setCtrlVisible("NoticePanel", false)

    -- 默认选中发现声音
    self:onTypeButton(self:getControl("VoiceButtonPanel1"), nil, true)

    -- 主题相关
    self:setMainInfo()

    self:hookMsg("MSG_GOOD_VOICE_SHOW_LIST")

    self:bindSearchPanel()
end

-- 点击单个声音
function GoodVoiceExhibitionDlg:bindSearchPanel()
    -- 初始化编辑框
    self:setCtrlVisible("CleanFieldButton", false, "SearchPanel")
    self.inputCtrl = self:createEditBox("InputPanel", "SearchPanel", nil, function(sender, type)
        if "end" == type then
        elseif "changed" == type then
            if not self.inputCtrl then return end
            local content = self.inputCtrl:getText()
            local len = gf:getTextLength(content)
            if len > SEARCH_LIMINT then
                content = gf:subString(content, SEARCH_LIMINT)
                self.inputCtrl:setText(content)
                gf:ShowSmallTips(CHS[5400041])
            end


            if len == 0 then
                self:setCtrlVisible("CleanFieldButton", false, "SearchPanel")
            else
                self:setCtrlVisible("CleanFieldButton", true,  "SearchPanel")
            end
        end
    end)

    self.inputCtrl:setFontColor(COLOR3.TEXT_DEFAULT)
    self.inputCtrl:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.inputCtrl:setPlaceholderFont(CHS[3003794], 19)
    self.inputCtrl:setFont(CHS[3003794], 19)
    self.inputCtrl:setPlaceHolder(CHS[4200701])
    self.inputCtrl:setPlaceholderFontSize(19)
    self.inputCtrl:setPlaceholderFontColor(cc.c3b(102, 102, 102))
    self.inputCtrl:setFontColor(COLOR3.TEXT_DEFAULT)
end


-- 点击单个声音
function GoodVoiceExhibitionDlg:onUnitVoiceButton(sender, eventType)
    gf:CmdToServer("CMD_GOOD_VOICE_QUERY_VOICE", {voice_id = sender.data.voice_id})
end

function GoodVoiceExhibitionDlg:onTypeButton(sender, eventType, isInit)
    self.choosenImage:removeFromParent()
    sender:addChild(self.choosenImage)

    self.selectType = BUTTON_TYPE[sender:getName()]

    if isInit then
        self.cache[self.selectType] = GoodVoiceMgr.cache[self.selectType]
    end

    if self.cache[self.selectType] and gfGetTickCount() - self.cache[self.selectType].receiveTime <= REFRESH_TIME then
        -- 设置列表
        self:setVoices(self.cache[self.selectType].data.voiceShowData)
    else
        gf:CmdToServer("CMD_GOOD_VOICE_SHOW_LIST", {type = BUTTON_TYPE[sender:getName()]})
    end
end

-- 设置主要内容
function GoodVoiceExhibitionDlg:setMainInfo()
    local data = GoodVoiceMgr.seasonData

    -- 主题
    self:setLabelText("ThemeLabel", data.theme_name)

    -- 活动阶段
    local stageStr = ""
    local sTime
    local eTime

    self:setCtrlVisible("ViewPanel", false)
    if gf:getServerTime() >= data.upload_start and gf:getServerTime() <= data.upload_end then
        self:setLabelText("Label1", CHS[4200644], "InfoPanel")  -- 声音上传阶段
        sTime = data.upload_start
        eTime = data.upload_end
    elseif gf:getServerTime() >= data.canvass_start and gf:getServerTime() <= data.canvass_end then
        self:setLabelText("Label1", CHS[4200645], "InfoPanel")    -- 声援阶段
        sTime = data.canvass_start
        eTime = data.canvass_end
    elseif gf:getServerTime() >= data.primary_election_start and gf:getServerTime() <= data.primary_election_end then
        self:setLabelText("Label1", CHS[4200646], "InfoPanel")    -- 初选阶段
        sTime = data.primary_election_start
        eTime = data.primary_election_end
    elseif gf:getServerTime() >= data.final_election_start and gf:getServerTime() <= data.final_election_end then
        self:setLabelText("Label1", CHS[4200647], "InfoPanel")    -- 总选阶段
      --  sTime = data.final_election_start
      --  eTime = data.final_election_end
        self:setColorTextEx(CHS[4300507], self:getControl("ViewPanel"), COLOR3.GREEN)   -- 点击查看评审结果
        self:setCtrlVisible("ViewPanel", true)
    end

    -- 时间
    if sTime then
        local sTimeStr = gf:getServerDate("%m-%d %H:%M", sTime)
        local eTimeStr = gf:getServerDate("%m-%d %H:%M", eTime)
        self:setLabelText("Label2", string.format( CHS[4200648], sTimeStr, eTimeStr), "InfoPanel")   -- %s至%s
    end
end

-- 设置声音列表
function GoodVoiceExhibitionDlg:setVoices(data)
    local list = self:resetListView("ListView")

    self:setCtrlVisible("NoticePanel", #data == 0)
    if #data == 0 then
        return
    end

    local rowCount = math.ceil( #data / 3 )
    local idx = 0
    for i = 1, rowCount do
        local unitPanel = self.rowPanel:clone()
        list:pushBackCustomItem(unitPanel)
        for j = 1, 3 do
            idx = idx + 1
            local voicePanel = self:getControl("VoicePanel" .. j, nil, unitPanel)
            self:setUnitVoice(data[idx], voicePanel, i, j)
        end
    end
end

function GoodVoiceExhibitionDlg:setPhoto(path, para)
    local tab = gf:split(para, "|")
    if not tab then return end
    local row = tonumber(tab[1])
    local idx = tonumber(tab[2])

    local list = self:getControl("ListView")
    local items = list:getItems()

    local rowPanel = items[row]
    if not rowPanel then return end
    local destPanel = self:getControl("VoicePanel" .. idx, nil, rowPanel)

    self:setImage("GuardImage", path, destPanel)

    list:requestRefreshView()
end

--[[
    [LUA-print] DEBUG : -------- 14={ popular=0, voice_id=now_dist|596035CF0060D3000
100|5C938132002495000E01, voice_title=p10的声音, name=p10, img_str=,  }
--]]

function GoodVoiceExhibitionDlg:setUnitVoice(data, panel, row, idx)
    panel.data = data

    if not data then
        panel:setVisible(false)
        return
    end

    -- 封面
    if string.len( data.img_str ) <= 5 then
        local icon = ResMgr:getMatchPortraitByIcon(tonumber(data.img_str))
        self:setImage("GuardImage", icon, panel)
    else
        BlogMgr:assureFile("setPhoto", self.name, data.img_str, nil, string.format( "%d|%d", row, idx))
    end

    -- 玩家姓名
    self:setLabelText("PlayerNameLabel", data.name, panel)

    -- 声音名字
    self:setLabelText("VoiceNameLabel", data.voice_title, panel)

    -- 人气
    local popular = math.min(data.popular, 9999999)
    self:setLabelText("NumLabel", popular, panel)
end

function GoodVoiceExhibitionDlg:onSearchButton(sender, eventType)
    local parentPanel = sender:getParent()
    local code = self.inputCtrl:getText()

    if code == "" then
        gf:ShowSmallTips(CHS[4200649])   -- 请输入想要搜索的声音标题。
        return
    end

    if sender.lastTime and gfGetTickCount() - sender.lastTime <= 30000 then
        gf:ShowSmallTips(CHS[4200650])   -- 30秒内只能搜索一次，请稍后再试。
        return
    end

    sender.lastTime = gfGetTickCount()
    gf:CmdToServer("CMD_GOOD_VOICE_SEARCH", {search_text = code})
end

function GoodVoiceExhibitionDlg:onCleanFieldButton(sender, eventType)
    self.inputCtrl:setText("")
    self:setCtrlVisible("CleanFieldButton", false)
end

function GoodVoiceExhibitionDlg:onMyVoiceButton(sender, eventType)
    if Me:queryBasicInt("level") < 70 then
        gf:ShowSmallTips(CHS[4200651]) -- 角色等级>=70级才可参与问道好声音。
        return
    end

    DlgMgr:openDlg("GoodVoiceMineDlg")
end


function GoodVoiceExhibitionDlg:onViewPanel(sender, eventType)
    DlgMgr:openDlg("GoodVoiceReviewDlg")
end


function GoodVoiceExhibitionDlg:onRefreshButton(sender, eventType)
    if self.cache[self.selectType] and gfGetTickCount() - self.cache[self.selectType].receiveTime <= REFRESH_TIME then
        -- 设置列表
        gf:ShowSmallTips(CHS[4200652])   -- 15秒内只能刷新一次，请稍后再试。
    else
        gf:CmdToServer("CMD_GOOD_VOICE_SHOW_LIST", {type = self.selectType})
    end
end

function GoodVoiceExhibitionDlg:onSelectListView(sender, eventType)
end

function GoodVoiceExhibitionDlg:MSG_GOOD_VOICE_SHOW_LIST(data)
    self.cache[data.list_type] = {}
    self.cache[data.list_type].data = data
    self.cache[data.list_type].receiveTime = gfGetTickCount()

    if data.list_type == GoodVoiceMgr.LIST_DATA_TYPE.SEARCH then
        self.choosenImage:removeFromParent()
        self:setVoices(data.voiceShowData)
        return
    end

    -- 如果下发的不是选中的，直接返回
    if self.selectType ~= data.list_type then return end

    -- 设置列表
    self:setVoices(data.voiceShowData)
end



return GoodVoiceExhibitionDlg
