-- AchievementShareDlg.lua
-- Created by
--

local AchievementShareDlg = Singleton("AchievementShareDlg", Dialog)

function AchievementShareDlg:init(data)
    self:setFullScreen()

    self:setImage("GuardImage", AchievementMgr:getIconById(data.achieve_id))
    
    AchievementMgr:addJBCJImageByCategory(self:getControl("GuardImage"), data.category)

    local descLabelName

    if data.is_finished == 1 then
        self:setLabelText("TimeLabel", os.date("%Y-%m-%d", data.time))
        self:setCtrlVisible("TimeLabel_1", false)
        self:setCtrlVisible("DescLabel_1", false)
        self:setCtrlVisible("DescLabel", true)
        descLabelName = "DescLabel"
    else
        self:setLabelText("TimeLabel", "")
        self:setCtrlVisible("TimeLabel_1", true)
        self:setCtrlVisible("DescLabel_1", true)
        self:setCtrlVisible("DescLabel", false)
        descLabelName = "DescLabel_1"
    end

    self:setLabelText("AchieveLabel", data.point)

    self:setLabelText("PetNumberLabel", data.name)

    if data.user ~= "" then
        self:setLabelText("NameLabel", string.format(CHS[4100825], data.user)) -- "达成者：%s"
    else
        self:setLabelText("NameLabel", data.user)
    end

    if data.achieve_desc ~= "" then
        self:setLabelText(descLabelName, string.format(data.achieve_desc, data.progress_max))
    else
        local achieve = AchievementMgr:getAchieveInfoById(data.achieve_id)
        if not achieve then
            -- 有可能没有请求过数据，获取原始配置中的描述            
            achieve = AchievementMgr:getRawInfoByIdName(data.achieve_id, data.name)

            if GameMgr.isIOSReview then
                self:setLabelText(descLabelName, string.format(achieve.IOSReview_desc or achieve.achieve_desc, data.progress_max))
            else
                self:setLabelText(descLabelName, string.format(achieve.achieve_desc, data.progress_max))
            end
        else
            self:setLabelText(descLabelName, string.format(achieve.achieve_desc, data.progress_max))
        end
    end
end

return AchievementShareDlg
