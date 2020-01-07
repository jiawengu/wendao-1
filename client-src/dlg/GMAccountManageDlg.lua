-- GMAccountManageDlg.lua
-- Created by songcw Feb/24/2016
-- GM账号操作

local GMAccountManageDlg = Singleton("GMAccountManageDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

local CHECKBOXS = {
    "ShowUserListCheckBox",
    "BlockAccountCheckBox",
}

function GMAccountManageDlg:init()
    self.root:setContentSize(Const.WINSIZE.width / Const.UI_SCALE, Const.WINSIZE.height / Const.UI_SCALE)
    self:align(ccui.RelativeAlign.centerInParent)
    self.root:requestDoLayout()
    -- 事件监听
    self:bindTouchEndEventListener(self.root, self.onCloseButton)
    -- 单选CheckBox
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItemsCanReClick(self, CHECKBOXS, self.onMenuCheckBoxClick)
end

function GMAccountManageDlg:setUser(user)
    self.userInfo = user
end

function GMAccountManageDlg:onMenuCheckBoxClick(sender, curIdx)
    if curIdx == 1 then
        GMMgr:cmdQueryByAccount(self.userInfo.account, "char")
        DlgMgr:closeDlg("GMAccountListDlg")   
        self:onCloseButton()
    elseif curIdx == 2 then
        -- 封闭账号
        local dlg = DlgMgr:openDlg("GMBlockAccountDlg")
        dlg:setDlgInfoByUser(self.userInfo)
    end
     
end

return GMAccountManageDlg
