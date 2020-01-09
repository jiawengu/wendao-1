-- TongTianTopTargetDlg.lua
-- Created by songcw Nov/27/2018
-- 通天塔塔顶 投票界面

local DugeonVoteDlg = require('dlg/DugeonVoteDlg')
local TongTianTopVoteDlg = Singleton("TongTianTopVoteDlg", DugeonVoteDlg)



function TongTianTopVoteDlg:setTitle(data)
    -- 星君

    local function setUnitShape(data, panel)
        if data then
            panel:setVisible(true)

            self:setImage("ShapeImage", ResMgr:getSmallPortrait(data.org_icon), panel)
            self:setLabelText("NameLabel", gf:getRealName(data.name), panel)
        else
            panel:setVisible(false)
        end
    end

    local npcList = gf:split(data.para, "|")
    local npcData = {}
    for i = 1, #npcList do
        local info = gf:split(npcList[i], ":")
        table.insert( npcData, {name = info[1], org_icon = info[2]} )
    end

    for i = 1, 5 do

        local panel = self:getControl("MemberPanel_" .. i, nil, "NPCteamPanel")
        if #npcData == 1 then
            if i == 3 then
                setUnitShape(npcData[1], panel)
            else
                setUnitShape(nil, panel)
            end
        else
            setUnitShape(npcData[i], panel)
        end

    end

    -- 标题
    self:setLabelText("TitleLabel_1", data.title)
    self:setLabelText("TitleLabel_2", data.title)

    -- 设置界面相关信息
    self.voteData = data

    self:setUiInfo()

    -- 退出投票按钮
    if data.is_team_leader == 1 then
        self:setCtrlVisible("StopVoteButton", true)
    else
        self:setCtrlVisible("StopVoteButton", false)
    end

    -- 刷新倒计时
    self:setHourglass(self.voteData.time)

    self:displayTeamInfo("MemberPanel")
end


return TongTianTopVoteDlg
