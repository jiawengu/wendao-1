-- PetCustomAssignAttribDlg.lua
-- Created by cheny Dec/26/2014
-- 宠物自定义加点

local PetCustomAssignAttribDlg = Singleton("PetCustomAssignAttribDlg", Dialog)

function PetCustomAssignAttribDlg:init()
    self:bindListener("ConAddButton", self.onConAddButton)
    self:bindListener("ConReduceButton", self.onConReduceButton)
    self:bindListener("WizAddButton", self.onWizAddButton)
    self:bindListener("WizReduceButton", self.onWizReduceButton)
    self:bindListener("StrAddButton", self.onStrAddButton)
    self:bindListener("StrReduceButton", self.onStrReduceButton)
    self:bindListener("DexAddButton", self.onDexAddButton)
    self:bindListener("DexReduceButton", self.onDexReduceButton)
    self:bindListener("ConfrimButton", self.onConfrimButton)
    self:bindListener("CancelButton", self.onCancelButton)
end

function PetCustomAssignAttribDlg:resetInfo(con, wiz, str, dex)
    if  con < 0 or wiz < 0 or str < 0 or dex < 0 or
        con + wiz + str + dex > 4 then return end

    self.conAdd = con
    self.wizAdd = wiz
    self.strAdd = str
    self.dexAdd = dex
    self.attribPoint = 4 - con - wiz - str - dex
    self:setLabelText("ConValueLabel", con)
    self:setLabelText("WizValueLabel", wiz)
    self:setLabelText("StrValueLabel", str)
    self:setLabelText("DexValueLabel", dex)
end

function PetCustomAssignAttribDlg:tryAddPoint(key, addLabel, delta)
    local value = self[key.."Add"]
    if value == nil then return false end

    -- 修正加点值
    if delta > self.attribPoint then delta = self.attribPoint end
    if delta == 0 then return false end
    if value + delta < 0 then return false end

    -- 显示加点
    value = value + delta
    self[key.."Add"] = value
    self.attribPoint = self.attribPoint - delta
    -- 设置颜色
    self:setLabelText(addLabel, value)
    return true
end

function PetCustomAssignAttribDlg:onConAddButton(sender, eventType)
    self:tryAddPoint("con", "ConValueLabel", 1)
end

function PetCustomAssignAttribDlg:onConReduceButton(sender, eventType)
    self:tryAddPoint("con", "ConValueLabel", -1)
end

function PetCustomAssignAttribDlg:onWizAddButton(sender, eventType)
    self:tryAddPoint("wiz", "WizValueLabel", 1)
end

function PetCustomAssignAttribDlg:onWizReduceButton(sender, eventType)
    self:tryAddPoint("wiz", "WizValueLabel", -1)
end

function PetCustomAssignAttribDlg:onStrAddButton(sender, eventType)
    self:tryAddPoint("str", "StrValueLabel", 1)
end

function PetCustomAssignAttribDlg:onStrReduceButton(sender, eventType)
    self:tryAddPoint("str", "StrValueLabel", -1)
end

function PetCustomAssignAttribDlg:onDexAddButton(sender, eventType)
    self:tryAddPoint("dex", "DexValueLabel", 1)
end

function PetCustomAssignAttribDlg:onDexReduceButton(sender, eventType)
    self:tryAddPoint("dex", "DexValueLabel", -1)
end

function PetCustomAssignAttribDlg:onConfrimButton(sender, eventType)
    if self.conAdd + self.wizAdd + self.strAdd + self.dexAdd ~= 4 then
        gf:ShowSmallTips(CHS[2000063])
        return
    end

    DlgMgr:sendMsg("PetAttribDlg", "setRecommendAttrib",
        self.conAdd, self.wizAdd, self.strAdd, self.dexAdd, 2)
    DlgMgr:sendMsg("PetAttribDlg", "onCustomPanel")
    DlgMgr:closeDlg("PetCustomAssignAttribDlg")
end

function PetCustomAssignAttribDlg:onCancelButton(sender, eventType)
    DlgMgr:closeDlg("PetCustomAssignAttribDlg")
end

return PetCustomAssignAttribDlg
