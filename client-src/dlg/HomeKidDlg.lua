-- HomeKidDlg.lua
-- Created by songcw Feb/28/2019
-- 居所标签页-居所娃娃

local HomeKidDlg = Singleton("HomeKidDlg", Dialog)

function HomeKidDlg:init()
    self:bindListener("KidInfoButton", self.onKidInfoButton)
    self:bindListener("HomeOutButton", self.onHomeOutButton)

    -- 娃娃总数
    local count = HomeChildMgr:getChildenCount()
    if count then
        self:setLabelText("NameLabel", count, "NumPanel")
    end

    -- 需要照顾
    local careCount = 0
    local data = HomeChildMgr:getChildByOrder()
    for _, child in pairs(data) do
        if child.isNeedCare == 1 then
            careCount = careCount + 1
        end
    end
    self:setLabelText("TimeLabel_1", careCount, "ComfortPanel")

    -- 跟随
    if HomeChildMgr:getFightKid() then
        self:setLabelText("TimeLabel_1", HomeChildMgr:getFightKid():getName(), "CleanPanel")
    else
        self:setLabelText("TimeLabel_1", CHS[5000059], "CleanPanel")
    end

    -- 形象
    self:setCtrlVisible("KidImage", false)
    local children = HomeChildMgr:getChildByOrderForHomeKidDlg()
    local child = children[#children]
    HomeChildMgr:setPortrait(child.id, self:getControl("KidPanel"), self, cc.p(2, -20))
end

function HomeKidDlg:onKidInfoButton(sender, eventType)
    DlgMgr:openDlg("KidInfoDlg")
    self:onCloseButton()
end

function HomeKidDlg:onHomeOutButton(sender, eventType)
end

return HomeKidDlg
