-- GoodVoiceJudgesDlg.lua
-- Created by
--

local GoodVoiceJudgesDlg = Singleton("GoodVoiceJudgesDlg", Dialog)

function GoodVoiceJudgesDlg:init()
   -- self:bindListViewListener("ListView", self.onSelectListView)

    self.rowPanel = self:retainCtrl("RowPanel")

    for j = 1, 4 do
        local panel = self:getControl("JudgesPanel" .. j, nil, self.rowPanel)
        self:bindListener("GMCloseButton", self.onGMCloseButton, panel)
    end

    gf:CmdToServer("CMD_GOOD_VOICE_JUDGES")

    self:hookMsg("MSG_GOOD_VOICE_JUDGES")

    self:setData()
end


function GoodVoiceJudgesDlg:onGMCloseButton(sender, eventType)
    gf:confirm(CHS[4200670], function ( )   -- 是否删除此评委打分？

        gf:CmdToServer("CMD_ADMIN_GOOD_VOICE_DELETE_JUDGE", {name = sender:getParent().data.name})
    end)
end


function GoodVoiceJudgesDlg:setData()

end

function GoodVoiceJudgesDlg:setPhoto(path, para)
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

-- 设置单个声音
function GoodVoiceJudgesDlg:setUnitJudgesPanel(data, panel, row, idx)
    panel.data = data
    if not data then
        panel:setVisible(false)
        return
    end

    -- 封面
    local headPanel = self:getControl("ShapePanel", nil, panel)
    if string.len( data.icon_img ) <= 5 then
        local resIcon = ResMgr:getSmallPortrait(tonumber(data.icon_img))
        self:setImage("GuardImage", resIcon, panel)
    else
        BlogMgr:assureFile("setPhoto", self.name, data.icon_img, nil, string.format( "%d|%d", row, idx))
    end

    -- 简介
    local contentPanel = self:getControl("TestPanel", nil, panel)
    self:setLabelText("Label", data.desc, contentPanel)

    -- 玩家名字
    self:setLabelText("PlayerNameLabel", data.name, panel)

    self:setCtrlVisible("GMCloseButton", GMMgr:isGM(), panel)
end

function GoodVoiceJudgesDlg:MSG_GOOD_VOICE_JUDGES(data)
    local list = self:resetListView("ListView")
    local collectCount = data.count
    local rowCount = math.ceil(collectCount / 4)

    local idx = 0
    for i = 1, rowCount do
        local panel = self.rowPanel:clone()
        list:pushBackCustomItem(panel)
        for j = 1, 4 do
            local unitPanel = self:getControl("JudgesPanel" .. j, nil, panel)
            idx = idx + 1
            self:setUnitJudgesPanel(data.judes_for_nomal[idx], unitPanel, i, j)
        end
    end
end


function GoodVoiceJudgesDlg:onSelectListView(sender, eventType)
end

return GoodVoiceJudgesDlg
