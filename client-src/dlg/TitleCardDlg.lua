-- TitleCardDlg.lua
-- Created by zhengjh Mar/12/2015
-- 称谓卡片

local TitleCardDlg = Singleton("TitleCardDlg", Dialog)

function TitleCardDlg:init()

    self.recoutcePanelSize = self.recoutcePanelSize or self:getCtrlContentSize("RecourcePanel")
    self.rootSize = self.rootSize or self.root:getContentSize()
end

function TitleCardDlg:setData(title)
    self:bindListener("TitleCardDlg", self.onCloseButton)
    -- 称谓
    local nameLabel =  self:getControl("TitleNameLabel", Const.UILabel)
    local color = CharMgr:getChengWeiColor(title)
    nameLabel:setText(CharMgr:getChengweiShowName(title))
    nameLabel:setColor(color)

    local str = CHS[6000083]..CharMgr:getChenweiResource(title)
    self:setColorText(str, "RecourcePanel", nil, nil, nil, COLOR3.LIGHT_WHITE)

    local panelSize = self:getCtrlContentSize("RecourcePanel")
    if panelSize.height > self.recoutcePanelSize.height then
        self.root:setContentSize(self.rootSize.width, self.rootSize.height + (panelSize.height - self.recoutcePanelSize.height))
        self:setLabelText("TitleRecourceLabel", "")
    else
        -- 如果只有一行，居中，那就用label
        self.root:setContentSize(self.rootSize)
        self:getControl("RecourcePanel"):removeAllChildren()

        self:setLabelText("TitleRecourceLabel", CHS[6000083]..CharMgr:getChenweiResource(title))
    end

--[[
   -- 来源
   local rescourseLabel = self:getControl("TitleRecourceLabel", Const.UILabel)
   rescourseLabel:setText(CHS[6000083]..CharMgr:getChenweiResource(title))

       --]]
end

return TitleCardDlg
