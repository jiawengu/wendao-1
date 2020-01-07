-- WorldBossMgr.lua
-- Created by sujl, Apr/8/2017
-- 世界BOSS管理器

WorldBossMgr = Singleton()

function WorldBossMgr:requestRankData()
    gf:CmdToServer("CMD_WORLD_BOSS_RANK", {})
end

function WorldBossMgr:requestLifeData()
    gf:CmdToServer("CMD_WORLD_BOSS_LIFE", {})
end

function WorldBossMgr:MSG_WORLD_BOSS_RANK(data)
    DlgMgr:openDlg("WorldBossRankDlg")
end

function WorldBossMgr:MSG_WORLD_BOSS_RESULT(data)
    local dlg = DlgMgr:openDlg("WorldBossResultDlg")
    dlg:setData(data)
end

MessageMgr:regist("MSG_WORLD_BOSS_RESULT", WorldBossMgr)
MessageMgr:regist("MSG_WORLD_BOSS_RANK", WorldBossMgr)