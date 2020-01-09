local useSpecialItemCallFunc = {}

-- 谦谦有礼礼包
useSpecialItemCallFunc[CHS[7150007]] = function (item)
    if InventoryMgr:getEmptyPosCount() < 1 then
        -- 包裹格子不足
        gf:ShowSmallTips(CHS[7150009])
        return true
    end

    -- 获取使用礼包后vip天数
    local vipType = Me:getVipType()
    local leftDays = Me:getVipFloatDays()
    local toDays = nil
    if vipType == 0 or vipType == 1 then
        toDays = leftDays + 30
    elseif vipType == 2 then
        toDays = leftDays + 25
    elseif vipType == 3 then
        toDays = leftDays + 20
    end

    if toDays and toDays < 1 then
        toDays = 1
    end

    if toDays > Const.MAX_VIP_DAYS then
        -- 若使用礼包后vip天数超过上限则需确认再使用
        gf:confirm(CHS[7150008],
            function ()
                gf:CmdToServer('CMD_APPLY', {pos = item.pos, amount = 1})
            end, nil)
    else
        gf:CmdToServer('CMD_APPLY', {pos = item.pos, amount = 1})
    end

    return true
end

-- 位列仙班·月卡礼包
useSpecialItemCallFunc[CHS[7150014]] = function (item)    
    if InventoryMgr:getEmptyPosCount() < 1 then
        -- 包裹格子不足
        gf:ShowSmallTips(CHS[7150009])
        return true
    end

    gf:CmdToServer('CMD_APPLY', {pos = item.pos, amount = 1})

    return true
end

-- 位列仙班·季卡礼包
useSpecialItemCallFunc[CHS[7150015]] = function (item)
    if InventoryMgr:getEmptyPosCount() < 1 then
        -- 包裹格子不足
        gf:ShowSmallTips(CHS[7150009])
        return true
    end

    gf:CmdToServer('CMD_APPLY', {pos = item.pos, amount = 1})

    return true
end

-- 位列仙班·年卡礼包
useSpecialItemCallFunc[CHS[7150016]] = function (item)
    if InventoryMgr:getEmptyPosCount() < 1 then
        -- 包裹格子不足
        gf:ShowSmallTips(CHS[7150009])
        return true
    end

    gf:CmdToServer('CMD_APPLY', {pos = item.pos, amount = 1})

    return true
end

-- 水岚缘·月卡礼包
useSpecialItemCallFunc[CHS[7120021]] = function (item)
    if GameMgr.inCombat then
        -- 战斗中不可进行此操作。
        gf:ShowSmallTips(CHS[4000223])
        return true
    end

    if InventoryMgr:getEmptyPosCount() < 1 then
        -- 包裹格子不足
        gf:ShowSmallTips(CHS[7150009])
        return true
    end

    gf:CmdToServer('CMD_APPLY', {pos = item.pos, amount = 1})

    return true
end

-- 水岚缘·季卡礼包
useSpecialItemCallFunc[CHS[7120022]] = function (item)
    if GameMgr.inCombat then
        -- 战斗中不可进行此操作。
        gf:ShowSmallTips(CHS[4000223])
        return true
    end

    if InventoryMgr:getEmptyPosCount() < 1 then
        -- 包裹格子不足
        gf:ShowSmallTips(CHS[7150009])
        return true
    end

    gf:CmdToServer('CMD_APPLY', {pos = item.pos, amount = 1})

    return true
end

-- 水岚缘·年卡礼包
useSpecialItemCallFunc[CHS[7120023]] = function (item)
    if GameMgr.inCombat then
        -- 战斗中不可进行此操作。
        gf:ShowSmallTips(CHS[4000223])
        return true
    end

    if InventoryMgr:getEmptyPosCount() < 1 then
        -- 包裹格子不足
        gf:ShowSmallTips(CHS[7150009])
        return true
    end

    gf:CmdToServer('CMD_APPLY', {pos = item.pos, amount = 1})

    return true
end

-- 礼花·万花争鸣
useSpecialItemCallFunc[CHS[5420352]] = function (item)
    repeat
        if Me:isInJail() then
            gf:ShowSmallTips(CHS[5000228])
            break
        end

        if GameMgr.inCombat then
            -- 战斗中不可进行此操作。
            gf:ShowSmallTips(CHS[4000223])
            break
        end

        if Me:isLookOn() then
            -- 观战中不可进行此操作。
            gf:ShowSmallTips(CHS[5420353])
            break
        end

        if PlayActionsMgr:isPlayLiHua() then
            -- 请等待当前礼花播放结束。
            gf:ShowSmallTips(CHS[5420354])
            break
        end

        gf:CmdToServer('CMD_APPLY', {pos = item.pos, amount = 1})
        return true
    until true

    MessageMgr:pushMsg({MSG = 0x8029, pos = item.pos, amount = 1})

    return true
end
return useSpecialItemCallFunc