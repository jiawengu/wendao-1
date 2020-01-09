-- PetStruggleCombatResultDlg.lua
-- Created by huangzz Sep/20/2017
-- 斗宠大会战报界面

local PetStruggleCombatResultDlg = Singleton("PetStruggleCombatResultDlg", Dialog)

function PetStruggleCombatResultDlg:init()
    self:bindListener("ChallengerImagePanel", self.onChallengerImagePanel)
    
    self.recordPanel = self:retainCtrl("RecordPanel")
    
    self:setCtrlVisible("ListView", true)
    self:setRecordList()
    
    self.selectSender = nil
end

-- record_time 战报时间
-- challenge_staus 0表示挑战    1表示被挑战
-- gid
-- player_name
-- vectory_status 0表示胜利   1表示失败
-- last_ranking  上次排名
-- cur_ranking  本次排名
function PetStruggleCombatResultDlg:setOneRecord(data, cell)
    -- 胜负
    if data.vectory_status == 0 then
        self:setImagePlist("ResultImage", ResMgr.ui.party_war_win, cell)
    elseif data.vectory_status == 1 then
        self:setImagePlist("ResultImage", ResMgr.ui.party_war_lose, cell)
    else
        self:setImagePlist("ResultImage", ResMgr.ui.party_war_draw, cell)
    end
    
    -- 排名
    local rankC = data.last_ranking - data.cur_ranking
    self:setCtrlVisible("DrawRankingLabel", rankC == 0, cell)
    self:setCtrlVisible("IndexImage", rankC ~= 0, cell)
    if rankC < 0 then
        self:setImagePlist("IndexImage", ResMgr.ui.zhanbao_order_down_plist, cell)
        self:setLabelText("RankingLabel", -rankC, cell)
    elseif rankC > 0 then
        self:setImagePlist("IndexImage", ResMgr.ui.zhanbao_order_up_plist, cell)
        self:setLabelText("RankingLabel", rankC, cell)
    else
        self:setLabelText("DrawRankingLabel", CHS[5400291], cell)
    end
    
    -- 对方信息
    self:setImage("PortraitImage", ResMgr:getSmallPortrait(data.player_icon), cell)
    self:setItemImageSize("PortraitImage", cell)
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, data.player_level or 1, false, LOCATE_POSITION.LEFT_TOP, 23, cell)
    self:setLabelText("NameLabel", data.player_name, cell)
    
    -- 挑战时间
    local combatStr = ArenaMgr:getRecordTimestr(data.record_time)
    if data.challenge_staus == 0 then
        combatStr = combatStr .. CHS[5400292]
    else
        combatStr = combatStr .. CHS[5400293]
    end
    
    self:setLabelText("CombatLabel", combatStr, cell)
    
    cell.data = data
end

-- 初值化战报
function PetStruggleCombatResultDlg:setRecordList()
    local recordTable = ArenaMgr:getRecordData("pet")
    local listView = self:resetListView("ListView", 3)
    local cou = #recordTable
    
    if cou == 0 then
        self:setCtrlVisible("NoticePanel", true)
        return
    end
    
    self:setCtrlVisible("NoticePanel", false)
    
    for i = cou, 1, -1 do
        local cell = self.recordPanel:clone()
        self:setOneRecord(recordTable[i], cell)
        listView:pushBackCustomItem(cell)
    end
end

function PetStruggleCombatResultDlg:onChallengerImagePanel(sender, eventType)
    local data = sender:getParent().data
    if data then
        if not data["gid"] or data["gid"] == "" then   -- 目标位npc
            gf:ShowSmallTips(CHS[6000139])
        else
            FriendMgr:requestCharMenuInfo(data["gid"], {
                needCallWhenFail = true,
                gid = data["gid"],
                requestDlg = self.name,
            })

            self.selectSender = sender
        end
    end
end

function PetStruggleCombatResultDlg:onCharInfo(gid, isFail)
    if not self.selectSender then return end

    if isFail then
        gf:ShowSmallTips(CHS[6000139])
    else
        local dlg = DlgMgr:openDlg("CharMenuContentDlg")
        if dlg then

            dlg:setting(gid)
            local rect = self:getBoundingBoxInWorldSpace(self.selectSender)
            dlg:setFloatingFramePos(rect)
        end
    end
end

function PetStruggleCombatResultDlg:cleanup()
    FriendMgr:unrequestCharMenuInfo(self.name)

    self.selectSender = nil
end

return PetStruggleCombatResultDlg
