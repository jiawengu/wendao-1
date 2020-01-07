-- CharToBabyDlg.lua
-- Created by songcw May/03/2017
-- 真身、元婴转换界面


local CharToBabyDlg = Singleton("CharToBabyDlg", Dialog)

local TEN_SECONDS = 10000 -- 10 * 1000

function CharToBabyDlg:init()
    self:bindListener("ComfireButton", self.onComfireButton)
    
    self:setData()
    
    self:setRule()
end

function CharToBabyDlg:setData()
    if Me:getChildType() == 0 then
        -- 正常情况不会走到这
        self:onCloseButton()
        return
    end    

    local leftPanel = self:getControl("LeftHeadPanel")
    local rightPanel = self:getControl("RightHeadPanel")
    
    if Me:isRealBody() then
        self:setImage("ShapeImage", ResMgr:getSmallPortrait(Me:queryBasicInt("org_icon")), leftPanel)
        self:setItemImageSize("ShapeImage", leftPanel)
        -- 人物等级使用带描边的数字图片显示
        self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, Me:queryInt("level"), false, LOCATE_POSITION.LEFT_TOP, 21, leftPanel)        
        
        self:setImage("ShapeImage", ResMgr:getSmallPortrait(Me:getChildPortrait()), rightPanel)
        self:setItemImageSize("ShapeImage", rightPanel)
        self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, Me:queryInt("upgrade/level"), false, LOCATE_POSITION.LEFT_TOP, 21, rightPanel) 
    else    
        self:setImage("ShapeImage", ResMgr:getSmallPortrait(Me:getChildPortrait()), leftPanel)
        self:setItemImageSize("ShapeImage", leftPanel)
        self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, Me:queryInt("upgrade/level"), false, LOCATE_POSITION.LEFT_TOP, 21, leftPanel)
        
        self:setImage("ShapeImage", ResMgr:getSmallPortrait(Me:queryBasicInt("org_icon")), rightPanel)
        self:setItemImageSize("ShapeImage", rightPanel)
        self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, Me:queryInt("level"), false, LOCATE_POSITION.LEFT_TOP, 21, rightPanel)
    end
end

function CharToBabyDlg:setRule()
    local panel1 = self:getControl("RulePanel1")
    local str11 = string.format(CHS[4100558], Me:getChildName(), Me:getChildName())
    self:setLabelText("RuleLabel1", str11, panel1)
    
    local str12 = string.format(CHS[4100559], Me:getChildName())
    self:setLabelText("RuleLabel2", str12, panel1)
    
    local otherStr = ""
    if Me:getChildName() == CHS[4100560] then
        otherStr = CHS[4100561]
    else
        otherStr = CHS[4100560]
    end
    local str13 = string.format(CHS[4100562], Me:getChildName(), otherStr)
    self:setLabelText("RuleLabel3", str13, panel1)
    
    local panel2 = self:getControl("RulePanel2")
    self:setLabelText("RuleLabel1", CHS[4100563], panel2)
    self:setLabelText("RuleLabel2", CHS[4100564], panel2)
    self:setLabelText("RuleLabel3", CHS[4100565], panel2)
    
    local panel3 = self:getControl("RulePanel3")
    self:setLabelText("Label1", Me:getChildName() .. CHS[4100566], panel3)
    self:setLabelText("Label2", Me:getChildName() .. CHS[4100566], panel3)
    
    self:setLabelText("RuleLabel1", string.format(CHS[4100567], Me:getChildName()), panel3)
    self:setLabelText("RuleLabel2", string.format(CHS[4100568], Me:getChildName(), Me:getChildName()), panel3)
    self:setLabelText("RuleLabel3", string.format(CHS[4100569], Me:getChildName(), Me:getChildName()), panel3)
    self:setLabelText("RuleLabel4", string.format(CHS[4100570], Me:getChildName(), Me:getChildName()), panel3)
end

function CharToBabyDlg:onComfireButton(sender, eventType)
    if Me:queryInt("level") < 110 then
        gf:ShowSmallTips(CHS[4100571])
        return
    end

    if Me:getChildType() == 0 then
        gf:ShowSmallTips(CHS[4100572])
        return
    end

    if Me.lastUpgradeTie and gfGetTickCount() - Me.lastUpgradeTie < TEN_SECONDS then
        gf:ShowSmallTips(CHS[4100573])
        return
    end  
    
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003433])
        return
    end
    
    if Me:isRealBody() then
        gf:CmdToServer("CMD_CHANGE_CHAR_UPGRADE_STATE", {state = Me:getChildType()})
    else
        gf:CmdToServer("CMD_CHANGE_CHAR_UPGRADE_STATE", {state = 0})
    end
    
    self:onCloseButton()
end

return CharToBabyDlg
