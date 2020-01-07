-- MessageDlg.lua
-- Created by songcw June/2/2016
-- 拜师留言界面

local MessageDlg = Singleton("MessageDlg", Dialog)

local BE_STUDENT = 1    -- 登记为徒弟
local BE_TEACHER = 2    -- 登记为师父
local TO_TEACHER = 3    --
local TO_STUDENT = 4    --
local RELATION_TEACHER_MSG = 5      -- 关系界面中师父留言
local MODIFY_MSG_FOR_TEACHER        = 6          -- 修改寻师留言
local MODIFY_MSG_FOR_STUDENT        = 7          -- 修改寻师留言

function MessageDlg:init()
    self:bindListener("CancelButton", self.onCancelButton)
    self:bindListener("ChangeButton", self.onChangeButton)
    self:bindListener("ConfrimButton", self.onConfrimButton)
    self:bindListener("CleanFieldButton", self.onCleanFieldButton)

    self:bindEditFieldForSafe("MessagePanel", 80, "CleanFieldButton", cc.VERTICAL_TEXT_ALIGNMENT_TOP, nil, true)

    self.oper_type = 0
    self.chosenMasterInfo = nil
end

function MessageDlg:setDisplay(type, info)
    self.chosenMasterInfo = info
    self:setCtrlVisible("CancelButton", false)
    self:setCtrlVisible("ChangeButton", false)
    self:setCtrlVisible("ConfrimButton", false)
    self.oper_type = type
    if type == BE_STUDENT then
        self:setCtrlVisible("ConfrimButton", true)
        self:getControl("TextField"):setPlaceHolder(CHS[4200051]) -- 我想找一个好师父
        self:setLabelText("TitleLabel_1", CHS[4200052]) -- [4200052] = "寻师留言",
        self:setLabelText("TitleLabel_2", CHS[4200052])
        self:setLabelText("TitleLabel", CHS[4200053]) -- [4200053] = "填写寻师留言信息，让更多师父了解你:",
    elseif type == BE_TEACHER then
        self:setCtrlVisible("ConfrimButton", true)
        self:getControl("TextField"):setPlaceHolder(CHS[4200054]) -- [4200054] = "我想找一个听话的徒弟。",
        self:setLabelText("TitleLabel_1", CHS[4200055])
        self:setLabelText("TitleLabel_2", CHS[4200055])
        self:setLabelText("TitleLabel", CHS[4200056])
    elseif type == TO_STUDENT then
        self:setCtrlVisible("ConfrimButton", true)
        self:setCtrlVisible("ConfrimButton", true)
        self:getControl("TextField"):setPlaceHolder(CHS[4200057]) -- "我想拜您为师。",
        self:setLabelText("TitleLabel_1", CHS[4200058])
        self:setLabelText("TitleLabel_2", CHS[4200058])
        self:setLabelText("TitleLabel", CHS[4200059]) -- [4200059] = "填写拜师留言，能让师父更快了解你:",

    elseif type == TO_TEACHER then
        self:setCtrlVisible("ConfrimButton", true)

        self:getControl("TextField"):setPlaceHolder(CHS[4200060])
        self:setLabelText("TitleLabel_1", CHS[4200061])
        self:setLabelText("TitleLabel_2", CHS[4200061])
        self:setLabelText("TitleLabel", CHS[4200062])
    elseif type == RELATION_TEACHER_MSG then
        self:setCtrlVisible("ConfrimButton", true)

        self:getControl("TextField"):setPlaceHolder(CHS[4200063])
        self:setLabelText("TitleLabel_1", CHS[4200064])
        self:setLabelText("TitleLabel_2", CHS[4200064])
        self:setLabelText("TitleLabel", CHS[4200065])
    elseif type == MODIFY_MSG_FOR_TEACHER then
        self:getControl("TextField"):setPlaceHolder("")
        self:setLabelText("TitleLabel_1", CHS[4200066]) -- [4200066] = "寻师留言",
        self:setLabelText("TitleLabel_2", CHS[4200066])
        self:setLabelText("TitleLabel", CHS[4200067]) -- [4200067] = "请对你的寻师留言进行调整:",
        self:setCtrlVisible("CancelButton", true)
        self:setCtrlVisible("ChangeButton", true)
    elseif type == MODIFY_MSG_FOR_STUDENT then
        self:getControl("TextField"):setPlaceHolder("")
        self:setLabelText("TitleLabel_1", CHS[4200068]) -- [4200068] = "寻徒留言",
        self:setLabelText("TitleLabel_2", CHS[4200068]) -- [4200068] = "寻徒留言",
        self:setLabelText("TitleLabel", CHS[4200069]) -- [4200069] = "请对你的寻徒留言进行调整",
        self:setCtrlVisible("CancelButton", true)
        self:setCtrlVisible("ChangeButton", true)
    end
end

function MessageDlg:onCancelButton(sender, eventType)
    if self.oper_type == MODIFY_MSG_FOR_STUDENT then
        local str = CHS[4200071] -- "是否确认立即撤销你的寻徒信息？",
        gf:confirm(str, function ()            
            MasterMgr:cmdCancelLookingForStudentMsg("")
            self:onCloseButton()
        end)
    else
        local str = CHS[4200070] -- "是否确认立即撤销你的寻师信息？",     
        gf:confirm(str, function ()
            MasterMgr:cmdCancelLookingForTeacherMsg("")
            self:onCloseButton()
        end)
    end
end

function MessageDlg:onChangeButton(sender, eventType)
    local str = self:getInputText("TextField")
    if str == "" then str = self:getControl("TextField"):getPlaceHolder() end
    
    if self.oper_type == MODIFY_MSG_FOR_STUDENT then
        MasterMgr:cmdModifyLookingForStudentMsg(str)
    else
        MasterMgr:cmdModifyLookingForTeacherMsg(str)
    end
    
    self:onCloseButton()
end

function MessageDlg:isMeetCondition()
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 战斗中
    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[3002257])
        return
    end

    if self.oper_type == RELATION_TEACHER_MSG then
        return true
    end

    -- 删除角色
    if 1 == Me:queryBasicInt("to_be_deleted") then
        gf:ShowSmallTips(CHS[4200072])
        return
    end

    if self.oper_type == 1 then
        -- 玩家已经有师傅
        if MasterMgr:meHasTeacher() then
            gf:ShowSmallTips(CHS[4200073])
            return
        end

        -- 玩家等级
        if Me:queryBasicInt("level") >= MasterMgr:getBeMasterLevel() then
            gf:ShowSmallTips(string.format(CHS[4200074], MasterMgr:getBeMasterLevel()))
            return
        end


    elseif self.oper_type == TO_STUDENT then
        -- 条件上层已经判断
    end

    return true
end

function MessageDlg:onConfrimButton(sender, eventType)
    if self.oper_type == 0 then return end

    if not self:isMeetCondition() then return end


    -- TMD终于可以了
    local str = self:getInputText("TextField")
    if str == "" then str = self:getControl("TextField"):getPlaceHolder() end

    local content, haveBad = gf:filtText(str)
    if haveBad then

    end

    if self.oper_type == BE_STUDENT then
        MasterMgr:cmdLookingTeacher(content)
    elseif self.oper_type == BE_TEACHER then
        MasterMgr:cmdLookingStudent(content)
    elseif self.oper_type == TO_STUDENT then
        MasterMgr:cmdBeStudent(self.chosenMasterInfo.gid, content)
    elseif self.oper_type == TO_TEACHER then
        MasterMgr:cmdBeTeacher(self.chosenMasterInfo.gid, content)
    elseif self.oper_type == RELATION_TEACHER_MSG then
        MasterMgr:modifyRelationTeacherMsg(content)
    end
    self:onCloseButton()
end

function MessageDlg:onCleanFieldButton(sender, eventType)
    self:setInputText("TextField", "")
    sender:setVisible(false)
end

return MessageDlg
