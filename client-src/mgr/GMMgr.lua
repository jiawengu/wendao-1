-- GMMgr.lua
-- Created by songcw Feb/24/2016
-- GM管理器

GMMgr = Singleton()

-- 权限配置表
local permissions = {
    [GM_LIMITS.GA]  = {[CHS[3004040]] = 1,
                       [CHS[4300045]] = 1,
					   [CHS[4400017]] = 1,
                       },
    [GM_LIMITS.GA1] = {[CHS[3004041]] = 1,
                       [CHS[3004042]] = 1,
                       [CHS[4300047]] = 1,
                       [CHS[4300048]] = 1,
                       [CHS[3004043]] = 1,
                       [CHS[3004044]] = 1,
                       [CHS[3004045]] = 1,
                       [CHS[3004046]] = 1,
                       [CHS[3004047]] = 1,
                       [CHS[3004048]] = 1,
                       [CHS[3004049]] = 1,
                       [CHS[3004040]] = 1,
                       [CHS[4300044]] = 1,
                       [CHS[4300045]] = 1,
                       [CHS[4300114]] = 1,
					   [CHS[4400017]] = 1,
                       [CHS[5420263]] = 1,
                      },
    [GM_LIMITS.GA2] = {[CHS[3004041]] = 1,
                       [CHS[3004042]] = 1,
                       [CHS[4300047]] = 1,
                       [CHS[4300048]] = 1,
                       [CHS[3004044]] = 1,
                       [CHS[3004045]] = 1,
                       [CHS[3004046]] = 1,
                       [CHS[3004049]] = 1,
                       [CHS[3004040]] = 1,
                       [CHS[4300044]] = 1,
                       [CHS[4300045]] = 1,
                       [CHS[4300046]] = 1,
					   [CHS[4400017]] = 1,
                       [CHS[5420263]] = 1,
                      },
    [GM_LIMITS.GA3] = {[CHS[3004041]] = 1,
                       [CHS[3004042]] = 1,
                       [CHS[4300047]] = 1,
                       [CHS[4300048]] = 1,
                       [CHS[3004043]] = 1,
                       [CHS[3004044]] = 1,
                       [CHS[3004045]] = 1,
                       [CHS[3004046]] = 1,
                       [CHS[3004047]] = 1,
                       [CHS[3004048]] = 1,
                       [CHS[3004049]] = 1,
                       [CHS[3004040]] = 1,
                       [CHS[4300044]] = 1,
                       [CHS[4300045]] = 1,
                       [CHS[4300046]] = 1,
                       [CHS[4300114]] = 1,
					   [CHS[4400017]] = 1,
                       [CHS[5420263]] = 1,
                      },
    [GM_LIMITS.GB] = {[CHS[3004041]] = 1,
                       [CHS[3004042]] = 1,
                       [CHS[4300047]] = 1,
                       [CHS[4300048]] = 1,
                       [CHS[3004043]] = 1,
                       [CHS[3004044]] = 1,
                       [CHS[3004045]] = 1,
                       [CHS[3004046]] = 1,
                       [CHS[3004047]] = 1,
                       [CHS[3004048]] = 1,
                       [CHS[3004049]] = 1,
                       [CHS[3004040]] = 1,
                       [CHS[4300044]] = 1,
                       [CHS[4300045]] = 1,
                       [CHS[4300046]] = 1,
                       [CHS[4300114]] = 1,
					   [CHS[4400017]] = 1,
                       [CHS[5420263]] = 1,
                      },
    [GM_LIMITS.GC] = {[CHS[3004041]] = 1,
                        [CHS[3004042]] = 1,
                        [CHS[4300047]] = 1,
                        [CHS[4300048]] = 1,
                        [CHS[3004050]] = 1,
                        [CHS[4300049]] = 1,
                        [CHS[3004043]] = 1,
                        [CHS[3004044]] = 1,
                        [CHS[3004045]] = 1,
                        [CHS[3004046]] = 1,
                        [CHS[3004047]] = 1,
                        [CHS[3004048]] = 1,
                        [CHS[3004049]] = 1,
                        [CHS[3004040]] = 1,
                        [CHS[4300044]] = 1,
                        [CHS[4300045]] = 1,
                        [CHS[4300046]] = 1,
                        [CHS[4300114]] = 1,
                        [CHS[4400017]] = 1,
                        [CHS[5420263]] = 1,
                        [CHS[4300369]] = 1,
                    },
    [GM_LIMITS.GD] = {[CHS[3004041]] = 1,
                        [CHS[3004042]] = 1,
                        [CHS[4300047]] = 1,
                        [CHS[4300048]] = 1,
                        [CHS[3004050]] = 1,
                        [CHS[4300049]] = 1,
                        [CHS[3004043]] = 1,
                        [CHS[3004044]] = 1,
                        [CHS[3004045]] = 1,
                        [CHS[3004046]] = 1,
                        [CHS[3004047]] = 1,
                        [CHS[3004048]] = 1,
                        [CHS[3004049]] = 1,
                        [CHS[3004040]] = 1,
                        [CHS[4300044]] = 1,
                        [CHS[4300045]] = 1,
                        [CHS[4300046]] = 1,
                        [CHS[4300114]] = 1,
                        [CHS[4400017]] = 1,
                        ["配置属性"] = 1,
                        [CHS[5420263]] = 1,
                        [CHS[4300369]] = 1,
                    },
    [GM_LIMITS.G1] = {[CHS[3004040]] = 1},
    [GM_LIMITS.G2] = {[CHS[3004040]] = 1},
    [GM_LIMITS.G3] = {[CHS[3004041]] = 1,
                        [CHS[3004042]] = 1,
                        [CHS[3004049]] = 1,
                        [CHS[3004040]] = 1,
                    },
    [GM_LIMITS.G4] = {[CHS[3004041]] = 1,
                        [CHS[3004042]] = 1,
                        [CHS[3004050]] = 1,
                        [CHS[3004043]] = 1,
                        [CHS[3004044]] = 1,
                        [CHS[3004045]] = 1,
                        [CHS[3004046]] = 1,
                        [CHS[3004047]] = 1,
                        [CHS[3004048]] = 1,
                        [CHS[3004049]] = 1,
                        [CHS[3004040]] = 1,
                        [CHS[4300047]] = 1,
                        [CHS[4300048]] = 1,
                        [CHS[4300114]] = 1,
                        [CHS[4300044]] = 1,
                        [CHS[5420263]] = 1,
                    },
}

GMMgr.mePrivilege = 0

-- 是否是GM
function GMMgr:isGM()
    if GMMgr.mePrivilege > 1 then
        return true
    end

    return false
end

-- 是否是GM
function GMMgr:isGMByPrivilege(privilege)
    if not privilege then return false end

    if privilege > 1 then
        return true
    end

    return false
end

-- 切换隐身状态
function GMMgr:cmdChangeShadowState()
    gf:CmdToServer("CMD_ADMIN_SHADOW_SELF", {})
end

-- 警告玩家
function GMMgr:cmdWainingPlayer(name, gid, title, content, day)
    if title == "" then title = CHS[3004051] end
    gf:CmdToServer("CMD_ADMIN_WARN_PLAYER", {name = name, gid = gid, title = title, content = content, valid_day = day})
end

-- 踢玩家下线
function GMMgr:cmdKickOffPlayer(name)
    gf:CmdToServer("CMD_ADMIN_KICKOFF", {name = name})
end

-- 禁言玩家
function GMMgr:cmdShutChannelPlayer(name, gid, ti, channel, reason)
    gf:CmdToServer("CMD_ADMIN_SHUT_CHANNEL", {name = name, gid = gid, ti = ti, channel = channel, reason = reason})
end

-- 封闭账号
function GMMgr:cmdBlockAccount(account, ti, reason, remove_goods)
    gf:CmdToServer("CMD_ADMIN_BLOCK_ACCOUNT", {account = account, ti = ti, reason = reason, remove_goods = remove_goods})
end

-- 封闭角色
function GMMgr:cmdBlockUser(name, gid, ti, reason, remove_goods)
    gf:CmdToServer("CMD_ADMIN_BLOCK_USER", {name = name, gid = gid, ti = ti, reason = reason, remove_goods = remove_goods})
end

-- 禁闭
function GMMgr:cmdThrowInJail(name, gid, ti, reason)
    gf:CmdToServer("CMD_ADMIN_THROW_IN_JAIL", {name = name, gid = gid, ti = ti, reason = reason})
end

-- 监听
function GMMgr:cmdSniffAT(name)
    local gmDlgs = {"GMAccountListDlg", "GMAccountManageDlg", "GMBlockAccountDlg",
        "GMBlockUserDlg", "GMConfirmDlg", "GMDebugTipsDlg", "GMForbidSpeakingDlg", "CharPortraitDlg",
        "GMManageDlg", "GMRestrictUserDlg", "GMUserListDlg", "GMUserManageDlg", "GMWarningDlg", "CharMenuContentDlg"
    }

    for i = 1, #gmDlgs do
        DlgMgr:closeDlg(gmDlgs[i])
    end

    -- 监听某玩家，name = 玩家名字。解除监听的时候name == ""
    gf:CmdToServer("CMD_ADMIN_SNIFF_AT", {name = name})
end

-- 账号查询
function GMMgr:cmdQueryByAccount(account, type)
    gf:CmdToServer("CMD_ADMIN_QUERY_ACCOUNT", {account = account, type = type})
end

-- 角色名称查询
function GMMgr:cmdQueryByPlayer(name, type)
    gf:CmdToServer("CMD_ADMIN_QUERY_PLAYER", {name = name, type = type})
end

-- 终止战斗
function GMMgr:cmdStopCombat(gid)
    gf:CmdToServer("CMD_ADMIN_STOP_COMBAT", {gid = gid})
end

-- 接近目标
function GMMgr:cmdMoveToTarget(gid)
    gf:CmdToServer("CMD_ADMIN_MOVE_TO_TARGET", {gid = gid})
end

-- 查询进程
function GMMgr:cmdSearchProcess(gid)
    gf:CmdToServer("CMD_ADMIN_SEARCH_PROCESS", {gid = gid})
end

-- 查询本线
function GMMgr:cmdQueryLocalLine()
    gf:CmdToServer("CMD_ADMIN_QUERY_LOCAL_LINE", {})
end

-- 查询本地图
function GMMgr:cmdQueryLocalMap()
    gf:CmdToServer("CMD_ADMIN_QUERY_LOCAL_MAP", {})
end

-- 封闭Mac
function GMMgr:cmdBlockMac(mac, interval, reason)
    gf:CmdToServer("CMD_ADMIN_BLOCK_MAC", {mac = mac, interval = interval, reason = reason})
end

-- 查询NPC
function GMMgr:cmdQueryNPC()
    gf:CmdToServer("CMD_ADMIN_QUERY_NPC", {})
end

-- 查询自己是否有权限by事件
function GMMgr:isCanDo(something)
    if permissions[GMMgr.mePrivilege] and permissions[GMMgr.mePrivilege][something] then
        return true
    end

    return false
end

-- 是否处于监听状态
function GMMgr:isStaticMode()
    return (Me:queryBasicInt("static_mode") == 1)
end

-- 角色名称查询
function GMMgr:MSG_ADMIN_QUERY_ACCOUNT(data)
    if data.count <= 0 then
        gf:ShowSmallTips(CHS[4300005])
        return
    end
    local dlg = DlgMgr:openDlg("GMAccountListDlg")
    dlg:setUserList(data.info)
end

function GMMgr:MSG_ADMIN_QUERY_PLAYER(data)
    if data.count <= 0 then
        gf:ShowSmallTips(CHS[4300005])
        return
    end

    local dlg = DlgMgr:getDlgByName("GMUserManageDlg")
    if dlg then
        local dlgData = dlg:getUser()
        for i = 1, #data.info do
            if dlgData.name == data.info[i].name then
                dlgData.mac = data.info[i].mac
                dlg:setUser(dlgData)
            end
        end
    else
        local dlg2 = DlgMgr:openDlg("GMUserListDlg")
        dlg2:setUserList(data.info)
    end
end

function GMMgr:MSG_ADMIN_QUERY_NPC(data)
    local dlg = DlgMgr:openDlg("GMNPCListDlg")
    dlg:setData(data)
end

function GMMgr:setEditBoxValue(dlg, ctlName, value, color, root)
    local panel = dlg:getControl(ctlName, nil, root)
    local eb = panel:getChildByName("EditBox")
    eb:setText(tostring(value))
    if color then
        eb:setFontColor(color)
    end
end

function GMMgr:getEditBoxValue(dlg, ctlName, root)
    local panel = dlg:getControl(ctlName, nil, root)
    local eb = panel:getChildByName("EditBox")
    return eb:getText()
end


-- 会默认该对话框的self.ctrlNameEB
function GMMgr:bindEditBoxForGM(dlg, ctrlName, downCallBack, limitCondition, panel, defalueCb)

    dlg[ctrlName .. "EB"] = dlg:createEditBox(ctrlName, panel, nil, function(sender, type, eb)
        if type == "changed" then
            local minValue = dlg.VALUE_RANGE[ctrlName].MIN
            local maxValue = dlg.VALUE_RANGE[ctrlName].MAX

            local value = tonumber(eb:getText())
            if not value then
                gf:ShowSmallTips(CHS[4100485])
                eb:setText(tostring(dlg.VALUE_RANGE[ctrlName].DEF))
                eb:setFontColor(COLOR3.WHITE)

                if defalueCb then
                    defalueCb(dlg, eb, dlg.VALUE_RANGE[ctrlName].DEF)
                end
                return
            end

            if value < minValue or value > maxValue then
                gf:ShowSmallTips(string.format(CHS[4100486], minValue, maxValue))
                eb:setText(tostring(math.min(dlg.VALUE_RANGE[ctrlName].DEF, maxValue)))
                eb:setFontColor(COLOR3.WHITE)
                if defalueCb then
                    defalueCb(dlg, eb, dlg.VALUE_RANGE[ctrlName].DEF)
                end
                return
            end

            if limitCondition then
                if not limitCondition(dlg, eb, value) then
                    eb:setText(tostring(dlg.VALUE_RANGE[ctrlName].DEF))
                    eb:setFontColor(COLOR3.WHITE)
                    return
                end
            end

            if not dlg.VALUE_RANGE[ctrlName].notNeedChanegColor then
                if value > dlg.VALUE_RANGE[ctrlName].DEF then eb:setFontColor(COLOR3.GREEN) end
                if value < dlg.VALUE_RANGE[ctrlName].DEF then eb:setFontColor(COLOR3.RED) end
                if value == dlg.VALUE_RANGE[ctrlName].DEF then eb:setFontColor(COLOR3.WHITE) end
            end

            if downCallBack then
                downCallBack(dlg, eb, value)
            end
        end
    end)

    local minValue = dlg.VALUE_RANGE[ctrlName].MIN
    local maxValue = dlg.VALUE_RANGE[ctrlName].MAX

    dlg[ctrlName .. "EB"]:setText(tostring(dlg.VALUE_RANGE[ctrlName].DEF))
    dlg[ctrlName .. "EB"]:setFont(CHS[3003794], 21)
end



function GMMgr:bindEditField(dlg, ctrlName, downCallBack, limitCondition, panel)
    local minValue = dlg.VALUE_RANGE[ctrlName].MIN
    local maxValue = dlg.VALUE_RANGE[ctrlName].MAX

    local textCtrl = dlg:getControl(ctrlName, nil, panel)
    textCtrl:setText(tostring(dlg.VALUE_RANGE[ctrlName].DEF))

    textCtrl:addEventListener(function(sender, eventType)
        if ccui.TextFiledEventType.insert_text == eventType then

        elseif ccui.TextFiledEventType.delete_backward == eventType then
        elseif ccui.TextFiledEventType.attach_with_ime == eventType then
     --       sender:setText("")
        elseif ccui.TextFiledEventType.detach_with_ime == eventType then
    --        dlg:setCtrlEnabled("RefineButton", true)
   --         local ctrl = dlg:getControl("Label", nil, "RefineButton")
    --        ctrl:setColor(COLOR3.WHITE)

            local value = tonumber(sender:getStringValue())
            if not value then
                gf:ShowSmallTips(CHS[4100485])
                sender:setText(tostring(dlg.VALUE_RANGE[ctrlName].DEF))
                sender:setColor(COLOR3.WHITE)
                return
            end

            if value < minValue or value > maxValue then
                gf:ShowSmallTips(string.format(CHS[4100486], minValue, maxValue))
                sender:setText(tostring(math.min(dlg.VALUE_RANGE[ctrlName].DEF, maxValue)))
                sender:setColor(COLOR3.WHITE)
                return
            end

            if limitCondition then
                if not limitCondition(self, value) then
                    sender:setText(tostring(dlg.VALUE_RANGE[ctrlName].DEF))
                    sender:setColor(COLOR3.WHITE)
                    return
                end
            end

            if not dlg.VALUE_RANGE[ctrlName].notNeedChanegColor then
                if value > dlg.VALUE_RANGE[ctrlName].DEF then sender:setColor(COLOR3.GREEN) end
                if value < dlg.VALUE_RANGE[ctrlName].DEF then sender:setColor(COLOR3.RED) end
                if value == dlg.VALUE_RANGE[ctrlName].DEF then sender:setColor(COLOR3.WHITE) end
            end

            if downCallBack then
                downCallBack(dlg, sender)
            end
        end
    end)
end

-- 设置玩家等级
function GMMgr:setAdminLevel(level)
    gf:CmdToServer("CMD_ADMIN_SET_USER_LEVEL", {level = level})
end

-- 设置玩家属性     attrib，潜能、道行、气血、法力、物伤、法伤、防御、速度属性，以“|”分隔。
function GMMgr:setAdminAttrib(attrib)
    gf:CmdToServer("CMD_ADMIN_SET_USER_ATTRIB", {attrib = attrib})
end

-- 设置宠物等级
function GMMgr:setAdminPetLevel(petNo, petLevel)
    gf:CmdToServer("CMD_ADMIN_SET_PET_LEVEL", {petNo = petNo, petLevel = petLevel})
end

-- 设置宠物属性
function GMMgr:setAdminPetAttrib(petType, info, attrib, skills, morph, rebuild, isDianhua, godBooks, isYuhua, intimacy, isFly)
    gf:CmdToServer("CMD_ADMIN_SET_PET_ATTRIB", {petType = petType, info = info, attrib = attrib, skills = skills, morph = morph,
        rebuild = rebuild, isDianhua = isDianhua, godBooks = godBooks, isYuhua = isYuhua, intimacy = intimacy, isFly = isFly})
end

-- 生成指定装备类型
function GMMgr:setAdminMakeEquip(equipType, req_level, rebuildLevel, blue, pink, yellow, green, black, gongming)
    gf:CmdToServer("CMD_ADMIN_MAKE_EQUIPMENT", {equipType = equipType, req_level = req_level, rebuildLevel = rebuildLevel, blue = blue,
        pink = pink, yellow = yellow, green = green, black = black, gongming = gongming})
end

-- 生成指定道具、金钱
function GMMgr:setAdminMakeItem(itemName, amount)
    gf:CmdToServer("CMD_ADMIN_MAKE_ITEM", {itemName = itemName, amount = amount})
end

-- 请求打开GM-名人争霸控制
function GMMgr:openGM_MRZB_CONTROL()
    gf:CmdToServer("CMD_CSB_GM_OPEN_CONTROL", {})
end

function GMMgr:MSG_CSB_GM_REQUEST_CONTROL_INFO(data)
    DlgMgr:openDlgEx("GMCrossServiceFightDlg", data)
end

-- 请求打开GM-名人争霸控制
function GMMgr:startFightGM_MRZB()
    gf:CmdToServer("CMD_CSB_GM_START_COMBAT", {})
end

-- 请求打开GM-名人争霸控制
function GMMgr:setGM_MRZB_RESULT(result)
    gf:CmdToServer("CMD_CSB_GM_CONFIRM_COMBAT_RESULT", {result = result})
end

-- 退出控制-名人争霸控制
function GMMgr:cancleGM_MRZB_CONTROL()
    gf:CmdToServer("CMD_CSB_GM_CANCEL_CONTROL_INFO", {})
end

-- 获取GM-全民PK
function GMMgr:getQmpkGmData()
    return self.qmpkData
end

-- 请求打开GM-全民PK控制
function GMMgr:openGM_QMPK_CONTROL()
    gf:CmdToServer("CMD_CSQ_GM_OPEN_CONTROL", {})
end

-- 退出控制-全民PK
function GMMgr:cancleGM_QMPK_CONTROL()
    gf:CmdToServer("CMD_CSQ_GM_CANCEL_CONTROL", {})
end

-- GM-全民PK开始比赛
function GMMgr:startFightGM_QMPK(matchId)
    gf:CmdToServer("CMD_CSQ_GM_START_COMBAT", {matchId = matchId})
end

-- GM-全民PK比赛结果
function GMMgr:setGM_QMPK_RESULT(matchId, isOk)
    gf:CmdToServer("CMD_CSQ_GM_CONFIRM_COMBAT_RESULT", {matchId = matchId, isOk = isOk})
end

-- GM-全民PK比赛冠军
function GMMgr:setGM_QMPK_LAST_WINNER(matchId, teamId)
    gf:CmdToServer("CMD_CSQ_GM_COMMIT_WINNER", {matchId = matchId, teamId = teamId})
end

-- GM-全民PK控制数据回来
function GMMgr:MSG_CSQ_GM_REQUEST_CONTROL_INFO(data)
    table.sort(data.list, function(l, r)
        return l.matchId < r.matchId
    end)

    self.qmpkData = data
end

function GMMgr:isWarAdmin(warType)
    if self.warAdminData and self.warAdminData.warData[warType] then
        return true
    end
end

function GMMgr:MSG_MATCH_ADMIN_DATA(data)
    self.warAdminData = data
end

MessageMgr:regist("MSG_MATCH_ADMIN_DATA", GMMgr)

MessageMgr:regist("MSG_CSQ_GM_REQUEST_CONTROL_INFO", GMMgr)
MessageMgr:regist("MSG_CSB_GM_REQUEST_CONTROL_INFO", GMMgr)
MessageMgr:regist("MSG_ADMIN_QUERY_NPC", GMMgr)
MessageMgr:regist("MSG_ADMIN_QUERY_ACCOUNT", GMMgr)
MessageMgr:regist("MSG_ADMIN_QUERY_PLAYER", GMMgr)

return GiftMgr
