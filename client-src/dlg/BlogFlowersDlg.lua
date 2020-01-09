-- BlogFlowersDlg.lua
-- Created by liuhb Seq/21/2017
-- 个人空间 - 送花

local BlogFlowersDlg = Singleton("BlogFlowersDlg", Dialog)

local LMG_MONEY = 990000

local YJX_MONEY = 100

local blogHostData = nil

local FlowerInfo

function BlogFlowersDlg:init(gid)
    self:bindListener("GiveButton", self.onGiveButtonKNX, "FlowerPanel1")
    self:bindListener("GiveButton", self.onGiveButtonLMG, "FlowerPanel2")
    self:bindListener("GiveButton", self.onGiveButtonYJX, "FlowerPanel3")

    FlowerInfo = BlogMgr:getFlowerInfo()

    self.gid = gid

    -- 初始化当前界面
    self:initData()
    
    -- 博客主的数据
    blogHostData = BlogMgr:getUserDataByGid(gid)
    
    -- 玩家名
    self:setLabelText("GiveNameLabel", CHS[5400262] .. (blogHostData.name or ""))
    
    BlogMgr:requestFlowersData(gid)
    
    self:hookMsg("MSG_BLOG_FLOWER_INFO")
    self:hookMsg("MSG_BLOG_FLOWER_PRESENT")
end

function BlogFlowersDlg:showFlower(sender)
    local dlg = DlgMgr:openDlg("BonusInfoDlg")
    local rect = self:getBoundingBoxInWorldSpace(sender)
    dlg:setRewardInfo({
        imagePath = FlowerInfo[sender.flower].icon,
        resType = ccui.TextureResType.localType,
        basicInfo = {
            [1] = FlowerInfo[sender.flower].name
        },

        desc = FlowerInfo[sender.flower].desc
    })
    dlg.root:setAnchorPoint(0, 0)
    dlg:setFloatingFramePos(rect)
end

-- 初始化数据
function BlogFlowersDlg:initData(data)
    -- 蓝玫瑰消耗金钱数
    local cashStr, color = gf:getArtFontMoneyDesc(LMG_MONEY)
    self:setNumImgForPanel("CostPanel", color, cashStr, false, LOCATE_POSITION.CENTER, 21, "FlowerPanel2")
    self:bindFlower(CHS[5400279], "FlowerPanel2")
    
    -- 郁金香消耗元宝数
    local goldStr = gf:getArtFontMoneyDesc(YJX_MONEY)
    self:setNumImgForPanel("CostPanel", ART_FONT_COLOR.DEFAULT, goldStr, false, LOCATE_POSITION.CENTER, 21, "FlowerPanel3")
    self:bindFlower(CHS[5400280], "FlowerPanel3")
    
    -- 康乃馨
    self:setKNXSellOut(data and data.times1 == 1)
    self:bindFlower(CHS[5400278], "FlowerPanel1")
    
    self.flowerInfo = data
end

function BlogFlowersDlg:bindFlower(flower, rootName)
    local panel = self:getControl("PortraitPanel", nil, rootName)
    panel:setTouchEnabled(true)
    panel.flower = flower
    self:bindTouchEndEventListener(panel, self.showFlower)
end

-- 刷新康乃馨是否售完
function BlogFlowersDlg:setKNXSellOut(isSellOut)
    self:setCtrlVisible("NoneImage", isSellOut, "FlowerPanel1")
    self:setCtrlVisible("GiveButton", not isSellOut, "FlowerPanel1")
end

-- 康乃馨
function BlogFlowersDlg:onGiveButtonKNX(sender, eventType)
    -- 若当前玩家要赠送的对象是自己的空间，则予以如下弹出提示（容错）
    if blogHostData.user_gid == Me:queryBasic("gid") then
        gf:ShowSmallTips(CHS[5400273])
        return
    end

    -- 若当前玩家等级＜40级，则予以如下弹出提示（容错）
    if Me:queryBasicInt("level") < BlogMgr:getMessageLimitLevel() then
        gf:ShowSmallTips(CHS[5400267])
        return
    end

    self:setButtonsTouchEnabled(false)
    BlogMgr:requestPresentFlower(CHS[5400278], self.gid)
end

-- 蓝玫瑰
function BlogFlowersDlg:onGiveButtonLMG(sender, eventType)
    if not self.flowerInfo then
        return
    end
    
    -- 若当前玩家要赠送的对象是自己的空间，则予以如下弹出提示（容错）
    if blogHostData.user_gid == Me:queryBasic("gid") then
        gf:ShowSmallTips(CHS[5400273])
        return
    end

    -- 若当前玩家等级＜40级，则予以如下弹出提示（容错）
    if Me:queryBasicInt("level") < BlogMgr:getMessageLimitLevel() then
        gf:ShowSmallTips(CHS[5400267])
        return
    end


    -- 若今日玩家已赠送过这个空间主人≥10次蓝玫瑰花束，则给予如下弹出提示
    local leftTimes = 10 - self.flowerInfo.times2 
    if leftTimes <= 0 then
        gf:ShowSmallTips(CHS[5400274])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onGiveButtonLMG", sender, eventType) then
        return
    end
    
    local cashStr = gf:getMoneyDesc(LMG_MONEY)
    gf:confirm(string.format(CHS[5400275], cashStr, blogHostData.name, leftTimes), function() 
        self:setButtonsTouchEnabled(false)
        BlogMgr:requestPresentFlower(CHS[5400279], self.gid)
    end)
end

-- 郁金香
function BlogFlowersDlg:onGiveButtonYJX(sender, eventType)
    if not self.flowerInfo then
        return
    end

    -- 若当前玩家要赠送的对象是自己的空间，则予以如下弹出提示（容错）
    if blogHostData.user_gid == Me:queryBasic("gid") then
        gf:ShowSmallTips(CHS[5400273])
        return
    end

    -- 若当前玩家等级＜40级，则予以如下弹出提示（容错）
    if Me:queryBasicInt("level") < BlogMgr:getMessageLimitLevel() then
        gf:ShowSmallTips(CHS[5400267])
        return
    end


    -- 若今日玩家已赠送过这个空间主人≥20次郁金香花束，则给予如下弹出提示 
    local leftTimes = 20 - self.flowerInfo.times3
    if leftTimes <= 0 then
        gf:ShowSmallTips(CHS[5400276])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onGiveButtonYJX", sender, eventType) then
        return
    end
    
    local goldStr = gf:getMoneyDesc(YJX_MONEY)
    gf:confirm(string.format(CHS[5400277], goldStr, blogHostData.name, leftTimes), function() 
        self:setButtonsTouchEnabled(false)
        BlogMgr:requestPresentFlower(CHS[5400280], self.gid)
    end)
end

function BlogFlowersDlg:setButtonsTouchEnabled(enabled)
    self:setCtrlTouchEnabled("GiveButton", enabled, "FlowerPanel1")
    self:setCtrlTouchEnabled("GiveButton", enabled, "FlowerPanel2")
    self:setCtrlTouchEnabled("GiveButton", enabled, "FlowerPanel3")
end

function BlogFlowersDlg:MSG_BLOG_FLOWER_INFO(data)
    if self.gid ~= data.host_gid then
        return
    end
    
    self:setButtonsTouchEnabled(true)
    self:initData(data)
end

function BlogFlowersDlg:MSG_BLOG_FLOWER_PRESENT(data)
    if self.gid ~= data.host_gid then
        return
    end

    self:setButtonsTouchEnabled(true)
end

function BlogFlowersDlg:MSG_BLOG_CHAR_INFO(data)
    blogHostData = BlogMgr:getUserDataByGid(data.user_gid)
end

return BlogFlowersDlg
