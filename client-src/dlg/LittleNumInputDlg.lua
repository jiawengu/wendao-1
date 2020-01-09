-- LittleNumInputDlg.lua
-- Created by songcw Oct/22/2015
-- 小键盘界面

-- 历史遗留原因，这个小键盘界面占时只针对帮派批量研发技能进行优化
-- 后续需要使用此小键盘的接口，需要小心处理

local LittleNumInputDlg = Singleton("LittleNumInputDlg", Dialog)

function LittleNumInputDlg:init()
    self.num = 0
    self.maxNum = 0
    for i = 0, 9 do
        local btn = self:getControl(i .. "Button")
        btn:setTag(i)

        self:bindTouchEndEventListener(btn, self.onNumButton)
    end
    self:bindListener("DeleteButton", self.onDeleteButton)
    self:bindListener("ComfireButton", self.onComfireButton)
end

function LittleNumInputDlg:setMax(levelMax)
    self.maxNum = PartyMgr:getPartyLevelMax() - levelMax
end

function LittleNumInputDlg:onNumButton(sender, eventType)
    self.num = self.num * 10 + sender:getTag()
    if self.num > self.maxNum then
        self.num = self.maxNum
        gf:ShowSmallTips(string.format(CHS[3002913], self.num))
    end
    DlgMgr:sendMsg("PartySkillBatchDevelopDlg", "setDestLevel", self.num)
end

function LittleNumInputDlg:onDeleteButton(sender, eventType)
    self.num = math.floor(self.num / 10)
    if self.num > self.maxNum then self.num = self.maxNum end
    DlgMgr:sendMsg("PartySkillBatchDevelopDlg", "setDestLevel", self.num)
end

function LittleNumInputDlg:onComfireButton(sender, eventType)
    self:onCloseButton()
    DlgMgr:sendMsg("PartySkillBatchDevelopDlg", "setCost", self.num)
end

return LittleNumInputDlg
