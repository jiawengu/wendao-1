-- WorldBossResultDlg.lua
-- Created by  huangzz Jan/24/2018
-- 世界BOSS 战斗结算界面

local WorldBossResultDlg = Singleton("WorldBossResultDlg", Dialog)

function WorldBossResultDlg:init()
    self:bindListener("ConfirmButton", self.onConfirmButton)
end

function WorldBossResultDlg:setData(data)
    -- 排名
    local str
    if data.new_rank == -2 then
        -- 与服务器约定new_rank为-2时，当前排名显示：正在统计中
        str = CHS[7100397] 
    else
        if data.old_rank < 0 then
            data.old_rank = data.inside_rank
        end
        
        local cRank = data.old_rank - data.new_rank
        str = data.new_rank
        if data.new_rank < 0 then
            str = CHS[5400435]
        elseif cRank > 0 then
            str = string.format(CHS[5400433], data.new_rank, cRank)
        elseif cRank < 0 then
            str = string.format(CHS[5400434], data.new_rank, -cRank)
        end
    end

    self:setColorText(str, "RankChangePanel", "NowRankPanel", nil, 13, nil, 25)
    
    -- 本次伤害
    self:setColorText(data.add_damage, "DamagePanel", "NowDamagePanel", nil, 13, nil, 25)
    
    -- 总计伤害
    self:setColorText(data.new_damage, "DamagePanel", "TotalDamagePanel", nil, 13, nil, 25)
end

function WorldBossResultDlg:onConfirmButton(sender, eventType)
    self:onCloseButton()
end

return WorldBossResultDlg
