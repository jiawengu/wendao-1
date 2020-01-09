-- FightTalkNoMenuDlg.lua
-- Created by chenyq Dec/13/2014
-- 战斗对话界面

local NpcDlg = require('dlg/NpcDlg')
local FightTalkNoMenuDlg = Singleton("FightTalkNoMenuDlg", NpcDlg)

function FightTalkNoMenuDlg:getCfgFileName()
    -- 与 NpcDlg 共用配置
    return ResMgr:getDlgCfg("NpcDlg");
end

function FightTalkNoMenuDlg:createMenuItem(text, id, key)
end

function FightTalkNoMenuDlg:cleanup()
    NpcDlg.cleanup(self)
    
    GFightMgr:EndCurUnit('GUnitObjWait')
end

return FightTalkNoMenuDlg
