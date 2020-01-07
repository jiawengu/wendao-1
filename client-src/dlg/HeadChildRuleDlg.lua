-- HeadChildRuleDlg.lua
-- Created by lixh Apr/11/2019
-- 点击娃娃头像弹出的状态信息界面

local HeadChildRuleDlg = Singleton("HeadChildRuleDlg", Dialog)

function HeadChildRuleDlg:init(data)
    self:setKidInfo(data)
end

function HeadChildRuleDlg:setKidInfo(data)
    local kid = HomeChildMgr:getFightKid()
    if not kid then return end

    local life, max_life = 0,0
    local mana, max_mana = 0,0

    max_life = kid:queryInt("max_life")
    max_mana = kid:queryInt("max_mana")

    self:setLabelText("LifeLabel", string.format(CHS[2000006], data.curPetLife, max_life), "ChildRulePanel")
    self:setLabelText("ManaLabel", string.format(CHS[2000007], data.curPetMana, max_mana), "ChildRulePanel")

    local rect = data.node:getBoundingBox()
    local pt = data.node:convertToWorldSpace(cc.p(0, 0))
    self.root:setAnchorPoint(0, 0)
    local rootSize = self.root:getContentSize()
    self:setPosition(cc.p(pt.x - rootSize.width + data.node:getContentSize().width + 5, pt.y - rootSize.height))
end

return HeadChildRuleDlg
