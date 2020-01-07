-- CityInfoDlg.lua
-- Created by huangzz Feb/28/2018
-- 社交个人信息界面

local CityInfoDlg = Singleton("CityInfoDlg", Dialog)

local LOCATION_LIMIT_WORD = 8  -- 定位地址最长显示长度

local LOCATE_SPACE_TIME = 10 -- 手动定位时间间隔 10s

local locationStartTime = 0

function CityInfoDlg:init()
    self:bindListener("ChangeButton", self.onChangeSexButton, "SexPanel")
    self:bindListener("TypeButton1", self.onSelectSexButton, "SexChoosePanel")
    self:bindListener("TypeButton2", self.onSelectSexButton, "SexChoosePanel")
    self:bindListener("SexPanel", self.onChangeSexButton)
    self:bindListener("GpsButton", self.onGpsButton)
    self:bindListener("BKImage_3", self.onClickPortrait, "ShowPanel")

    self:bindFloatPanelListener("SexChoosePanel", "ChangeButton", "SexPanel")

    -- 绑定数字键盘
    -- self:bindNumInput("ChangeButton", "AgePanel")
    self:setCtrlTouchEnabled("ChangeButton", false, "AgePanel")
    self:bindNumInput("AgePanel")

    self:refreshShowPanel()

    self:autoLocate()

    self:hookMsg("MSG_LBS_CHAR_INFO")
    self:hookMsg("MSG_BLOG_CHAR_INFO")
    self:hookMsg("MSG_LBS_BLOG_ICON_IMG")
end

function CityInfoDlg:onLocationFunc(result, type)
    if result == 0 then
        gf:ShowSmallTips(CHS[5400482])
    else
        CitySocialMgr:setSuccLocateTime(gf:getServerTime())

        DlgMgr:sendMsg("CityRankingDlg", "resetAllData")
        DlgMgr:sendMsg("CityNearbyDlg", "requestNearbyInfo")

        if type == 3 then
            gf:ShowSmallTips(CHS[5410234])
        end
    end

    if not DlgMgr:isDlgOpened(self.name) then
        -- 回调回来，界面已经被关闭了，则不进行后续处理
        return
    end

    self:doWhenLocationEnd()
end

function CityInfoDlg:refreshShowPanel()
    -- 相性及名字
    self:setLabelText("NameLabel", Me:getShowName(), "ShowPanel")
    local polarPath = ResMgr:getSuitPolarImagePath(Me:queryBasicInt("polar"))
    local polarImage = self:getControl("TypeImage", nil, "ShowPanel")
    if polarImage and polarPath then
        polarImage:loadTexture(polarPath, ccui.TextureResType.plistType)
    end

    -- 等级
    self:setLabelText("LevelLabel", Me:getLevel(), "OtherInfoPanel")

    self:refreshPortrait()
    self:refreshLocation()
    self:setSexLabel(CitySocialMgr:getUserSex())
    self:setAgeLabel(CitySocialMgr:getUserAge())
end

-- 修改性别
function CityInfoDlg:onChangeSexButton(sender, eventType)
    self:setCtrlVisible("SexChoosePanel", true)
end

-- 选择性别
function CityInfoDlg:onSelectSexButton(sender, eventType)
    self:setCtrlVisible("SexChoosePanel", false)

    local name = sender:getName()
    local sex = 2
    if name == "TypeButton1" then
        sex = 1
    end

    self:setSexLabel(sex)
    if sex ~= CitySocialMgr:getUserSex() then
        gf:CmdToServer("CMD_LBS_CHANGE_GENDER", {sex = sex})
    end
end

-- 开启定位
function CityInfoDlg:onGpsButton(sender, eventType)
    local curTime = gf:getServerTime()
    if curTime - CitySocialMgr:getLastSuccLocateTime() < LOCATE_SPACE_TIME then
        gf:ShowSmallTips(CHS[5400488])
        return
    end

    self:tryStartLocate(3)
end

function CityInfoDlg:tryStartLocate(type)
    if CitySocialMgr:startLocate(self.onLocationFunc, self, type) then
        -- 定位开启成功
        self:setCtrlEnabled("GpsButton", false, "AddressPanel")
        self:setLabelText("AddressLabel", CHS[5400483] .. "   ", "AddressPanel", COLOR3.TEXT_DEFAULT)
        return true
    end
end

function CityInfoDlg:setPortrait(filePath, scale)
    local panel = self:getControl("ShapePanel", Const.UIImage, "ShowPanel")
    if panel then
        panel:removeAllChildren()
        if string.isNilOrEmpty(filePath) then return end
        local sp = cc.Sprite:create(filePath)
        if not sp then return end
        local contentSize = sp:getContentSize()
        local pSize = panel:getContentSize()
        sp:setScale(scale or (pSize.width / contentSize.width))
        sp:setPosition(cc.p(pSize.width / 2, pSize.height / 2))
        panel:addChild(sp)
    end
    self:setCtrlVisible("LoadBKImage", false, "ShowPanel")
end

-- 刷新头像显示
function CityInfoDlg:refreshPortrait()
    local path = CitySocialMgr:getIcon()
    if CitySocialMgr:isDefaultIcon() then
        self:setPortrait(path, 0.75)
    else
        self:setCtrlVisible("LoadBKImage", true, "ShowPanel")
        BlogMgr:assureFile("setPortrait", self.name, path)
    end

    self:setCtrlVisible("ExamineImage", CitySocialMgr:isReview(), "ShowPanel")
end

function CityInfoDlg:getUserData()
    return CitySocialMgr:getUserData()
end

function CityInfoDlg:uploadPortrait(filePath)
    if string.isNilOrEmpty(filePath) then return end

    filePath = string.trim(string.gsub(filePath, "\\/", "/"))
    local s = string.sub(filePath, 1, 1)
    if '{' == s then
        local data = json.decode(filePath)
        if 'save' == data.action then
            filePath = data.path
        else
            return
        end
    end

    local userData = self:getUserData()
    local dlg = DlgMgr:openDlg("BlogPhotoConfirmDlg")
    dlg:setData({gid = Me:queryBasic("gid"), name = Me:getName(), polar = Me:queryBasicInt("polar")}, filePath, self.name)
end

-- 头像上传完成
function CityInfoDlg:onFinishUploadIcon(files, uploads)
    if #files ~= #uploads then
        gf:ShowSmallTips(CHS[2000447])
        ChatMgr:sendMiscMsg(CHS[2000447])
        return
    end

    gf:CmdToServer("CMD_BLOG_CHANGE_ICON", { icon_img = uploads[1] })
end

function onCityPortraitUpload(filePath)
    DlgMgr:sendMsg("CityInfoDlg", "uploadPortrait", filePath)
end

function CityInfoDlg:doOpenPhoto(state)
    BlogMgr:comDoOpenPhoto(state, "onCityPortraitUpload")
end

-- 打开相册
function CityInfoDlg:openPhoto(state)
    if Me:queryBasicInt("level") < 70 then
        gf:ShowSmallTips(CHS[2000440])
        return
    end

    local elapse = gf:getServerTime() - CitySocialMgr:getLastIconModifyTime()
    if elapse < 30 * 60 then
        gf:ShowSmallTips(string.format(CHS[2000441], 30 - math.floor(elapse / 60)))
        return
    end

    if self:checkSafeLockRelease('doOpenPhoto', state) then
        return
    end

    self:doOpenPhoto(state)
end

-- 删除头像
function CityInfoDlg:deleteIcon()
    gf:confirm(CHS[2000442], function()
        gf:CmdToServer("CMD_BLOG_DELETE_ICON")
    end)
end

function CityInfoDlg:onClickPortrait(sender, eventType)
    local dlg = BlogMgr:showButtonList(self, sender, "showPortrait", self.name)
    local x, y = dlg.root:getPosition()
    dlg.root:setPosition(cc.p(x - 50, y + 50))
end

-- 显示性别
function CityInfoDlg:setSexLabel(sex)
    self:setLabelText("TypeLabel", gf:getGenderChs(sex), "SexPanel", COLOR3.TEXT_DEFAULT)
end

function CityInfoDlg:setAgeLabel(num)
    if num < 0 then
        self:setLabelText("TypeLabel", CHS[5400480], "AgePanel", COLOR3.GRAY)
    else
        self:setLabelText("TypeLabel", num, "AgePanel", COLOR3.TEXT_DEFAULT)
    end

    self.age = num
end

-- 数字键盘插入数字
function CityInfoDlg:insertNumber(num)
    if num <= 0 then
        num = 0
    end

    if num >= 100 then
        gf:ShowSmallTips(CHS[5400041])
        num = math.floor(num / 10)
    end

    self:setAgeLabel(num)
    self.age = num

    -- 更新键盘数据
    local dlg = DlgMgr.dlgs["SmallNumInputDlg"]
    if dlg then
        dlg:setInputValue(num)
    end
end

-- 确认修改年龄
function CityInfoDlg:comfireNumber()
    if self.age ~= CitySocialMgr:getUserAge() and self.age >= 0 then
        gf:CmdToServer("CMD_LBS_CHANGE_AGE", {age = self.age})
    end
end

-- 定位失败时对界面的处理
function CityInfoDlg:doWhenLocationEnd()
    self:setCtrlEnabled("GpsButton", true, "AddressPanel")
    self:refreshLocation()
end

-- 刷新位置信息
function CityInfoDlg:refreshLocation()
    if not CitySocialMgr:isLocating() or CitySocialMgr:getCurLocateType() == 1 then
        local location = CitySocialMgr:getLocation()
        if string.isNilOrEmpty(location) then
            self:setLabelText("AddressLabel", CHS[5400481], "AddressPanel", COLOR3.GRAY)
        else
            self:setLabelText("AddressLabel", CitySocialMgr:getLocationShowStr(location), "AddressPanel", COLOR3.TEXT_DEFAULT)
        end
    end
end

-- 切换标签或打开界面，若与上次定位差 10 分钟则自动定位
function CityInfoDlg:autoLocate()
    if CitySocialMgr:needLocate() then
        self:tryStartLocate(2)
    elseif CitySocialMgr:isLocating() and CitySocialMgr:getCurLocateType() ~= 1 then
        self:setCtrlEnabled("GpsButton", false, "AddressPanel")
        self:setLabelText("AddressLabel", CHS[5400483] .. ".  ", "AddressPanel", COLOR3.TEXT_DEFAULT)
    elseif not CitySocialMgr:hasLocation() then
        -- 地址为空时，且不在定位中，要再开启定位
        self:tryStartLocate(2)
        CitySocialMgr:setLocateTime()
    end
end

function CityInfoDlg:MSG_LBS_CHAR_INFO(data)
    self:refreshShowPanel()
end

function CityInfoDlg:MSG_BLOG_CHAR_INFO(data)
    self:refreshPortrait()
end

function CityInfoDlg:MSG_LBS_BLOG_ICON_IMG(data)
    self:refreshPortrait()
end

function CityInfoDlg:cleanup()

end

return CityInfoDlg
