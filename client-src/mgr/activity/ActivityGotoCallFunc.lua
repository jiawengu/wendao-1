local gotoCallFunc = {}

-- 【周】仙池温泉
gotoCallFunc[CHS[5450454]] = function (activity)
    if MapMgr:isInYuLuXianChi() then
        gf:ShowSmallTips(CHS[5450458])
        return
    end

    AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[5450459]))
end

return gotoCallFunc