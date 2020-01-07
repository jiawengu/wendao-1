-- AnniversaryPetCardrewDlg.lua
-- Created by
--

local AnniversaryPetCardrewDlg = Singleton("AnniversaryPetCardrewDlg", Dialog)
local NumImg = require('ctrl/NumImg')

function AnniversaryPetCardrewDlg:init(data)

    self:bindListener("CloseImage", self.onCloseButton)

    self:setCtrlFullClient("BlackPanel")

    -- 星星
    for i = 1, 3 do
        self:setCtrlVisible("StarImage_" .. i, i <= data.bonus_level)
    end

    -- 历史最高分
    self:setLabelText("HighestNumLabel", string.format( CHS[4101200], data.hightest_socre ))

    if data.exp and data.exp ~= "" and data.exp ~= "0" then
        self:setLabelText("NumLabel_1", data.exp, "ExpPanel")
    else
        self:setLabelText("NumLabel_1", CHS[5000059], "ExpPanel")
    end

    if data.tao and data.tao ~= "0" and data.tao ~= "" then
        self:setLabelText("NumLabel_1", gf:getTaoStr(math.floor(tonumber(data.tao))) .. CHS[4100702], "DaoPanel")
    else
        self:setLabelText("NumLabel_1", CHS[5000059], "DaoPanel")
    end

    if data.item and data.item ~= "" then
        self:setLabelText("NumLabel_1", data.item .. " * 1", "ItemPanel")
    else
        self:setLabelText("NumLabel_1", CHS[5000059], "ItemPanel")
    end

    local timePanel = self:getControl('NumPanel')
    if timePanel then
        local sz = timePanel:getContentSize()
        self.numImg = NumImg.new('bfight_num', 5, false, -5)
        self.numImg:setPosition(sz.width / 2, sz.height / 2)
        self.numImg:setVisible(false)
        self.numImg:setScale(0.5, 0.5)
        timePanel:addChild(self.numImg)
        self.numImg:setPosition(sz.width / 2, sz.height / 2)
        self.numImg:setNum(data.fp_num, false)
        self.numImg:setVisible(true)
    end
end

function AnniversaryPetCardrewDlg:cleanup()
    gf:CmdToServer('CMD_2019ZNQFP_FINISH')
end

return AnniversaryPetCardrewDlg
