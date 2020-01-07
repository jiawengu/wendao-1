-- SouxlpSmallDlg.lua
-- Created by lixh Nov/02/2017
-- 2018元旦节：搜邪罗盘指引界面

local SouxlpSmallDlg = Singleton("SouxlpSmallDlg", Dialog)

-- 左上角罗盘相对全屏0点的的偏移
local OFFSET_X = 82
local OFFSET_Y = Const.WINSIZE.height - 182.5

-- 罗盘方位原来颜色
local ORI_COLOR = cc.c3b(89, 80, 62)

-- 罗盘方位点亮后颜色
local RED_COLOR = cc.c3b(166, 58, 60)

-- 罗盘方位数量
local NEEDLE_DIR_NUM = 8

-- 小罗盘光效标记
local MAGIC_TAG = 1000

-- 罗盘当前指针角度对应红色方位
local ANGLE_TO_COMPASS_STATUS = {
    {left = -25, right = 25, on = {1}},
    {left = 20, right = 25, on = {1, 2}},
    {left = 20, right = 70, on = {2}},
    {left = 65, right = 70, on = {2, 3}},
    
    {left = 65, right = 115, on = {3}},
    {left = 110, right = 115, on = {3, 4}},
    {left = 110, right = 160, on = {4}},
    {left = 155, right = 160, on = {4, 5}},
    
    {left = 155, right = 180, on = {5}},
    {left = -180, right = -155, on = {5}},
    {left = -160, right = -155, on = {5, 6}},
    {left = -160, right = -110, on = {6}},
    {left = -115, right = -110, on = {6, 7}},
    
    {left = -115, right = -65, on = {7}},
    {left = -70, right = -65, on = {7, 8}},
    {left = -70, right = -20, on = {8}},
    {left = -25, right = -20, on = {8, 1}},
}

function SouxlpSmallDlg:init(data)
    self:setFullScreen()
    self.tarX = OFFSET_X
    self.tarY = OFFSET_Y

    self:bindListener("SouxlpPanel", self.onCompassPanel)

    self.compass = self:getControl("SouxlpPanel")
    self.needle = self:getControl("CenterNeedleImage")
    
    self.mapId = data.mapId
    self.monsterX, self.monsterY = MapMgr:adjustPosition(data.x, data.y)
    self.needAction = tonumber(data.needAction) == 1
    if self.needAction then
        -- 需要播放动作，则在播放完再开始更新小罗盘上信息
        self.startFlag = false
        self:startAction()
    else
        self.compass:setPosition(self.tarX, self.tarY)
        self.startFlag = true
    end

    local dlg = DlgMgr:getDlgByName("SystemFunctionDlg")
    if dlg then 
        dlg:onStatusButton2()
    end
end

-- 点击小罗盘，给提示
function SouxlpSmallDlg:onCompassPanel()
    gf:ShowSmallTips(CHS[7190216])
end

-- 小罗盘播放动作
function SouxlpSmallDlg:startAction()
    local callBack = cc.CallFunc:create(function()
        self.startFlag = true
    end)
    
    local moveto  = cc.MoveTo:create(1, cc.p(self.tarX, self.tarY))
    local action = cc.Sequence:create(moveto, callBack)
    self.compass:runAction(action)
end

function SouxlpSmallDlg:onUpdate()
    if not self.startFlag then
        return
    end
    
    -- 获取当前怪物与人物位置向量夹角
    local angle = self:getAngleWithMonster()
    self.needle:setRotation(angle)
    
    local lightTable = {}
    for i = 1, #ANGLE_TO_COMPASS_STATUS do
        local info = ANGLE_TO_COMPASS_STATUS[i]
        if angle > info.left and angle <= info.right then
            for j = 1, #info.on do
                local img = self:getControl("Image_" .. info.on[j])
                img:setColor(RED_COLOR)
                gf:createArmatureMagic({name = ResMgr.ArmatureMagic.luopan_dir_light.name, 
                    action = "Top0" .. info.on[j]}, img, info.on[j] + MAGIC_TAG)
                table.insert(lightTable, info.on[j])
            end
        end
    end
    
    -- 计算需要移除光效与红色的img编号
    local needRemoveLight = {}
    for i = 1, NEEDLE_DIR_NUM do
        local isLight = false
        for j = 1, #lightTable do
            if i == lightTable[j] then
                -- i方向当前亮
                isLight = true
            end
        end
        
        if not isLight then
            table.insert(needRemoveLight, i)
        end
    end
    
    -- 全部置灰
    for i = 1, #needRemoveLight do
        local img = self:getControl("Image_" .. needRemoveLight[i])
        img:setColor(ORI_COLOR)
        local magic = img:getChildByTag(needRemoveLight[i] + MAGIC_TAG)
        if magic then
            magic:removeFromParent()
            magic = nil
        end
    end
end

function SouxlpSmallDlg:cleanUp()
    ArmatureMgr:removeUIArmature(ResMgr.ArmatureMagic.luopan_dir_light.name)
end

-- 计算当前角色与怪物位置的距离
function SouxlpSmallDlg:getDistanceWithMonster()
    local curX, curY = gf:convertToMapSpace(Me.curX, Me.curY)
    return gf:distance(curX, curY, self.monsterX, self.monsterY)
end

-- 计算当前角色与怪物位置的水平夹角
function SouxlpSmallDlg:getAngleWithMonster()
    local curX, curY = gf:convertToMapSpace(Me.curX, Me.curY)
    local vecX = self.monsterX - curX
    local vecY = self.monsterY - curY
    return math.atan2(vecX, -vecY) * 180 / math.pi
end

function SouxlpSmallDlg:setVisible(flag)
    Dialog.setVisible(self, flag)

    local dlg = DlgMgr:getDlgByName("SystemFunctionDlg")
    if flag then
        if dlg and dlg.curStatus == 2 then
            dlg:onStatusButton2()
        end
    else
        if dlg and dlg.curStatus == 1 then
            dlg:onStatusButton1()
        end
    end
end

function SouxlpSmallDlg:onCloseButton()
    local dlg = DlgMgr:getDlgByName("SystemFunctionDlg")
    if dlg then
        dlg:onStatusButton1()
    end
end

return SouxlpSmallDlg
