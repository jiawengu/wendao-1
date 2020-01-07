-- GoodVoiceCollectionDlg.lua
-- Created by
--

local GoodVoiceCollectionDlg = Singleton("GoodVoiceCollectionDlg", Dialog)

function GoodVoiceCollectionDlg:init()
    self:bindListViewListener("ListView", self.onSelectListView)

    self.rowPanel = self:retainCtrl("RowPanel")
    for j = 1, 4 do
        self:bindListener("VoicePanel" .. j, self.onUnitVoiceButton, self.rowPanel)
    end

    local cache = GoodVoiceMgr.cache[GoodVoiceMgr.LIST_DATA_TYPE.COLLECT]
    if cache and gfGetTickCount() - cache.receiveTime <= 15000 then
        -- 有数据，并且数据在15s内，直接设置
        self:setCollectList(cache.data.voiceShowData)
    else
        -- 刷新
        gf:CmdToServer("CMD_GOOD_VOICE_SHOW_LIST", {type = GoodVoiceMgr.LIST_DATA_TYPE.COLLECT})
    end

    self:hookMsg("MSG_GOOD_VOICE_SHOW_LIST")
    self:hookMsg("MSG_GOOD_VOICE_BE_DELETED")
end

-- 点击单个声音
function GoodVoiceCollectionDlg:onUnitVoiceButton(sender, eventType)
    gf:CmdToServer("CMD_GOOD_VOICE_QUERY_VOICE", {voice_id = sender.data.voice_id})
end

function GoodVoiceCollectionDlg:setCollectList(data)
    local list = self:resetListView("ListView")
    local collectCount = #data
    local rowCount = math.ceil(collectCount / 4)
    local idx = 0
    for i = 1, rowCount do
        local panel = self.rowPanel:clone()
        list:pushBackCustomItem(panel)
        for j = 1, 4 do
            local unitPanel = self:getControl("VoicePanel" .. j, nil, panel)
            idx = idx + 1
            self:setUnitVoicePanel(data[idx], unitPanel, i, j)
        end
    end

    self:setCtrlVisible("NoticePanel", rowCount == 0)
end

function GoodVoiceCollectionDlg:setPhoto(path, para)
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

-- 设置单个声音
function GoodVoiceCollectionDlg:setUnitVoicePanel(data, panel, row, idx)

    if not data then
        panel:setVisible(false)
        return
    end

    panel.data = data

    -- 封面
    if string.len( data.img_str ) <= 5 then
        local icon = ResMgr:getMatchPortraitByIcon(tonumber(data.img_str))
        self:setImage("GuardImage", icon, panel)
    else
        BlogMgr:assureFile("setPhoto", self.name, data.img_str, nil, string.format( "%d|%d", row, idx))
    end

    -- 点赞数
    self:setLabelText("NumLabel", data.popular, panel)

    -- 声音名字
    self:setLabelText("VoiceNameLabel", data.voice_title, panel)

    -- 玩家名字
    self:setLabelText("PlayerNameLabel", data.name, panel)
end

function GoodVoiceCollectionDlg:MSG_GOOD_VOICE_SHOW_LIST(data)
    if data.list_type ~= GoodVoiceMgr.LIST_DATA_TYPE.COLLECT then return end
    self:setCollectList(data.voiceShowData)
end

function GoodVoiceCollectionDlg:onSelectListView(sender, eventType)

end


function GoodVoiceCollectionDlg:MSG_GOOD_VOICE_BE_DELETED(data)
    local cache = GoodVoiceMgr.cache[GoodVoiceMgr.LIST_DATA_TYPE.COLLECT]
    if cache and gfGetTickCount() - cache.receiveTime <= 15000 then
        local ret= {}
        for i = 1, #cache.data.voiceShowData do
            if cache.data.voiceShowData[i].voice_id ~= data.voice_id then
                table.insert( ret, cache.data.voiceShowData[i])
            end
        end
        self:setCollectList(ret)
    else
        gf:CmdToServer("CMD_GOOD_VOICE_SHOW_LIST", {type = GoodVoiceMgr.LIST_DATA_TYPE.COLLECT})
    end
end


return GoodVoiceCollectionDlg
