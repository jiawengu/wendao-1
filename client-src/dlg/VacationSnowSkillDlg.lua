-- VacationSnowSkillDlg.lua
-- Created by 
-- 

local VacationSnowSkillDlg = Singleton("VacationSnowSkillDlg", Dialog)

local SKILL_INFO = {
    [CHS[4100891]] = {
        name = CHS[4100891], info = CHS[4100919], descript = CHS[4100920], icon = ResMgr.ui.vacation_show_skill1, oper = 1,
    },

    [CHS[4100892]] = {
        name = CHS[4100892], info = CHS[4100931], descript = CHS[4100932], icon = ResMgr.ui.vacation_show_skill2, oper = 2,
    },

    [CHS[4100894]] = {
        name = CHS[4100894], info = CHS[4100933], descript = CHS[4100934], icon = ResMgr.ui.vacation_show_skill3, oper = 2,
    },

    [CHS[4100893]] = {
        name = CHS[4100893], info = CHS[4100935], descript = CHS[4100936], icon = ResMgr.ui.vacation_show_skill4, oper = 3,
    },
    
    [CHS[5450143]] = { -- 引火
        name = CHS[5450143], info = "", descript = CHS[5450150], icon = ResMgr.ui.vacation_ysgw_skill1, oper = 1, confirmText = CHS[5450161],
    },
    [CHS[5450144]] = { -- 加热
        name = CHS[5450144], info = "", descript = CHS[5450151], icon = ResMgr.ui.vacation_ysgw_skill2, oper = 2, confirmText = CHS[5450161],
    },
    [CHS[5450145]] = { -- 炙烤
        name = CHS[5450145], info = "", descript = CHS[5450152], icon = ResMgr.ui.vacation_ysgw_skill3, oper = 3, confirmText = CHS[5450161],
    },
    [CHS[5450146]] = { -- 滴水
        name = CHS[5450146], info = "", descript = CHS[5450153], icon = ResMgr.ui.vacation_ysgw_skill4, oper = 4, confirmText = CHS[5450161],
    },
    [CHS[5450147]] = { -- 倒水
        name = CHS[5450147], info = "", descript = CHS[5450154], icon = ResMgr.ui.vacation_ysgw_skill5, oper = 5, confirmText = CHS[5450161],
    },
    [CHS[5450148]] = { -- 喷水
        name = CHS[5450148], info = "", descript = CHS[5450155], icon = ResMgr.ui.vacation_ysgw_skill6, oper = 6, confirmText = CHS[5450161],
    },
    [CHS[5450149]] = { -- 躺下
        name = CHS[5450149], info = "", descript = CHS[5450156], icon = ResMgr.ui.vacation_ysgw_skill7, oper = 7,
    },
}

function VacationSnowSkillDlg:init()
    self:bindListener("ConfirmButton", self.onConfirmButton)
    
    self.descSize = self.descSize or self:getCtrlContentSize("DescriptPanel")
    self.rootSize = self.rootSize or self.root:getContentSize()
    
    self.isCMD = false
end

function VacationSnowSkillDlg:cleanup()
    if self.isCMD then
    else
        if DlgMgr:isDlgOpened(self.parentDlg.name) then
            self.parentDlg:skillCloseCallBack()
        end
    end
end

function VacationSnowSkillDlg:setSkill(skillName, obj)
    self.parentDlg = obj
    self.skillName = skillName

    self:setImage("SkillImage", SKILL_INFO[skillName].icon)

    self:setLabelText("SkillNameLabel", skillName)

    self:setLabelText("SkillIntroLabel", SKILL_INFO[skillName].info)

    local height = self:setColorText(SKILL_INFO[skillName].descript, "DescriptPanel", nil, 5, 0, COLOR3.WHITE)
    
    local changeHeight = self.descSize.height - height
    self.root:setContentSize(self.rootSize.width, self.rootSize.height - changeHeight)
    
    if SKILL_INFO[skillName].confirmText then
        self:setLabelText("Label", SKILL_INFO[skillName].confirmText, "ConfirmButton")
    end
end
--
function VacationSnowSkillDlg:setFloatingFramePos(rect)
    if not self.root then return end
    if not rect then return end
    local x = (rect.x + rect.width * 0.5)
    local y = (rect.y + rect.height * 0.5)
    local dlgSize = self.root:getContentSize()
    dlgSize.width = dlgSize.width * Const.UI_SCALE
    dlgSize.height = dlgSize.height * Const.UI_SCALE
    local ap = self.root:getAnchorPoint()
    self.root:setAnchorPoint(0,0)
    local posX, posY, isUp
    -- 触发控件在右下
    posX = rect.x - dlgSize.width * 0.5 + rect.width * 0.5
    posY = rect.y + rect.height + 30
    isUp = true
    
    local winSize = self:getWinSize()

    -- 上下限判断    超出上下限，20单位间隔
    if isUp then
        if (posY + dlgSize.height)  > winSize.oy + winSize.height then
            -- 超出高度
            posY = (Const.WINSIZE.height - dlgSize.height - 20) * Const.UI_SCALE
        end
    else
        if posY < winSize.oy then
            posY = 20 * Const.UI_SCALE + winSize.oy
        end
    end

    -- 超出左右屏幕
    if posX < winSize.ox then
        posX = winSize.ox
    elseif posX + dlgSize.width > winSize.width + winSize.ox then
        local arrImage = self:getControl("ArrowImage")
        local arrowPx = arrImage:getPositionX()
        arrImage:setPositionX(arrowPx + (posX + dlgSize.width - winSize.width - winSize.ox))
        
        posX = winSize.width + winSize.ox - dlgSize.width
    end
    --]]

    self:setPosition(cc.p(posX, posY))
end
--]]

function VacationSnowSkillDlg:onConfirmButton(sender, eventType)
    if DlgMgr:isDlgOpened(self.parentDlg.name) then
        self.parentDlg:cmdOper(SKILL_INFO[self.skillName].oper)
    end
    
    self.isCMD = true
    self:onCloseButton()
end

return VacationSnowSkillDlg
