-- CityFriendVerificationDlg.lua
-- Created by huangzz Mar/05/2018
-- 区域好友验证界面

local CityFriendVerificationDlg = Singleton("CityFriendVerificationDlg", Dialog)

local LIMIT_WORD = 20

function CityFriendVerificationDlg:init()
    self:bindListener("CleanRemarksButton", self.onCleanRemarksButton)
    self:bindListener("CancelButton", self.onCancelButton)
    self:bindListener("ConfirmButton", self.onConfirmButton)
    
    self:bindEditFieldForSafe("InputPanel", LIMIT_WORD, "CleanRemarksButton", cc.VERTICAL_TEXT_ALIGNMENT_TOP, nil, 160)
end

function CityFriendVerificationDlg:onCleanRemarksButton(sender, eventType)
    self:setInputText("TextField", "")
    sender:setVisible(false)
    self:setCtrlVisible("DefaultLabel", true)
end

function CityFriendVerificationDlg:onCancelButton(sender, eventType)
    DlgMgr:closeDlg("CityFriendVerificationDlg")
end

function CityFriendVerificationDlg:onConfirmButton(sender, eventType)
    local text = self:getInputText("TextField")

    if text ~= "" then
        local text, haveFit = gf:filtText(text)
        if haveFit then
            self:setInputText("TextField", text)
            return
        end
    end

    CitySocialMgr:sendCityFriendCheck(self.charName, self.gid, text)

    DlgMgr:closeDlg("CityFriendVerificationDlg")
end

function CityFriendVerificationDlg:setInfo(info)
    self.charName = info.name
    self.gid = info.gid
    local titleStr = string.format(CHS[5400501], info.name, info.dist_name)
    self:setColorText(titleStr, "NamePanel", nil, nil, nil, nil, 20, true)
end


return CityFriendVerificationDlg
