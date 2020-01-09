-- BatteryAndWifiMgr.lua
-- created by zhengjh Jan/11/2016
-- 挑战掌门

ChallengeLeaderMgr = Singleton()

-- data.para para == 1 查看掌门信息   para == 2 修改掌门签名
function ChallengeLeaderMgr:operMaster(data)
	gf:CmdToServer("CMD_OPER_MASTER",data)
end

-- 掌门信息
function ChallengeLeaderMgr:MSG_MASTER_INFO(data)
    if not DlgMgr.dlgs["ChallengingLeaderDlg"] then
        local dlg = DlgMgr:openDlg("ChallengingLeaderDlg")
        dlg:setLeaderInfo(data)
    end
end

MessageMgr:regist("MSG_MASTER_INFO", ChallengeLeaderMgr)