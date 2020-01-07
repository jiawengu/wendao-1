-- CityFriendOperationDlg.lua
-- Created by huangzz Mar/05/2018
-- 新区域好友操作界面

local CityFriendOperationDlg = Singleton("CityFriendOperationDlg", Dialog)

local LIMIT_WORD = 20

function CityFriendOperationDlg:init()
    self:bindListener("CleanRemarksButton", self.onCleanRemarksButton)
    self:bindListener("CancelButton", self.onCancelButton)
    self:bindListener("ConfirmButton", self.onConfirmButton)

    self.charData = nil

    -- 备注
    self:bindEditFieldForSafe("InputPanel", LIMIT_WORD, "CleanRemarksButton", cc.VERTICAL_TEXT_ALIGNMENT_TOP, nil, 160)
end

function CityFriendOperationDlg:setPortrait(filePath, gid)
    if self.gid == gid then
        self:setImage("ShapeImage", filePath, self:getControl("FramePanel"))
    end
end

function CityFriendOperationDlg:setCharInfo(data)
    self.charData = data
    self.gid = data.gid
    local shapePanel = self:getControl("FramePanel")
    
    -- 头像
    self:setPortrait(ResMgr:getSmallPortrait(data.icon), data.gid)
    
    if not string.isNilOrEmpty(data.icon_img) then
        BlogMgr:assureFile("setPortrait", self.name, data.icon_img, nil, data.gid)
    end

    -- 人物等级使用带描边的数字图片显示
    -- self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 19, shapePanel)

    -- 名称
    self:setLabelText("NameLabel", data.char)
    
    -- 年龄
    if not data.age or data.age < 0 then
        self:setLabelText("AgeLabel", CHS[5400495] .. CHS[5400496])
    else
        self:setLabelText("AgeLabel", CHS[5400495] .. data.age)
    end
    
    -- 相性
    local polar = gf:getPloarByIcon(data.icon)
    self:setImagePlist("PolarImage", ResMgr:getSuitPolarImagePath(polar))

    -- 性别
    self:setImage("SexImage", ResMgr:getGenderSignByGender(data.sex))
    
    if GameMgr:getDistName() ~= data.dist_name then
        gf:addKuafLogo(shapePanel)
    else
        gf:removeKuafLogo(shapePanel)
    end

    -- 备注
    local memo = FriendMgr:getMemoByGid(data.gid)
    if memo and string.len(memo) > 0 then 
        self:setCtrlVisible("DefaultLabel", false)
        self:setInputText("TextField", memo)
        self:setCtrlVisible("CleanRemarksButton", true)
    else
        self:setCtrlVisible("DefaultLabel", true)
        self:setInputText("TextField", "")
        self:setCtrlVisible("CleanRemarksButton", false)
    end
end

function CityFriendOperationDlg:onCleanRemarksButton(sender, eventType)
    self:setInputText("TextField", "")
    sender:setVisible(false)
    self:setCtrlVisible("DefaultLabel", true)
end

function CityFriendOperationDlg:onCancelButton(sender, eventType)
    self:onCloseButton()
end

function CityFriendOperationDlg:onConfirmButton(sender, eventType)
    local inputText = self:getInputText("TextField", self.rootPanel) or ""

    -- 屏蔽敏感字
    local filtTextStr, haveFilt = gf:filtText(inputText, nil, false)
    if haveFilt then
        return
    end

    gf:CmdToServer("CMD_MODIFY_FRIEND_MEMO", {gid = self.charData.gid, memo = inputText})

    self:onCloseButton()  
end

return CityFriendOperationDlg
