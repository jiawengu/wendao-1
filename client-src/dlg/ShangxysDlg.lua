-- ShangxysDlg.lua
-- Created by songcw Aug/23/2018
-- 2019年寒假活动之赏雪吟诗 答题界面

local ShangxysDlg = Singleton("ShangxysDlg", Dialog)

local JiaoSx1Dlg = require('dlg/JiaoSx1Dlg')
local ShangxysDlg = Singleton("ShangxysDlg", JiaoSx1Dlg)


function ShangxysDlg:init(data)
    self:setCtrlFullClient("TouchPanel")
    for i = 1, 4 do
        local btn = self:getControl("Button_" .. i)
        btn:setTag(i)
        self:bindListener("Button_" .. i, self.onButton)
    end
    self:setData(data)
end

function ShangxysDlg:onUpdate()
    if not self.endTime then return end

    -- 倒计时
    local sec = math.ceil( (self.endTime - gfGetTickCount()) / 1000 )
    if sec > 10 then
        self:setLabelText("TimeLabel", string.format( CHS[4200423],  sec), nil, COLOR3.GREEN)
    else
        self:setLabelText("TimeLabel", string.format( CHS[4200423],  sec), nil, COLOR3.RED)
    end

    -- 结束关闭
    if sec <= 0 then
        self.endTime = nil
        DlgMgr:closeDlg(self.name)
    end
end

function ShangxysDlg:onCloseButton()
    gf:confirm(CHS[4101174], function ( )
        -- body
        DlgMgr:closeDlg(self.name)
        gf:CmdToServer("CMD_CLOSE_DIALOG", {para1 = "winter_day_2019_sxys", para2 = ""})
    end)
end

function ShangxysDlg:setData(data)
    self.data = data

    --if not self.endTime then
        self.endTime = math.min( gfGetTickCount() + (data.end_ti - gf:getServerTime()) * 1000, gfGetTickCount() + 30 * 1000)
    --end

    -- 题目
    self:setLabelText("QuestionLabel", CHS[4200587] .. data.question)

    -- 选项
    for i = 1, 4 do
        local bth = self:getControl("Button_" .. i)
        bth.selectText = selectTanswer1ext
        self:setLabelText("AnswerLabel", data["answer" .. i], "Button_" .. i)
    end
end


function ShangxysDlg:onButton(sender, eventType)
    gf:CmdToServer("CMD_SXYS_ANSWER_2019", {select_num = sender:getTag()})
    DlgMgr:closeDlg(self.name)
end

return ShangxysDlg
