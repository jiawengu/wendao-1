-- LangmqgMakeDlg.lua
-- Created by songcw Mar/29/2019
-- 2019七夕，制作巧果界面

local LangmqgMakeDlg = Singleton("LangmqgMakeDlg", Dialog)

local MARTIALS = {
    --"面粉",   "鸡蛋",   "白糖",   "芝麻",   "食盐",   "温水",   "植物油"
    CHS[4101464], CHS[4101465], CHS[4101466], CHS[4101467], CHS[4101468], CHS[4101469], CHS[4101470],
}

function LangmqgMakeDlg:init()

  --  self:onDlgOpened()
end

function LangmqgMakeDlg:onDlgOpened(para)
    local dataTab = gf:split(para[1], "|")
    local max = math.max(tonumber(dataTab[1]), tonumber(dataTab[2]))
    local min = math.min(tonumber(dataTab[1]), tonumber(dataTab[2]))

    local ret = {}
    table.insert( ret, MARTIALS[max] )
    table.insert( ret, MARTIALS[min] )

    local pool = gf:deepCopy(MARTIALS)
    table.remove( pool, max)
    table.remove( pool, min)

    local rand1 = math.random( 1, #pool )
    table.insert( ret, pool[rand1] )
    table.remove( pool, rand1)

    local rand1 = math.random( 1, #pool )
    table.insert( ret, pool[rand1] )
    table.remove( pool, rand1)

    local destImage = self:getControl("DestImage")
    local x, y = destImage:getPosition()

    for i = 1, 4 do
        local image = self:getControl("Image_" .. i)
        image:loadTexture(ResMgr:getIconPathByName(ret[i]))

        local moveAct = cc.MoveTo:create(0.7, cc.p(x, y))
        local out = cc.FadeOut:create(0.3)
        local disAct = cc.CallFunc:create(function()
            local effect = ResMgr.ArmatureMagic.lmqg_zzqg
            gf:createArmatureOnceMagic(effect.name, effect.action, self:getControl("SoupImage"), function()
                self:onCloseButton()
            end, nil, nil, 110, -25)
        end)



        image:runAction(cc.Sequence:create(moveAct, cc.Spawn:create(out, disAct)))
    end
end

return LangmqgMakeDlg
