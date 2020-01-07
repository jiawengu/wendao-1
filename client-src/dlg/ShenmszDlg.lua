-- ShenmszDlg.lua
-- Created by huangzz Dec/26/2018
-- 神秘画卷界面

local ShenmszDlg = Singleton("ShenmszDlg", Dialog)

local NumImg = require('ctrl/NumImg')

local COLORS = {
    [CHS[5450429]] = cc.c3b(0xdf, 0x0a, 0x0a),
    [CHS[5450430]] = cc.c3b(0x00, 0xA8, 0x06),
    [CHS[5450431]] = cc.c3b(0x00, 0x7E, 0xFF),
    [CHS[5450432]] = cc.c3b(0x00, 0x00, 0x00),
    [CHS[5450433]] = cc.c3b(0xFF, 0xFF, 0x00),
    [CHS[5450434]] = cc.c3b(0x81, 0x1f, 0xd5),
    [CHS[5450435]] = cc.c3b(0xff, 0xb2, 0xfe),
    [CHS[5450436]] = cc.c3b(0x4C, 0x20, 0x00),
    [CHS[5450437]] = cc.c3b(0x00, 0xFF, 0xFF),
    [CHS[5450438]] = cc.c3b(0xFF, 0xFF, 0xFF),
}

local LoadingPicInfo = require "loading_pic/PictureName" or {}

local hasPut = {}

function ShenmszDlg:init()
    self:setCtrlFullClient(self.root)

    self:bindListener("NumberPanel", self.onNumberPanel)

    local panel = self:getControl("NumberPanel")
    local size = panel:getContentSize()
    local rSize = self.root:getContentSize()
    self.numPanelSize = {width = rSize.width - 960 + size.width, height = rSize.height - 640 + size.height}
    panel:setContentSize(self.numPanelSize.width, self.numPanelSize.height)

    self.numImgs = {}

    if ActivityMgr.smszData then
        self.blank:setOpacity(0) -- 防止闪一下
        performWithDelay(self.root, function()
            -- 需延时一帧，等 self.root doLayout 再刷新显示数字
            self.blank:setOpacity(255)
            if ActivityMgr.smszData then
                self:MSG_SUMMER_2019_SMSZ_SMHJ(ActivityMgr.smszData)
            end
        end, 0)
    end

    self:hookMsg("MSG_SUMMER_2019_SMSZ_SMHJ")
    self:hookMsg("MSG_SUMMER_2019_SMSZ_SMHJ_RESULT")
end

function ShenmszDlg:onNumberPanel(sender)
    if not self.mapGrid then return end

    local wPos = GameMgr.curTouchPos
    local clickNum = -1
    for key, numImg in pairs(self.numImgs) do
        local pos = numImg:convertToNodeSpace(wPos)
        local size = numImg:getContentSize()
        if numImg:isVisible() and pos.x > 0 and pos.x < size.width and pos.y > 0 and pos.y < size.height then
            hasImg = true
            clickNum = key - 1
            break
        end
    end

    if self.can_commit == 0 then return end

    gf:CmdToServer("CMD_SUMMER_2019_SMSZ_SMHJ_COMMIT", {num = clickNum})

    if clickNum == -1 and next(self.numImgs) and self.lastTimes > 0 then
        gf:ShowSmallTips(CHS[5450447])
    end
end

function ShenmszDlg:getScale(index)
    local col = math.floor(index / 10) + 1
    local row = index % 10 + 1
    return col / 10 * 0.8 + 0.72, row / 10 * 0.8 + 0.72
end

function ShenmszDlg:getCanPutPos(index)
    local col = math.floor(index / 10)
    local row = index % 10

    if col > 9 then col = 9 end

    if not hasPut[col] then hasPut[col] = {} end

    -- 数字不能重叠，故判断当前位置及相邻的位置是否已有数字，没有可直接放置
    if (not hasPut[col - 1] or not hasPut[col - 1][row])
        and (not hasPut[col + 1] or not hasPut[col + 1][row])
        and (not hasPut[col][row + 1])
        and (not hasPut[col][row - 1])
        and (not hasPut[col][row]) then
        hasPut[col][row] = 1

        -- 数字会进行缩放，减 50 防止数字放大时超出边界
        local ox = self.getWinSize().ox
        return (self.numPanelSize.width - 50 - ox) / 10 * col + ox, (self.numPanelSize.height - 50) / 10 * row
    else
        return self:getCanPutPos((index + 1) % 100)
    end
end

function ShenmszDlg:MSG_SUMMER_2019_SMSZ_SMHJ(data)
    local colors = gf:deepCopy(COLORS)
    local numPanel = self:getControl("NumberPanel")
    local mapImg = self:getControl("MapImage")
    mapImg:removeAllChildren()

    local grid =  cc.NodeGrid:create()
    mapImg:addChild(grid)

    hasPut = {}
    for i = 1, 10 do
        local info = data[i]
        local num = i - 1
        local numImg = NumImg.new(ART_FONT_COLOR.SHENM_NUM, num)
        local x, y = self:getCanPutPos(info.pos_index)
        numImg:setScale(self:getScale(info.scale_index))
        numImg:setAnchorPoint(0, 0)
        numImg:setNumsColor(COLORS[info.color])
        numImg:setOpacity(153)

        local wPos = numPanel:convertToWorldSpace(cc.p(x, y))
        local pos = grid:convertToNodeSpace(wPos)
        numImg:setPosition(pos)
        grid:addChild(numImg, i, i)

        if info.hasFind then
            numImg:setVisible(false)
            self:setCtrlColor("Label_" .. num, COLORS[info.color], "FindNumberPanel")

            self.numImgs[i] = nil
        else
            self.numImgs[i] = numImg
        end
    end

    self.can_commit = data.can_commit

    -- 剩余次数
    local lastTimes = 20 - data.commit_num
    self.lastTimes = lastTimes
    if lastTimes == 0 and next(self.numImgs) then
        self:setLabelText("TipLabel_1", CHS[5450450], "CoverPanel")
        self:setLabelText("TipLabel_2", "", "CoverPanel")
        self:setLabelText("TipLabel_3", "", "CoverPanel")
    else
        if data.can_commit == 0 then
            self:setLabelText("TipLabel_1", CHS[5450329], "CoverPanel")
            self:setLabelText("TipLabel_2", "", "CoverPanel")
            self:setLabelText("TipLabel_3", "", "CoverPanel")
        elseif not next(self.numImgs) then
            self:setLabelText("TipLabel_1", CHS[5450453], "CoverPanel")
            self:setLabelText("TipLabel_2", "", "CoverPanel")
            self:setLabelText("TipLabel_3", "", "CoverPanel")
        else
            if data.find_count >= 8 then
                self:setLabelText("TipLabel_1", string.format(CHS[5450446], data.find_count), "CoverPanel") 
            else 
                self:setLabelText("TipLabel_1", string.format(CHS[5450451], data.find_count), "CoverPanel")
            end

            self:setLabelText("TipLabel_2", lastTimes .. "/" .. 20, "CoverPanel")
            self:setLabelText("TipLabel_3", CHS[5450452], "CoverPanel")
        end
    end

    -- 背景
    local sp = cc.Sprite:create(ResMgr:getLoadingPic(data.map_index))
    grid:addChild(sp, 0, 12)

    self.mapGrid = grid
end

function ShenmszDlg:MSG_SUMMER_2019_SMSZ_SMHJ_RESULT(data)
    if not self.mapGrid then return end

    if data.result == 0 then
        local action = cc.TurnOffTiles:create(1, cc.size(100, 100))
        self.mapGrid:runAction(cc.Sequence:create(
            cc.TurnOffTiles:create(1, cc.size(100, 100)),
            cc.CallFunc:create(function() 
                self.mapGrid:setVisible(false)
            end)
        ))
    end
end

function ShenmszDlg:cleanup()
    gf:CmdToServer("CMD_SUMMER_2019_SMSZ_SMHJ_STOP", {})

    self.mapGrid = nil

    self.numImgs = nil
end

return ShenmszDlg
