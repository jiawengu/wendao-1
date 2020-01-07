-- PartyManageIconDlg.lua
-- created by sujl, Dec/21/2016
-- 帮派图标管理

local PartyManageIconDlg = Singleton("PartyManageIconDlg", Dialog)

local GridPanel = require('ctrl/GridPanel')

-- 每页显示列数、行数、总个数
local COL_PER_PAGE = 5

-- 格子的高宽
local GRID_WIDTH = 74
local GRID_HEIGHT = 74

-- 格子间的间隔
local GRID_MARGIN_WIDTH = 5
local GRID_MARGIN_HEIGHT = 4

local CLIP_WIDTH = 64
local CLIP_HEIGHT = 64
local BM_WIDTH = 48
local BM_HEIGHT = 48

local defaultPartyIcon

function PartyManageIconDlg:init()
    self:bindListener("NoteButton_1", self.onNoteButton)
    self:bindListener("UPloadButton", self.onUploadButton)
    self:bindListener("ApplyButton", self.onApplyButton)
    self:bindListener("MainBodyPanel", self.onMainBodyPanel)

    self.scrollView = self:getControl("ScrollView")
    self.scrollView:removeAllChildren()
    self.previewPanel = self:getControl("PreviewPanel")

    local titlePanel = self:getControl("TitlePanel", Const.UIPanel, self.previewPanel)
    self.tx, self.ty = titlePanel:getPosition()

    local namePanel = self:getControl("NamePanel", Const.UIPanel, self.previewPanel)
    self.nx, self.ny = namePanel:getPosition()

    -- 设置上传提示
    if gf:gfIsFuncEnabled(FUNCTION_ID.CLIP_SCALE_IMAGE) then
        self:setLabelText("NoteLabel_1", CHS[2000215], "MainBodyPanel")
    end

    -- 设置形象
    local meIcon = 0
    if Me:queryBasicInt("suit_icon") ~= 0 and gf:isShowSuit() then
        meIcon = Me:queryBasicInt("suit_icon")
    else
        meIcon = Me:queryBasicInt('icon')
    end

    local weaponIcon = 0
    local weapon = InventoryMgr:getItemsByPosArray({EQUIP.WEAPON})
    if weapon then
        local item = InventoryMgr:getItemByPos(weapon[1].pos)
        if item then
            weaponIcon = item.icon
        end
    end

    self:setPortrait("UserIconPanel", meIcon, weaponIcon, nil, nil, nil, nil, nil, Me:queryBasicInt("icon"))

    -- 仙魔光效
    self:addUpgradeMagicToCtrl("UserIconPanel", Me:queryBasicInt("upgrade/type"), nil, true)

    self:initIconList()

    if not PartyMgr:getPartyInfo() then
        PartyMgr:queryPartyInfo()
    else
        self:refreshInfo()
    end

    self:hookMsg("MSG_PARTY_INFO")
end

function PartyManageIconDlg:cleanup()
    self.filePath = nil
    self.fileOper = nil
    self.fileName = nil
end

function PartyManageIconDlg:loadData()
    if defaultPartyIcon then return end

    local cfg = require(ResMgr:getPartyIconCfgPath("PartyIconCfg.lua"))
    defaultPartyIcon = {}
    for i = 1, #cfg do
        local iconItem = {
            imgFile = ResMgr:getPartyIconPath(cfg[i]),
            fileName = cfg[i],
        }
        defaultPartyIcon[i] = iconItem
    end

    defaultPartyIcon.count = #cfg
end

-- 初始化系统帮派图标
function PartyManageIconDlg:initIconList()
    if not defaultPartyIcon then self:loadData() end

    self.scrollView:removeAllChildren()
    local contentSize = self.scrollView:getContentSize()
    local ROW_PER_PAGE = math.ceil(defaultPartyIcon.count / COL_PER_PAGE)
    local page = GridPanel.new(COL_PER_PAGE * GRID_WIDTH + GRID_MARGIN_WIDTH * (COL_PER_PAGE - 1), ROW_PER_PAGE * GRID_HEIGHT + (ROW_PER_PAGE - 1) * GRID_MARGIN_HEIGHT,
            ROW_PER_PAGE, COL_PER_PAGE, GRID_WIDTH, GRID_HEIGHT, GRID_MARGIN_HEIGHT, GRID_MARGIN_WIDTH, cc.size(64, 64))

    -- 额外设置grid上边距
    page:setGridTop(0)
    page:setData(defaultPartyIcon, 1, function(index, sender)
        self:selectIcon(ResMgr:getPartyIconPath(defaultPartyIcon[index].fileName), 2, defaultPartyIcon[index].fileName)
    end)
    self:selectIcon()

    self.scrollView:addChild(page)
    self.scrollView:setInnerContainerSize(page:getContentSize())
end

function PartyManageIconDlg:selectIcon(path, oper, fileName)
    if not path then
        local partyIcon = PartyMgr:getPartyIcon()
        if string.isNilOrEmpty(partyIcon) then
            partyIcon = PartyMgr:getPartyReviewIcon()
        end

        if string.isNilOrEmpty(partyIcon) then return end

        path = ResMgr:getPartyIconPath(partyIcon)
        if not gf:isFileExist(path) then
            path = ResMgr:getCustomPartyIconPath(partyIcon)
        end
    else
        self.fileName = fileName
        self.filePath = path
        self.fileOper = oper
    end

    self:setImage("Image_210", path, self:getControl("SelectedIconPanel", Const.UIPanel, self.previewPanel))
    self:setImageSize("Image_210", cc.size(64, 64), self:getControl("SelectedIconPanel", Const.UIPanel, self.previewPanel))
    self:setPartyIcon(path)
end

-- 设置图标
function PartyManageIconDlg:setPartyIcon(icon)
    local path = icon

    if not gf:isFileExist(path) then
        path = ResMgr:getPartyIconPath(icon)
    end

    if not gf:isFileExist(path) then
        path = ResMgr:getCustomPartyIconPath(icon)
    end

    self:setCtrlVisible("PartyImage", gf:isFileExist(path), self.previewPanel)
    self:setImage("PartyImage", path, self.previewPanel)

    local partyImage = self:getControl("PartyImage", Const.UIImage, self.previewPanel)
    if not partyImage then return end
    partyImage:ignoreContentAdaptWithSize(false)
    partyImage:setContentSize(Const.PARTYICON_SHOWSIZE)
    local imageSize = partyImage:getContentSize()
    local titlePanel = self:getControl("TitlePanel", Const.UIPanel, self.previewPanel)
    if titlePanel and titlePanel:isVisible() then
        local size = titlePanel:getContentSize()
        local x, y = titlePanel:getPosition()
        partyImage:setPosition(cc.p(self.tx - size.width / 2, self.ty))
        titlePanel:setPosition(cc.p(self.tx + imageSize.width / 2, self.ty))
    else
        local namePanel = self:getControl("NamePanel", Const.UIPanel, self.previewPanel)
        local size = namePanel:getContentSize()
        local x, y = namePanel:getPosition()
        partyImage:setPosition(cc.p(self.nx - size.width / 2, self.ny))
        namePanel:setPosition(cc.p(self.nx + imageSize.width / 2, self.ny))
    end
end

-- 设置称谓
function PartyManageIconDlg:setTitle(title)
    if string.isNilOrEmpty(title) then
        self:setCtrlVisible("TitlePanel", false, self.previewPanel)
    else
        self:setLabelText("Label_1", title, self:getControl("TitlePanel", Const.UIPanel, self.previewPanel))
        self:setLabelText("Label_2", title, self:getControl("TitlePanel", Const.UIPanel, self.previewPanel))
        self:updateLayout("TitlePanel", self.previewPanel)
        self:setCtrlVisible("TitlePanel", true, self.previewPanel)
        local titlePanel = self:getControl("TitlePanel", Const.UIPanel, self.previewPanel)
        local label = self:getControl("Label_1", nil, titlePanel)
        if titlePanel then
           titlePanel:setContentSize(label:getContentSize().width + 8, titlePanel:getContentSize().height)
        end
    end
end

-- 设置名字
function PartyManageIconDlg:setName(name)
    self:setLabelText("Label_1", name, self:getControl("NamePanel", Const.UIPanel, self.previewPanel))
    self:setLabelText("Label_2", name, self:getControl("NamePanel", Const.UIPanel, self.previewPanel))
    self:updateLayout("NamePanel", self.previewPanel)

    local namePanel = self:getControl("NamePanel", Const.UIPanel, namePanel)
    local label = self:getControl("Label_1", nil, namePanel)
    if namePanel then
       namePanel:setContentSize(label:getContentSize().width + 8, namePanel:getContentSize().height)
    end
end

-- 设置消耗建设度
function PartyManageIconDlg:setCostConstruction(value)
    self:setLabelText("CostLabel_2", value, self:getControl("ConstructionPanel", Const.UIPanel, self.previewPanel))
end

-- 设置拥有建设度
function PartyManageIconDlg:setOwnConstruction(value)
    self:setLabelText("OwnLabel_2", value, self:getControl("ConstructionPanel", Const.UIPanel, self.previewPanel))
end

-- 刷新角色信息
function PartyManageIconDlg:refreshInfo()
    local partyIcon = PartyMgr:getPartyIcon()
    self:setTitle(CharMgr:getChengweiShowName(Me:queryBasic("title")))
    self:setName(Me:getShowName())
    self:setPartyIcon(partyIcon)
    self:setCostConstruction(10000)

    local partyInfo = PartyMgr:getPartyInfo()
    self:setOwnConstruction(partyInfo and partyInfo.construct or 0)
end

function PartyManageIconDlg:onNoteButton(sender, eventType)
    if gf:gfIsFuncEnabled(FUNCTION_ID.CLIP_SCALE_IMAGE) then
        self:setCtrlVisible("OfflineRulePanel_1", true)
    else
        self:setCtrlVisible("OfflineRulePanel", true)
    end
end

function PartyManageIconDlg:onUploadButton(sender, eventType)
    repeat
        if CHS[4000153] ~= PartyMgr:getPartyJob() then
            gf:ShowSmallTips(CHS[2000202])
            break
        end

        local review_icon = PartyMgr:getPartyReviewIcon()
        if not string.isNilOrEmpty(review_icon) then
            gf:ShowSmallTips(CHS[2000203])
            break
        end

        local partyInfo = PartyMgr:getPartyInfo()
        if not partyInfo then return end
        local partyLevel = partyInfo and partyInfo.partyLevel or 0
        if partyLevel <= 1 then
            gf:ShowSmallTips(CHS[2000204])
            break
        end

        local construction = PartyMgr:getNeedConstructionForUpload()
        if partyInfo.construct < construction then
            gf:ShowSmallTips(string.format(CHS[2000205], construction))
            break
        end

        -- 安全锁判断
        if self:checkSafeLockRelease("onUploadButton", sender, eventType) then return end
        gf:comDoOpenPhoto(0, "onPartyIconUpload", cc.size(CLIP_WIDTH, CLIP_HEIGHT), cc.size(BM_WIDTH, BM_HEIGHT), gf:isIos() and 60 or 80)

    until true
end

function onPartyIconUpload(filePath)
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

    Log:I("-------------->PartyManageIconDlg:onUpload:" .. filePath)
    local fileSize = 0
    local f = io.open(filePath, "rb")
    if not f then return end
    local data
    repeat
        data = f:read(1024)
        if data then
            fileSize = fileSize + #data
        end

        if fileSize > 1024 * 2 then break end
    until nil == data
    f:close()

    if fileSize > 1024 * 2 then
        gf:ShowSmallTips(CHS[2000206])
        return
    end

    local img = cc.Image:new()
    if not img:initWithImageFile(filePath) then
        return
    end

    local w = img:getWidth()
    local h = img:getHeight()
    if not gf:gfIsFuncEnabled(FUNCTION_ID.CLIP_SCALE_IMAGE) and (22 ~= w or 22 ~= h) then
        gf:ShowSmallTips(CHS[2000206])
        return
    end

    DlgMgr:sendMsg("PartyManageIconDlg", "selectIcon", filePath, 1)
end

function onPartyIconUploadFailed()
    gf:ShowSmallTips(CHS[2100084])
end

function PartyManageIconDlg:doDefaultIcon()
    repeat
        if CHS[4000153] ~= PartyMgr:getPartyJob() then
            gf:ShowSmallTips(CHS[2000202])
            break
        end

        local reivew_icon = PartyMgr:getPartyReviewIcon()
        if not string.isNilOrEmpty(review_icon) then
            gf:ShowSmallTips(CHS[2000203])
            break
        end

        local partyInfo = PartyMgr:getPartyInfo()
        if not partyInfo then return end

        local construction = PartyMgr:getNeedConstructionForUpload()
        local partyLevel = partyInfo and partyInfo.partyLevel or 0
        if partyInfo.construct < construction then
            gf:ShowSmallTips(string.format(CHS[2000205], construction))
            break
        end

        local partyIcon = PartyMgr:getPartyIcon()
        if partyIcon and ResMgr:getPartyIconPath(partyIcon) == self.filePath then
            gf:ShowSmallTips(CHS[2100037])
            break
        end

        -- 安全锁判断
        if self:checkSafeLockRelease("doDefaultIcon") then return end

        local path = self.filePath
        local oper = self.fileOper
        assert(2 == oper)
        gf:confirm(string.format(CHS[2000207]), function()
            local fileData = ""
            local fileMd5 = self.fileName or ""
            gf:CmdToServer("CMD_SUBMIT_ICON", { oper_type = oper, md5_value = fileMd5, file_data = fileData })
        end)

    until true
end

function PartyManageIconDlg:doUploadIcon()
    local path = self.filePath
    local oper = self.fileOper
    assert(1 == oper)
    gf:confirm(string.format(CHS[2000208]), function()
        local fileData = gfReadFile(path)
        local fileMd5 = gfGetMd5(fileData)
        gf:CmdToServer("CMD_SUBMIT_ICON", { oper_type = oper, md5_value = fileMd5, file_data = fileData })
    end)
end

function PartyManageIconDlg:onApplyButton(sender, eventType)
    if not self.filePath or not self.fileOper then
        gf:ShowSmallTips(CHS[2100038])
        return
    end

    if 1 == self.fileOper then
        self:doUploadIcon()
    else
        self:doDefaultIcon()
    end
end

function PartyManageIconDlg:onMainBodyPanel(sender, eventType)
    self:setCtrlVisible("OfflineRulePanel", false)
    self:setCtrlVisible("OfflineRulePanel_1", false)
end

function PartyManageIconDlg:MSG_PARTY_INFO(data)
    self:refreshInfo()
end

return PartyManageIconDlg