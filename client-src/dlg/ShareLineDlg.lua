-- ShareLineDlg.lua
-- Created by liuhb Mar/1/2016
-- 分享需要的其他元素

local ShareLineDlg = Singleton("ShareLineDlg", Dialog)

-- 面板颜色
local BACKIMG = {
    WHITE = 1,
    BLACK = 2,
}

-- Y坐标
local posY = 2
local posX = 10

local SHARE_TYPE_STR = {
    ["default"] = {
        ["logoAlign"] = ccui.RelativeAlign.alignParentTopLeft,
        ["disTime"] = false,
        ["NameLabel_1"] = CHS[3003626],
        ["NameLabel_2"] = "$Me",
        ["AreaLabel_1"] = CHS[3003627],
        ["AreaLabel_2"] = "$Dist",
        ["IDLabel_1"] = CHS[3003628],
        ["IDLabel_2"] = "$ID",
        ["DownLoadLabel"] = CHS[3003629],
        ["backImage"] = BACKIMG.BLACK,
    },

    -- 领取变异
    [SHARE_FLAG.GETELITEPET] = {
        ["logoAlign"] = ccui.RelativeAlign.alignParentTopRight,
        ["disTime"] = false,
        ["NameLabel_1"] = CHS[3003626],
        ["NameLabel_2"] = "$Me",
        ["AreaLabel_1"] = CHS[3003627],
        ["AreaLabel_2"] = "$Dist",
        ["IDLabel_1"] = CHS[3003628],
        ["IDLabel_2"] = "$ID",
        ["DownLoadLabel"] = CHS[3003629],
        ["backImage"] = BACKIMG.WHITE,
    },

    -- 试道王者
    [SHARE_FLAG.SHIDAOWZJL] = {
        ["logoAlign"] = ccui.RelativeAlign.alignParentTopRight,
        ["disTime"] = true,
        ["NameLabel_1"] = CHS[3003626],
        ["NameLabel_2"] = "$Me",
        ["AreaLabel_1"] = CHS[3003627],
        ["AreaLabel_2"] = "$Dist",
        ["IDLabel_1"] = CHS[3003628],
        ["IDLabel_2"] = "$ID",
        ["DownLoadLabel"] = CHS[3003629],
        ["backImage"] = BACKIMG.WHITE,
    },
}

function ShareLineDlg:init()
    -- 宽度适配
    local lineCtrl = self:getControl("InformationPanel")
    local contentSize = lineCtrl:getContentSize()
    self.root:setContentSize(cc.size(Const.WINSIZE.width / Const.UI_SCALE, Const.WINSIZE.height / Const.UI_SCALE))
    lineCtrl:setContentSize(cc.size(Const.WINSIZE.width / Const.UI_SCALE, contentSize.height))
end

function ShareLineDlg:setCurShareData(data)
    self.shareData = data
end

function ShareLineDlg:getCurShareData()
    return self.shareData
end

function ShareLineDlg:cleanup()
    self.shareData = nil
end

function ShareLineDlg:parseStr(str)
    local newStr = str
    newStr = string.gsub(newStr, "$Me", Me:getShowName() or "")
    newStr = string.gsub(newStr, "$Dist", Client:getWantLoginDistName() or "")
    newStr = string.gsub(newStr, "$ID", Me:getShowId() or "")

    return newStr
end

-- 更新数据
function ShareLineDlg:updateView(typeStr)
    local shareData = SHARE_TYPE_STR[typeStr]

    if not shareData then
        -- 取默认的值
        shareData = SHARE_TYPE_STR["default"]
    end

    -- 首先创建Logo
    local logoPath = shareData.logoPath or ResMgr.ui.atm_logo
    local logoImage = ccui.ImageView:create(logoPath, ccui.TextureResType.localType)
    self.root:addChild(logoImage)
    gf:align(logoImage, cc.size(Const.WINSIZE.width / Const.UI_SCALE, Const.WINSIZE.height / Const.UI_SCALE), shareData.logoAlign)

    -- 创建时间
    if shareData.disTime then
        local timeLabel = ccui.Text:create()
        timeLabel:setFontSize(23)
        timeLabel:setString(gf:getServerDate("%Y-%m-%d", os.time()))
        self.root:addChild(timeLabel)
        gf:align(timeLabel, cc.size(Const.WINSIZE.width / Const.UI_SCALE, Const.WINSIZE.height / Const.UI_SCALE), shareData.logoAlign)
        timeLabel:setPositionY(timeLabel:getPositionY() - logoImage:getContentSize().height * logoImage:getScale())
    end

    self:setCtrlVisible("InformationPanel", true)

    -- 然后创建面板底下图标
    self:setLabelText("NameLabel_1", self:parseStr(shareData["NameLabel_1"]))
    self:setLabelText("NameLabel_2", self:parseStr(shareData["NameLabel_2"]))
    self:setLabelText("AreaLabel_1", self:parseStr(shareData["AreaLabel_1"]))
    self:setLabelText("AreaLabel_2", self:parseStr(shareData["AreaLabel_2"]))
    self:setLabelText("IDLabel_1", self:parseStr(shareData["IDLabel_1"]))
    self:setLabelText("IDLabel_2", self:parseStr(shareData["IDLabel_2"]))
    if not ShareMgr:isOffice() then
        -- 不是官方渠道，不显示下载地址
        self:setLabelText("DownLoadLabel", "")
    else
        self:setLabelText("DownLoadLabel", self:parseStr(shareData["DownLoadLabel"]))
    end

    -- 对底下的字进行排版
    -- 最左边
    local NameLabelCtrl1 = self:getControl("NameLabel_1")
    NameLabelCtrl1:setAnchorPoint(cc.p(0, 0))
    NameLabelCtrl1:setPosition(cc.p(posX, posY))
    local NameLabelCtrl2 = self:getControl("NameLabel_2")
    NameLabelCtrl2:setAnchorPoint(cc.p(0, 0))
    NameLabelCtrl2:setPosition(cc.p(NameLabelCtrl1:getContentSize().width + NameLabelCtrl1:getPositionX(), posY))

    -- 最右边
    local downLoadLabelCtrl = self:getControl("DownLoadLabel")
    downLoadLabelCtrl:setAnchorPoint(cc.p(1, 0))
    downLoadLabelCtrl:setPosition(cc.p(Const.WINSIZE.width / Const.UI_SCALE - posX, posY))

    -- 计算中间还剩多少
    local midSize = downLoadLabelCtrl:getPositionX() - downLoadLabelCtrl:getContentSize().width
                    - (NameLabelCtrl2:getPositionX() + NameLabelCtrl2:getContentSize().width)

    local AreaLabelCtrl1 = self:getControl("AreaLabel_1")
    local AreaLabelCtrl2 = self:getControl("AreaLabel_2")
    local IdLabelCtrl1 = self:getControl("IDLabel_1")
    local IdLabelCtrl2 = self:getControl("IDLabel_2")

    -- 计算间隔
    midSize = midSize - AreaLabelCtrl1:getContentSize().width - AreaLabelCtrl2:getContentSize().width
        - IdLabelCtrl1:getContentSize().width - IdLabelCtrl2:getContentSize().width

    midSize = midSize / 3

    -- 设置位置
    AreaLabelCtrl1:setAnchorPoint(cc.p(0, 0))
    AreaLabelCtrl1:setPosition(cc.p(NameLabelCtrl2:getPositionX() + NameLabelCtrl2:getContentSize().width + midSize, posY))
    AreaLabelCtrl2:setAnchorPoint(cc.p(0, 0))
    AreaLabelCtrl2:setPosition(cc.p(AreaLabelCtrl1:getPositionX() + AreaLabelCtrl1:getContentSize().width, posY))
    IdLabelCtrl1:setAnchorPoint(cc.p(0, 0))
    IdLabelCtrl1:setPosition(cc.p(AreaLabelCtrl2:getPositionX() + AreaLabelCtrl2:getContentSize().width + midSize, posY))
    IdLabelCtrl2:setAnchorPoint(cc.p(0, 0))
    IdLabelCtrl2:setPosition(cc.p(IdLabelCtrl1:getPositionX() + IdLabelCtrl1:getContentSize().width, posY))

    -- 切换底下面板颜色
    if BACKIMG.WHITE == shareData.backImage then
        self:setCtrlVisible("BackImage", false)
        self:setCtrlVisible("BackImage_1", true)
    else
        self:setCtrlVisible("BackImage", true)
        self:setCtrlVisible("BackImage_1", false)
    end
end

return ShareLineDlg
