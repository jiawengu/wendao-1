-- CaseTWMailDlg.lua
-- Created by huangzz May/30/2018
-- 探案天外之谜-信封界面

local CaseTWMailDlg = Singleton("CaseTWMailDlg", Dialog)

function CaseTWMailDlg:init()
    self:setFullScreen()

    self:bindListener("PageButton", self.onPageButton)
    
    self.lastCloseTime = self.lastCloseTime or 0
    if gf:getServerTime() - self.lastCloseTime < 150 then
        self:setShowPage(self.isFirstPage)
    else
        self:setShowPage(true)
    end
end

function CaseTWMailDlg:onPageButton(sender, eventType)
    local label = self:getControl("Label_1", nil, sender)

    self:setShowPage(not self.isFirstPage)
end

function CaseTWMailDlg:setShowPage(showOnePage)
    self:setCtrlVisible("Label_1", showOnePage, sender)
    self:setCtrlVisible("Label_2", not showOnePage, sender)

    self:setCtrlVisible("PageOnePanel", showOnePage)
    self:setCtrlVisible("PageTwoPanel", not showOnePage)

    self.isFirstPage = showOnePage
end

function CaseTWMailDlg:setData(data)
    for i = 1, data.cou do
        local row = math.ceil(i / 5)
        local col = (i - 1) % 5 + 1

        local panel = self:getControl("IconPanel" .. row .. "_" .. col)
        if data[i] ~= CHS[5450269] then -- 天外
            self:setLabelText("TextLabel", data[i], panel)
            self:setLabelText("NumLabel", "", panel)
            self:setCtrlVisible("IconImage", false, panel)
        else
            self:setLabelText("TextLabel", "", panel)
            self:setLabelText("NumLabel", "", panel)
            self:setCtrlVisible("IconImage", true, panel)
        end
    end

    self:setLabelText("MoseLabel", data.letter_clue, panel)
end

function CaseTWMailDlg:cleanup()
    self.lastCloseTime = gf:getServerTime()
end

return CaseTWMailDlg
