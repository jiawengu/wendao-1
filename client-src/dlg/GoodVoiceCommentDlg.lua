-- GoodVoiceCommentDlg.lua
-- Created by songcw Mar/22/2019
--  好声音-评价界面



local GoodVoiceCommentDlg = Singleton("GoodVoiceCommentDlg", Dialog)

function GoodVoiceCommentDlg:init(data)

    self.rowPanel = self:retainCtrl("RowPanel")
    for j = 1, 4 do
        self:bindListener("JudgesPanel" .. j, self.onUnitVoiceButton, self.rowPanel)
        local panel = self:getControl("JudgesPanel" .. j, nil, self.rowPanel)
        self:bindListener("GMCloseButton", self.onGMCloseButton, panel)
        self:bindListener("CommentButton", self.onCommentButton, panel)
    end

    self:setData(data)

    self:hookMsg("MSG_GOOD_VOICE_SCORE_DATA")
end

function GoodVoiceCommentDlg:setData(data)
    self.data = data
    self:setLabelText("VoiceNameLabel", data.voice_title)

    if data.total_score < 0 then
        self:setLabelText("NumLabel", "")
    else
        self:setLabelText("NumLabel", string.format( CHS[4200641], data.basic_score, (data.total_score - data.basic_score), data.total_score))    -- 总分：%d（基础分） + %d（评委分） = %d
    end
    local list = self:resetListView("ListView")
    local totalCount = data.count
    local rowCount = math.ceil( totalCount / 4 )
    local idx = 0
    for i = 1, rowCount do
        local panel = self.rowPanel:clone()
        list:pushBackCustomItem(panel)
        for j = 1, 4 do
            local unitPanel = self:getControl("JudgesPanel" .. j, nil, panel)
            idx = idx + 1
            self:setUnitVoicePanel(data.scoreData[idx], unitPanel, i, j)
        end
    end
end
--[[
    [LUA-print] DEBUG : -------- 18={ icon_img=, voice_addr=一二三四五六七八九十一二
三四五六七八九十, voice_id=now_dist|5979A913007A3E000100|5C93381100B32A000E01, v
oice_title=p0013的声音, name=p0013, score=67,  }
]]

function GoodVoiceCommentDlg:setUnitVoicePanel(data, panel, row, idx)
    panel.data = data

    if not data then
        panel:setVisible(false)
        return
    end

    -- 打分
    self:setLabelText("NumLabel", string.format(CHS[4200643], data.score ), panel)  -- 打分：%d

    -- 玩家名字
    self:setLabelText("PlayerNameLabel", data.name, panel)

       -- 封面
    local headPanel = self:getControl("ShapePanel", nil, panel)
    if string.len( data.icon_img ) <= 5 then
      --  self:setImage("GuardImage", ResMgr:getBigPortrait(tonumber(data.icon_img)), panel)
        local resIcon = ResMgr:getSmallPortrait(tonumber(data.icon_img))
        self:setImage("GuardImage", resIcon, panel)
    else
        BlogMgr:assureFile("setPhoto", self.name, data.icon_img, nil, string.format( "%d|%d", row, idx))
    end

    self:setCtrlVisible("GMCloseButton", GMMgr:isGM(), panel)
end

function GoodVoiceCommentDlg:setPhoto(path, para)
    if not path or path == "" then return end
    local tab = gf:split(para, "|")
    if not tab then return end
    local row = tonumber(tab[1])
    local idx = tonumber(tab[2])

    local list = self:getControl("ListView")
    local items = list:getItems()

    local rowPanel = items[row]
    if not rowPanel then return end
    local destPanel = self:getControl("JudgesPanel" .. idx, nil, rowPanel)

    self:setImage("GuardImage", path, destPanel)

    list:requestRefreshView()
end

function GoodVoiceCommentDlg:onGMCloseButton(sender, eventType)
    gf:confirm(CHS[4200642], function ( )   -- 是否删除此评委打分？
        gf:CmdToServer("CMD_ADMIN_GOOD_VOICE_DELETE_SCORE", {name = sender:getParent().data.name, voice_id = self.data.voice_id})
    end)
end

function GoodVoiceCommentDlg:onCommentButton(sender, eventType)
    local data = sender:getParent().data
    gf:showTipInfo(data.comment, sender)
end

function GoodVoiceCommentDlg:MSG_GOOD_VOICE_SCORE_DATA(data)
    self:setData(data)
end

return GoodVoiceCommentDlg
