-- PetDressTabDlg.lua
-- Created by
--



local TabDlg = require('dlg/TabDlg')
local PetDressTabDlg = Singleton("PetDressTabDlg", TabDlg)

-- 按钮与对话框的映射表
PetDressTabDlg.dlgs = {
    DressDlgCheckBox = "PetDressDlg",
    ChangeColorDlgCheckBox = "PetChangeColorDlg",
    RuleCheckBox = "PetDressRuleDlg",
}

function PetDressTabDlg:onPreCallBack(sender, idx)
    if sender:getName() == "ChangeColorDlgCheckBox" then

        local pet = DlgMgr:sendMsg("PetAttribDlg", "getCurrentPet")
        local data = PetMgr:getChangeColorIcons(pet:queryBasicInt("icon"))
        if #data == 0 then
            gf:ShowSmallTips(CHS[4010285])
            return false
        end
    end

    return true
end

return PetDressTabDlg
