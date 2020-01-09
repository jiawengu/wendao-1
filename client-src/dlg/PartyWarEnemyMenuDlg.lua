-- PartyWarEnemyMenuDlg.lua
-- Created by songcw Jan/11/2016
-- 帮战敌方菜单对话框

local PartyWarEnemyMenuDlg = Singleton("PartyWarEnemyMenuDlg", Dialog)

function PartyWarEnemyMenuDlg:init()
    self:bindListener("FightButton", self.onFightButton)
    self.id = nil
    self:hookMsg("MSG_TEAM_DATA")
end

function PartyWarEnemyMenuDlg:queryTeam(gid)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_GET_TEAM_DATA, gid)
end

function PartyWarEnemyMenuDlg:onFightButton(sender, eventType)
    if not self.id then return end
    
    if not Me:isNearById(self.id) then
        gf:ShowSmallTips(CHS[3003291])
        DlgMgr:sendMsg("MissionDlg", "updatePartyWarInfo")    
        return    
    end
    
    gf:CmdToServer("CMD_KILL", {victim_id = self.id})
end

function PartyWarEnemyMenuDlg:MSG_TEAM_DATA(data)
    for i = 1,5 do   
        local panel = self:getControl("CharInfoPanel_" .. i)
        if i <= data.count then       
            if i > 1 then 
                self:setCtrlVisible("TeamImage", false, panel)
                self:setLabelText("IdentityLabel", CHS[3003292], panel)
            elseif data.isTeam == 1 then
                self:setCtrlVisible("TeamImage", true, panel)
                self:setLabelText("IdentityLabel", CHS[3003293], panel)
            else
                self:setCtrlVisible("TeamImage", false, panel)
                self:setLabelText("IdentityLabel", CHS[3003294], panel)
            end
            if data.teamInfo[i].zanli == 0 and data.count > 1 then
                self:setCtrlEnabled("ShapeImage", false, panel)
                self:setCtrlVisible("Zanli", true, panel)
            end

            local nameColor = CharMgr:getNameColorByType(OBJECT_TYPE.CHAR, data.teamInfo[i].vip, nil, true)
            self:setLabelText("NameLabel", gf:getRealName(data.teamInfo[i].name), panel, nameColor)
            self:setImage("ShapeImage", ResMgr:getSmallPortrait(data.teamInfo[i].icon), panel)
            self:setItemImageSize("ShapeImage", panel)
            self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, data.teamInfo[i].level, false, LOCATE_POSITION.LEFT_TOP, 19, panel)
        else
            self:setLabelText("IdentityLabel", "", panel)
            self:setLabelText("NameLabel", "", panel)
            self:setCtrlVisible("TeamImage", false, panel)
            self:setCtrlVisible("EmptyLabel", true, panel)
            self:getControl("LevelPanel", nil, panel):removeAllChildren()
            self:getControl("ShapeImage", nil, panel):resume()
        end        
    end
    
    self.id = data.teamInfo[1].id
end

return PartyWarEnemyMenuDlg
