-- BaiCPDlg.lua
-- Created by huangzz Nov/28/2018
-- 百草谱界面

local BaiCPDlg = Singleton("BaiCPDlg", Dialog)

local ITEM_INFO = {
    {name = CHS[5450377], desc = CHS[5450399], icon = 7953},
    {name = CHS[5450378], desc = CHS[5450400], icon = 7954},
    {name = CHS[5450379], desc = CHS[5450401], icon = 7955},
    {name = CHS[5450380], desc = CHS[5450402], icon = 7956},
    {name = CHS[5450381], desc = CHS[5450403], icon = 7972},
    {name = CHS[5450382], desc = CHS[5450404], icon = 7959},
    {name = CHS[5450383], desc = CHS[5450405], icon = 7961},
    {name = CHS[5450384], desc = CHS[5450406], icon = 7962},
    {name = CHS[5450385], desc = CHS[5450407], icon = 7963},
    {name = CHS[5450386], desc = CHS[5450408], icon = 7964},
    {name = CHS[5450387], desc = CHS[5450409], icon = 7965},
    {name = CHS[5450388], desc = CHS[5450410], icon = 7966},
    {name = CHS[5450389], desc = CHS[5450411], icon = 7967},
    {name = CHS[5450390], desc = CHS[5450412], icon = 7968},
    {name = CHS[5450391], desc = CHS[5450413], icon = 7970},
    {name = CHS[5450392], desc = CHS[5450414], icon = 7971},
    {name = CHS[5450393], desc = CHS[5450415], icon = 7973},
    {name = CHS[5450394], desc = CHS[5450416], icon = 7974},
    {name = CHS[5450395], desc = CHS[5450417], icon = 7975},
    {name = CHS[5450396], desc = CHS[5450418], icon = 7976},
    {name = CHS[5450397], desc = CHS[5450419], icon = 7977},
    {name = CHS[5450398], desc = CHS[5450420], icon = 7978},
}

function BaiCPDlg:init(param)
    self:bindListener("SubmitButton", self.onSubmitButton)
    self.itemPanel = self:retainCtrl("NamePanel")
    self.selectImg = self:retainCtrl("ChosenImage", self.itemPanel)

    self:setCtrlVisible("SkillImage", false, "ImagePanel")
    self:setCtrlVisible("Image_2", true, "ImagePanel")

    self.isDouc = param
    self.selectItem = nil

    self:initItemList()
end

function BaiCPDlg:onSubmitButton()
    if not self.isDouc then
        gf:ShowSmallTips(CHS[5410322])
        return
    end

    if not DlgMgr:isDlgOpened("ZhidbcDlg") then
        gf:ShowSmallTips(CHS[5410322])
        return
    end

    if not self.selectItem then
        gf:ShowSmallTips(CHS[5410323])
        return
    end

    DlgMgr:sendMsg("ZhidbcDlg", "setText", self.selectItem.name)

    self:onCloseButton()
end

function BaiCPDlg:initItemList()
    local listView = self:getControl("MenuListView")
    for i = 1, #ITEM_INFO do
        local cell = self.itemPanel:clone()
        self:setLabelText("TitleLabel", CHS[5450421] .. "  " .. ITEM_INFO[i].name, cell)
        cell.info = ITEM_INFO[i]
        self:bindTouchEndEventListener(cell, self.onItemInfo)
        listView:pushBackCustomItem(cell)
    end
end

function BaiCPDlg:onItemInfo(sender)
    local info = sender.info
    if not info then
        return
    end

    self.selectImg:removeFromParent()
    sender:addChild(self.selectImg)

    self:setCtrlVisible("SkillImage", true, "ImagePanel")
    self:setCtrlVisible("Image_2", false, "ImagePanel")
    self:setImage("SkillImage", ResMgr:getItemIconPath(info.icon), "ImagePanel")

    self:setLabelText("DescLabel", info.desc, "DescPanel")

    self.selectItem = info
end

return BaiCPDlg
