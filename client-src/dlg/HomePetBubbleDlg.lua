-- HomePetBubbleDlg.lua
-- Created by huangzz July/13/2017
-- 宠物食盆提示界面

local HomePetBubbleDlg = Singleton("HomePetBubbleDlg", Dialog)

function HomePetBubbleDlg:init()
    self.petPanel = self:getControl("PetPanel")
    self.petPanel:retain()
    self.petPanel:removeFromParent()
end

function HomePetBubbleDlg:getBubbleHint(icon)
    -- 生成颜色字符串控件
    local cell = self.petPanel:clone()

    self:setImage("IconImage", ResMgr:getSmallPortrait(icon), cell)

    return cell
end

function HomePetBubbleDlg:cleanup(data)
    self:releaseCloneCtrl("petPanel")
end


return HomePetBubbleDlg
