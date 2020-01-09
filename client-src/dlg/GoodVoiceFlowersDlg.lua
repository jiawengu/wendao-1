-- GoodVoiceFlowersDlg.lua
-- Created by
--

local GoodVoiceFlowersDlg = Singleton("GoodVoiceFlowersDlg", Dialog)

local YJX_MONEY = 100

local FLOWER_DESC = {
    [CHS[5400278]] = CHS[4200704],
    [CHS[5400280]] = CHS[4200705],
}

function GoodVoiceFlowersDlg:init(data)
    self:bindListener("GiveButton", self.onKNXGiveButton, "FlowerPanel1")
    self:bindListener("GiveButton", self.onYJXGiveButton, "FlowerPanel3")

    self:bindFlower(CHS[5400278], "FlowerPanel1")
    self:bindFlower(CHS[5400280], "FlowerPanel3")

    self.data = data

    local myData = GoodVoiceMgr.myVoiceData
    self:setLabelText("CostLabel", CHS[4200666] .. myData.carnation_num, "FlowerPanel1")

    local goldStr = gf:getArtFontMoneyDesc(YJX_MONEY)
    self:setNumImgForPanel("CostPanel", ART_FONT_COLOR.DEFAULT, goldStr, false, LOCATE_POSITION.CENTER, 21, "FlowerPanel3")
end

function GoodVoiceFlowersDlg:onKNXGiveButton(sender, eventType)
    local timeData = GoodVoiceMgr.seasonData
    if gf:getServerTime() > timeData.canvass_end then

        if gf:getServerTime() > timeData.final_election_start then
            gf:ShowSmallTips(CHS[4300506])   -- gf:ShowSmallTips("总选阶段无法献花，道友可前往#R天墉城#n#Y妙音仙子#n处查看晋级作品的评审情况！")
        else
            gf:ShowSmallTips(CHS[4200655])   -- gf:ShowSmallTips("当前阶段无法献花。")
        end
        return
    end
    gf:CmdToServer("CMD_GOOD_VOICE_GIVE_FLOWER", {voice_id = self.data.voice_id, flower = CHS[4200667]})
    self:onCloseButton()
end

function GoodVoiceFlowersDlg:showFlower(sender)
    local dlg = DlgMgr:openDlg("BonusInfoDlg")
    local rect = self:getBoundingBoxInWorldSpace(sender)
    dlg:setRewardInfo({
        imagePath = BlogMgr:getFlowerInfo()[sender.flower].icon,
        resType = ccui.TextureResType.localType,
        basicInfo = {
            [1] = sender.flower
        },

        desc = FLOWER_DESC[sender.flower]
    })
    dlg.root:setAnchorPoint(0, 0)
    dlg:setFloatingFramePos(rect)
end

function GoodVoiceFlowersDlg:bindFlower(flower, rootName)
    local panel = self:getControl("PortraitPanel", nil, rootName)
    panel:setTouchEnabled(true)
    panel.flower = flower
    self:bindTouchEndEventListener(panel, self.showFlower)
end

function GoodVoiceFlowersDlg:onYJXGiveButton(sender, eventType)

    local timeData = GoodVoiceMgr.seasonData
    if gf:getServerTime() > timeData.canvass_end then

        if gf:getServerTime() > timeData.final_election_start then
            gf:ShowSmallTips(CHS[4300506])   -- gf:ShowSmallTips("总选阶段无法献花，道友可前往#R天墉城#n#Y妙音仙子#n处查看晋级作品的评审情况！")
        else
            gf:ShowSmallTips(CHS[4200655])   -- gf:ShowSmallTips("当前阶段无法献花。")
        end
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onYJXGiveButton") then
        return
    end

    gf:confirm(CHS[4200669], function ()
        -- body
        gf:CmdToServer("CMD_GOOD_VOICE_GIVE_FLOWER", {voice_id = self.data.voice_id, flower = CHS[4200668]})
        self:onCloseButton()
    end)


end

return GoodVoiceFlowersDlg
