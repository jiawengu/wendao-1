-- LangmqgDlg.lua
-- Created by songcw Mar/29/2019
-- 2019七夕，巧果材料

local LangmqgDlg = Singleton("LangmqgDlg", Dialog)

local MARTIALS = {
    --"面粉",   "鸡蛋",   "白糖",   "芝麻",   "食盐",   "温水",   "植物油"
    CHS[4101464], CHS[4101465], CHS[4101466], CHS[4101467], CHS[4101468], CHS[4101469], CHS[4101470],
}

function LangmqgDlg:init(data)
    self:setFullScreen()
    self:setCtrlFullClient("BlackPanel")
    self:setCtrlFullClientEx("FullPanel")

    CharMgr:doCharHideStatus(Me)

    -- 全部盖上盖子
    for i = 1, 6 do
        local panel = self:getControl("MartialPanel" .. i)
        panel:setTag(i)
        self:bindTouchEndEventListener(panel, self.onMartialButton)
        self:setImagePlist("Image", ResMgr.ui.touming, panel)
    end

    self.data = data
    self:setPlayerInfo(data)

    self.timerId = self:startSchedule(function ()
        local leftTime = data.end_time - gf:getServerTime()
        leftTime = math.max(0, leftTime)
        self:setLabelText("NumLabel", leftTime .. CHS[4010199], "TimePanel")

        if leftTime == 0 then

        end
    end)


    self:hookMsg("MSG_QIXI_2019_LMQG_REFRESH")
    self:hookMsg("MSG_QIXI_2019_LMQG_SCORE")
end


function LangmqgDlg:onMartialButton(sender)
    if not sender.canClick then
        gf:ShowSmallTips(CHS[4101471])    -- 这个食盘还没有打开，无法操作哦！
        return
    end

    gf:CmdToServer("CMD_QIXI_2019_LMQG_SELECT", {martial_no = sender:getTag()})
end


function LangmqgDlg:cleanup()
    Me:setVisible(true)
end

function LangmqgDlg:onCloseButton()
    gf:confirm(CHS[4101472], function ()
        gf:CmdToServer("CMD_QIXI_2019_LMQG_QUIT")
    end)
end

function LangmqgDlg:setPlayerInfo(data)

    local function setInfo( data, isMe, needCollectCount )
        local namePanel = isMe and "PlayerNamePanel" or "NpcNamePanel"
        local shapePanel = isMe and "PlayerBonesPanel" or "NpcBonesPanel"
        local dataPanel = isMe and "RightPanel" or "LeftPanel"

        -- 名字
        self:setLabelText("NameLabel", data.player_name, namePanel)
        -- 龙骨动画
        self:creatCharDragonBones(data.player_icon, shapePanel)
        -- 收集数量
        self:setLabelText("NumLabel", data.player_collected .. "/" .. needCollectCount, dataPanel)
        -- 收集的材料
        self:setImage("ItemImage", ResMgr:getIconPathByName(MARTIALS[data.player_material_type]), dataPanel)
    end

    for i = 1, 2 do
        setInfo(data.playerInfo[i], Me:getId() == data.playerInfo[i].player_id, data.needCollectCount)
    end
end

function LangmqgDlg:creatCharDragonBones(icon, panelName, staticDb)
    local panel = self:getControl(panelName)
    local magic = panel:getChildByName("charPortrait")

    if magic then
        if magic:getTag() == icon then
            -- 已经有了，不需要加载
            return magic
        else
            DragonBonesMgr:removeCharDragonBonesResoure(magic:getTag(), string.format("%05d", magic:getTag()))
            magic:removeFromParent()
        end
    end

    local dbMagic = DragonBonesMgr:createCharDragonBones(icon, string.format("%05d", icon))
    if not dbMagic then return end

    local magic = tolua.cast(dbMagic, "cc.Node")
    magic:setPosition(panel:getContentSize().width * 0.5, -13)
    magic:setName("charPortrait")
    magic:setTag(icon)
    panel:addChild(magic)
    magic:setRotationSkewY(180)

    if not staticDb then
        DragonBonesMgr:toPlay(dbMagic, "stand", 0)
    end

    return magic
end

function LangmqgDlg:removeAllMagic()
    local armtureMagic = ResMgr.ArmatureMagic.lmqg_dkgz

    for i = 1, 6 do
        local panel = self:getControl("MartialPanel" .. i)
        panel:stopAllActions()
        local magic = panel:getChildByName(armtureMagic.action)
        if magic then magic:removeFromParent() end

        local magic = panel:getChildByName(ResMgr.ArmatureMagic.lmqg_get.action)
        if magic then magic:removeFromParent() end


        self:setCtrlVisible("GaiziImage", true, panel)
    end
end

function LangmqgDlg:MSG_QIXI_2019_LMQG_REFRESH(data)
    self:removeAllMagic()

    local armtureMagic = ResMgr.ArmatureMagic.lmqg_dkgz


    for i = 1, data.count do
        local panel = self:getControl("MartialPanel" .. data.martials[i].pos)
        local martialName = MARTIALS[data.martials[i].type]
        self:setImage("Image", ResMgr:getIconPathByName(martialName), panel)

        self:setCtrlVisible("GaiziImage", false, panel)


        panel.martialType = data.martials[i].type
        panel.canClick = true
        gf:createArmatureOnceMagic(armtureMagic.name, armtureMagic.action, panel, function ()
            -- 2s后盖上
            performWithDelay(panel, function ()
                local armtureMagic = ResMgr.ArmatureMagic.lmqg_gsgz
                panel.canClick = false
                gf:createArmatureOnceMagic(armtureMagic.name, armtureMagic.action, panel, function ()
                    self:setImage("Image", ResMgr.ui.lmqg_gz, panel)

                    self:setCtrlVisible("GaiziImage", true, panel)
                end)
            end, 2)
        end)
    end
end

function LangmqgDlg:MSG_QIXI_2019_LMQG_SCORE(data)
   -- self:removeAllMagic()

    local panelName = "LeftPanel"
    if data.player_id == Me:getId() then panelName = "RightPanel" end
    self:setLabelText("NumLabel", data.player_collected .. "/" .. self.data.needCollectCount, panelName)



    local armtureMagic = ResMgr.ArmatureMagic.lmqg_get
    local panel = self:getControl("MartialPanel" .. data.pos)

    performWithDelay(panel, function ( )
        self:setImagePlist("Image", ResMgr.ui.touming, panel)
    end, 1)

    gf:createArmatureOnceMagic(armtureMagic.name, armtureMagic.action, panel, function ()
        local magic = gf:createCallbackMagic(ResMgr.magic.grey_fog, function ( )
            local greyMagic = panel:getChildByName(ResMgr.magic.grey_fog)
            if greyMagic then
                greyMagic:removeFromParent()
            end
        end, {blendMode = "add", scaleX = 0.8, scaleY = 0.8})

        magic:setPosition(panel:getContentSize().width * 0.5, panel:getContentSize().height * 0.5)
        magic:setName(ResMgr.magic.grey_fog)
        panel:addChild(magic)
    end)
end

return LangmqgDlg
