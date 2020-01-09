-- InstructionsDlg.lua
-- Created by songcw Mar/14/2018
-- 默认通用规则说明

-- 该界面用于，不需要任何处理的说明类界面

local InstructionsDlg = Singleton("InstructionsDlg", Dialog)

function InstructionsDlg:getCfgFileName()
    return ResMgr:getDlgCfg(self.jsonFileName)
end


return InstructionsDlg
