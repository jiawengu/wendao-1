-- PetTabDlg.lua
-- Created by cheny Dec/24/2014
-- 宠物选项

-- 图鉴显示的最低等级要求
local HANDBOOK_SHOW_LEVEL = 0

local TabDlg = require('dlg/TabDlg')
local PetTabDlg = Singleton("PetTabDlg", TabDlg)

PetTabDlg.orderList = {
    ['PetAttribDlgCheckBox']        = 1,
    ['PetGetAttribDlgCheckBox']     = 2,
    ['PetSkillDlgCheckBox']         = 3,
    ['PetHorseDlgCheckBox']         = 4,
    ['PetHandbookDlgCheckBox']      = 5,
}

PetTabDlg.dlgs = {
    PetAttribDlgCheckBox    = 'PetAttribDlg',
    PetGetAttribDlgCheckBox = 'PetGetAttribDlg',
    PetSkillDlgCheckBox     = 'PetSkillDlg',
    PetHorseDlgCheckBox     = 'PetHorseDlg',
    PetHandbookDlgCheckBox  = 'PetHandbookDlg',
}

PetTabDlg.defDlg = "PetAttribDlg"

-- 2分30秒打开时候要记录选中的装备id
PetTabDlg.lastSelectItemId = nil

function PetTabDlg:setLastSelectItemId(id)
    self.lastSelectItemId = id
end

function PetTabDlg:init()
    TabDlg.init(self)
    
    if Me:getLevel() < HANDBOOK_SHOW_LEVEL then
        self:setCtrlVisible('PetHandbookDlgCheckBox', false)
    end
end

function PetTabDlg:cleanup()
    DlgMgr:closeDlg("PetListChildDlg")
end

function PetTabDlg:getIgnoreDlgWhenCloseCurShowDlg()
    if DlgMgr:getDlgByName(self.name) then
        return { [self.name] = 0, ["PetListChildDlg"] = 0 }
    else
        return self.name
    end
end

function PetTabDlg:getOpenDefaultDlg()
    return TabDlg.getOpenDefaultDlg(self) or "PetAttribDlg"
end

return PetTabDlg
