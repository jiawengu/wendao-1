-- YiShiMgr.lua
-- Created by sujl, Apr/8/2017
-- 义士招募管理器

YiShiMgr = Singleton()

local NPC_TYPE_NAME = {
    [0] = CHS[2100067],
    [1] = CHS[2100068],
    [2] = CHS[2100069],
    [3] = CHS[2100070],
    [4] = CHS[2100071],
}

-- 清除数据
function YiShiMgr:clearData()
    self.merit = nil
    self.canRecruitNpcs = nil
    self.hasRecruitNpcs = nil
    self.impoveNpcs = nil
end

-- 根据NPC类型获取NPC
function YiShiMgr:getNpcTypeName(npcType)
    return NPC_TYPE_NAME[npcType] or ""
end

-- 处理NPC数据(可招募及已招募)
function YiShiMgr:processData(data)
    self.merit = data.merit
    self.isShowMagic = (0 == data.flag)
    self.canRecruitNpcs = data.recruit_npcs
    self.hasRecruitNpcs = data.own_npcs
end

-- 处理强化列表数据
function YiShiMgr:processImproveData(data)
    self.merit = data.merit
    self.myImproveData = {
        atk = data.atk,
        tao = data.tao,
        spd = data.spd,
        def = data.def,
        atk_count = data.atk_count,
        spd_count = data.spd_count,
        tao_count = data.tao_count,
        def_count = data.def_count,
        left_count = data.left_count,
    }
    self.improveNpcs = data.npcs
end

-- 当前军功
function YiShiMgr:getMerit()
    return self.merit or 0
end

-- 是否显示光效
function YiShiMgr:showMagic()
    return self.isShowMagic
end

-- 可雇佣义士
function YiShiMgr:getCanRecruitNpcs(atkType)
    local npcs = self.canRecruitNpcs or {}
    if not atkType then return npcs end

    local ret = {}
    for i = 1, #npcs do
        if npcs[i].atk_type == atkType then
            table.insert(ret, npcs[i])
        end
    end

    return ret
end

-- 获取强化列表
function YiShiMgr:getImproveNpcs()
    return self.improveNpcs or {}
end

function YiShiMgr:getMyImproveData()
    return self.myImproveData
end

-- 增加义士
function YiShiMgr:insertNpc(data)
    if not self.hasRecruitNpcs then self.hasRecruitNpcs = {} end
    table.insert(self.hasRecruitNpcs, data.npc)
end

-- 删除义士
function YiShiMgr:removeNpc(npcId)
    local npcs = self:getHasRecruitNpcs()
    for i = 1, #npcs do
        if npcs[i].npc_id == npcId then
            table.remove(npcs, i)
            break
        end
    end

    self.hasRecruitNpcs = npcs
end

-- 已雇佣义士
function YiShiMgr:getHasRecruitNpcs()
    return self.hasRecruitNpcs or {}
end

-- 更新强化信息
function YiShiMgr:updateImproveData(data)
    self.merit = data.merit
    local npc = data.npc
    local npcs = self:getImproveNpcs()
    for i = 1, #npcs do
        if npcs[i].npc_id == npc.npc_id then
            npcs[i] = npc
            break
        end
    end
    self.impoveNpcs = npcs
end

-- 招募
function YiShiMgr:doRecruit(npc)
    if #self:getHasRecruitNpcs() >= 4 then
        gf:ShowSmallTips(CHS[2000238])
        return
    end

    if self:getMerit() < npc.merit then
        gf:ShowSmallTips(CHS[2000239])
        return
    end

    if npc then
        -- 固定招募
        local hasNpcs = self:getHasRecruitNpcs()
        for i = 1, #hasNpcs do
            if hasNpcs[i].npc_name == npc.npc_name then
                gf:ShowSmallTips(CHS[2000240])
                return
            end
        end
    end

    if npc and npc.npc_name == CHS[2000227] then
        gf:CmdToServer('CMD_YISHI_RECRUIT', { npc_name = ""})
    else
        gf:CmdToServer('CMD_YISHI_RECRUIT', { npc_name = npc.npc_name or ""})
    end
end

-- 辞退义士
function YiShiMgr:doDismiss(npc)
    gf:confirm(string.format(CHS[2000241], npc.npc_name), function()
        gf:CmdToServer('CMD_YISHI_DISMISS', { npc_id = npc.npc_id })
    end)
end

-- 强化义士
function YiShiMgr:doImporve(data)
end

-- 获取玩家状态
function YiShiMgr:getPlayerStatus()
    return self.playStatus
end

-- 切换状态
function YiShiMgr:switchStatus()
    local newStatus
    if 0 == self:getPlayerStatus() then
        newStatus = 1
    else
        newStatus = 0
    end

    gf:CmdToServer("CMD_YISHI_SWITCH_STATUS", {status = newStatus})
end

function YiShiMgr:MSG_YISHI_RECRUIT_DIALOG(data)
    self:processData(data)
    local dlg = DlgMgr:openDlg("NPCRecruitDlg")
    dlg:setDlgType(data.mode)
end

function YiShiMgr:MSG_YISHI_DISMISS_RESULT(data)
    self:removeNpc(data.npc_id)
end

function YiShiMgr:MSG_YISHI_RECRUIT_RESULT(data)
    self.merit = data.merit
    self:insertNpc(data)
end

function YiShiMgr:MSG_YISHI_IMPROVE_DIALOG(data)
    self:processImproveData(data)

    DlgMgr:openDlg("NPCSupplyDlg")
end

function YiShiMgr:MSG_YISHI_IMPROVE_RESULT(data)
    self.merit = data.left_merit
    local npc
    local found
    for i = 1, #self.improveNpcs do
        npc = self.improveNpcs[i]
        if npc.npc_id == data.npc.npc_id then
            self.improveNpcs[i] = data.npc
            found = true
            break
        end
    end

    if not found then
        self.myImproveData = {
            atk = data.npc.atk,
            tao = data.npc.tao,
            spd = data.npc.spd,
            def = data.npc.def,
            atk_count = data.npc.atk_count,
            spd_count = data.npc.spd_count,
            tao_count = data.npc.tao_count,
            def_count = data.npc.def_count,
            left_count = data.npc.left_count,
        }
    end
end

function YiShiMgr:MSG_YISHI_IMPROVE_PREVIEW(data)
end

function YiShiMgr:MSG_YISHI_EXCHANGE_DIALOG(data)
    self.merit = data.merit
    local dlg = DlgMgr:openDlg("JungongShopDlg")
    dlg:setInfo({ count = data.count, items = data.goods })
end

function YiShiMgr:MSG_YISHI_EXCHANGE_RESULT(data)
    self.merit = data.merit
end

function YiShiMgr:MSG_YISHI_SEARCH_RESULT(data)
end

function YiShiMgr:MSG_YISHI_PLAYER_STATUS(data)
    self.playStatus = data.status
end


MessageMgr:regist("MSG_YISHI_DISMISS_RESULT", YiShiMgr)
MessageMgr:regist("MSG_YISHI_RECRUIT_DIALOG", YiShiMgr)
MessageMgr:regist("MSG_YISHI_RECRUIT_RESULT", YiShiMgr)
MessageMgr:regist("MSG_YISHI_IMPROVE_DIALOG", YiShiMgr)
MessageMgr:regist("MSG_YISHI_IMPROVE_RESULT", YiShiMgr)
MessageMgr:regist("MSG_YISHI_IMPROVE_PREVIEW", YiShiMgr)
MessageMgr:regist("MSG_YISHI_EXCHANGE_DIALOG",YiShiMgr)
MessageMgr:regist("MSG_YISHI_EXCHANGE_RESULT",YiShiMgr)
MessageMgr:regist("MSG_YISHI_SEARCH_RESULT", YiShiMgr)
MessageMgr:regist("MSG_YISHI_PLAYER_STATUS", YiShiMgr)