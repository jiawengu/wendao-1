-- CaseRankingListDlg.lua
-- Created by lixh May/24/2018
-- 探案-十佳捕快界面

local CaseRankingListDlg = Singleton("CaseRankingListDlg", Dialog)

function CaseRankingListDlg:init()
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindFloatPanelListener("TipsPanel")
    self:bindListViewListener("RankingListView", self.onSelectRankingListView)

    self.selectImage = self:retainCtrl("SelectedImage", "OneRankingPanel")
    self.cell = self:retainCtrl("OneRankingPanel")

    self:hookMsg("MSG_CHAR_INFO")
    self:hookMsg("MSG_CHAR_INFO_EX")
    self:hookMsg("MSG_OFFLINE_CHAR_INFO")
end

-- 刷新界面
function CaseRankingListDlg:setData(rankingData)
    if not rankingData then return end

    local meGid = Me:queryBasic("gid")
    local meInRank = false
    local listView = self:resetListView("RankingListView")
    for i = 1, rankingData.count do
        local singleInfo = rankingData.list[i]
        if not singleInfo then return end

        local item = self:setSingleItem(self.cell:clone(), singleInfo, i)
        if singleInfo.gid == meGid then
            meInRank = true
            self:setMeData(rankingData, i)  
        end

        listView:pushBackCustomItem(item)
    end

    if not meInRank then
        self:setMeData(rankingData)
    end
end

function CaseRankingListDlg:onSelectRankingListView(sender, eventType)
    local item = self:getListViewSelectedItem(sender)
    if not item then return end
    self:addSelectImage(item)
    
    local gid = item.gid
    if not gid or gid == Me:queryBasic("gid") then return end

    self.selectGid = gid
    FriendMgr:requestCharMenuInfo(gid, nil, nil, 1)
end

function CaseRankingListDlg:setSingleItem(panel, info, rank)
    self:setLabelText("AttributeLabel1", rank, panel)
    self:setLabelText("AttributeLabel2", info.name, panel)
    self:setLabelText("AttributeLabel3", info.level, panel)
    self:setLabelText("AttributeLabel4", info.tanLevel, panel)
    self:setLabelText("AttributeLabel5", TanAnMgr:getTimeStr(info.tanTime), panel)
    self:setCtrlVisible("BackImage2", rank % 2 ~= 0, panel)
    panel.gid = info.gid
    return panel
end

-- 我的排行
function CaseRankingListDlg:setMeData(data, index)
    local root = self:getControl("MyRankingPanel")
    if index then
        self:setLabelText("AttributeLabel1", index, root)
    else
        self:setLabelText("AttributeLabel1", CHS[7190232], root)
        
    end

    self:setLabelText("AttributeLabel2", Me:getName(), root)
    self:setLabelText("AttributeLabel3", Me:getLevel(), root)
    self:setLabelText("AttributeLabel4", data.meTanLevel == "" and CHS[7100268] or data.meTanLevel, root)

    if data.meFinishTime > 0 then
        -- 已完成探案任务
        self:setLabelText("AttributeLabel5", TanAnMgr:getTimeStr(data.meFinishTime), root)
    elseif data.meFinishTime == -1 then
        self:setLabelText("AttributeLabel5", CHS[7100375], root)
    else
        self:setLabelText("AttributeLabel5", CHS[7190233], root)
    end
end

-- 选中效果
function CaseRankingListDlg:addSelectImage(sender)
    self.selectImage:removeFromParent()
    if sender then
        sender:addChild(self.selectImage)
    end
end

function CaseRankingListDlg:onInfoButton(sender, eventType)
    local tipsPanel = self:getControl("TipsPanel", Const.UIPanel)
    tipsPanel:setVisible(not tipsPanel:isVisible())
end

function CaseRankingListDlg:cleanup()
    self.selectGid = nil
end

function CaseRankingListDlg:MSG_OFFLINE_CHAR_INFO(data)
    self:MSG_CHAR_INFO(data)
end

function CaseRankingListDlg:MSG_CHAR_INFO_EX(data)
    self:MSG_CHAR_INFO(data)
end

function CaseRankingListDlg:MSG_CHAR_INFO(data)
    if self.selectGid == data.gid then
        local dlg = DlgMgr:openDlg("CharMenuContentDlg")
        dlg:setInfo(data)
        local rect = {
            x = GameMgr.curTouchPos.x,
            y = GameMgr.curTouchPos.y,
            width = 5,
            height = 5,
        }

        dlg:setFloatingFramePos(rect)

        self.selectGid = nil
    end
end

return CaseRankingListDlg
