-- HomeworkDlg.lua
-- Created by songcw June/18/2016
-- 传道授业任务发布界面

local HomeworkDlg = Singleton("HomeworkDlg", Dialog)

function HomeworkDlg:init()
    self:bindListener("ChangeButton", self.onChangeButton)    
    self:bindListener("MoneyImage", self.onBuyCashButton)  
    self.charInfo = nil
 
    self:MSG_UPDATE()
 
    local cashText2, fontColor2 = gf:getArtFontMoneyDesc(1000000)
    self:setNumImgForPanel("CostPanel", fontColor2, cashText2, false, LOCATE_POSITION.MID, 23, "MoneyPanel")
    self:hookMsg('MSG_CDSY_TODAY_TASK')
    self:hookMsg('MSG_UPDATE')
    
end

function HomeworkDlg:setStudent(charInfo)
    self.charInfo = charInfo
    MasterMgr:requestTodayTask(charInfo.gid)
    self:MSG_CDSY_TODAY_TASK({task = {[1] =3, [2] = 1}})
end

function HomeworkDlg:onBuyCashButton(sender, eventType)
    gf:showBuyCash()
end

function HomeworkDlg:onChangeButton(sender, eventType)
    if not self.charInfo then return end
    MasterMgr:publishTask(self.charInfo.gid, self.charInfo.name)
    self:onCloseButton()
end

function HomeworkDlg:MSG_CDSY_TODAY_TASK(data)
    local taskInfo = MasterMgr:getShouyeTaskInfo()
    for i = 1, 3 do
        local panel = self:getControl("WorkPanel_" .. i)
        if data.task[i] then
            self:setLabelText("NameLabel", taskInfo[data.task[i]].name, panel)
            self:setLabelText("TimeLabel", string.format("（0/%d）", taskInfo[data.task[i]].round), panel)
            panel:setVisible(true)
        else
            panel:setVisible(false)
        end
        panel:requestDoLayout()
    end
end

function HomeworkDlg:MSG_UPDATE(data)
    local cashText, fontColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('cash'))
    self:setNumImgForPanel("HaveCashPanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23, "MoneyPanel")

end

return HomeworkDlg
