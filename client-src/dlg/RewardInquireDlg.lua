-- RewardInquireDlg.lua
-- Created by zhengjh Mar/28/2016
-- 悬赏奖励组队悬浮框

local RewardInquireDlg = Singleton("RewardInquireDlg", Dialog)
local limtLevel = 30

function RewardInquireDlg:init()
    self:align(ccui.RelativeAlign.centerInParent)
end


function RewardInquireDlg:setTeamInfo(data)
    local members = TeamMgr.members_ex
    local index = 0
    if not members or #members == 0 then
        local name
        members = {}
        name, members[1] = next(data.teamList)
    end

    if not members[1] then
        return
    end

    for i = 1, 5 do

        if members[i] then
            local member = data.teamList[members[i].name]
            if member then
                index = index + 1
                local panel = self:getControl("Panel_" .. index)
                if index == 1 then
                    if data.count == 1 then
                        if TeamMgr:getLeaderId() == Me:getId() then
                            self:setCtrlVisible("TeamleaderImage", true)
                        else
                            self:setCtrlVisible("TeamleaderImage", false)
                        end
                    else
                        self:setCtrlVisible("TeamleaderImage", true)
                    end
                end

                self:setImage("MemberImage", ResMgr:getSmallPortrait(member.icon), panel)
                self:setItemImageSize("MemberImage", panel)
                self:setCtrlVisible("EmptyImage", false, panel)
                self:setCtrlVisible("ChangePanel", true, panel)

                -- 名字
                if member.vipType > 0 then
                    self:setLabelText("TitleLabel", member.name, panel, COLOR3.CHAR_VIP_BLUE)
                else
                    self:setLabelText("TitleLabel", member.name, panel, COLOR3.GREEN)
                end

                -- 等级
                self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, member.level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)

                -- 剩余次数
                if member.level < limtLevel then
                    self:setLabelText("TitleLabel_1", string.format(CHS[6400016], limtLevel), panel, COLOR3.RED)
                else
                    self:setLabelText("TitleLabel_1", string.format(CHS[6400017], member.times), panel, COLOR3.LIGHT_WHITE)
                end

                -- 任务领取状态
                if member.status == 1 or member.status == 3 then -- 还有未领取
                    self:setCtrlVisible("NotTakenImage", true, panel)
                    self:setCtrlVisible("TakenImage", false, panel)
                elseif member.status == 2 then -- 已领取
                    self:setCtrlVisible("NotTakenImage", false, panel)
                    self:setCtrlVisible("TakenImage", true, panel)
                else
                    self:setCtrlVisible("NotTakenImage", false, panel)
                    self:setCtrlVisible("TakenImage", false, panel)
                end
            end
        else
            local panel = self:getControl("Panel_" .. i)
            self:setLabelText("TitleLabel", CHS[4300457], panel, COLOR3.GRAY)
            --self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, member.level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)
            self:removeNumImgForPanel("LevelPanel", LOCATE_POSITION.LEFT_TOP, panel)
            self:setCtrlVisible("ChangePanel", false, panel)
            self:setCtrlVisible("EmptyImage", true, panel)
        end
    end
end


return RewardInquireDlg
