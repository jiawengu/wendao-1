-- PracticeMonsterDlg.lua
-- Created by zhengjh Mar/9/2015
-- 怪物列表悬浮框

local CONST_DATA =
{
    ColumnSpace = 80,
}

local normalMonsterList = require(ResMgr:getCfgPath('NormalPetList.lua'))
local PracticeMonsterDlg = Singleton("PracticeMonsterDlg", Dialog)

function PracticeMonsterDlg:init()
    self.titleLabel = self:getControl("TitleLabel", Const.UILabel)
    self.titleLabel:retain()
    self.monsterListpanel = self:getControl("MonsterListPanel", Const.UIPanel)
    self.monsterPanel = self:getControl("MonsterPanel", Const.UIPanel)
    self.monsterPanel:retain()
    self.monsterPanel:removeFromParent()
end

function PracticeMonsterDlg:setMonsterData(monsterBoos)
    -- 地图名称
    local mapNameLabel = self:getControl("TitleLabel", Const.UILabel)
    mapNameLabel:setString(monsterBoos["mapName"])

    local mosterList = self:getMosterList(monsterBoos["mapName"])
    local mosterNumber = #mosterList

    for i = 1, mosterNumber do
       local mosterPanel = self.monsterPanel:clone()
       mosterPanel:setPosition(CONST_DATA.ColumnSpace + (i -1) *( mosterPanel:getContentSize().width + CONST_DATA.ColumnSpace) , mosterPanel:getContentSize().height - 15)
       self:setMonsterInfo(mosterPanel, mosterList[i])
       self.monsterListpanel:addChild(mosterPanel)
    end

    self.monsterListpanel:setContentSize(CONST_DATA.ColumnSpace*(mosterNumber + 1) + self.monsterPanel:getContentSize().width * mosterNumber,  self.root:getContentSize().height)
    self.root:setContentSize(self.monsterListpanel:getContentSize())
end

function PracticeMonsterDlg:setMonsterInfo(mosterPanel,monster)
    -- 怪物头像
    local imgPath = ResMgr:getSmallPortrait(monster["icon"])
    local mosterImg = self:getControl("MonsterImage", Const.UIImage, mosterPanel)
    local iconImg = ccui.ImageView:create(imgPath)
    iconImg:setPosition(mosterPanel:getContentSize().width / 2, mosterPanel:getContentSize().height / 2)
    --mosterPanel:addChild(iconImg)
    mosterImg:loadTexture(imgPath)
    self:setItemImageSize("MonsterImage", mosterPanel)

    -- 怪物等级
    --local level = self:getControl("LevelLabel", Const.UILabel, mosterPanel)
    --level:setString(monster["level_req"])

    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.DEFAULT, monster["level_req"], false, LOCATE_POSITION.LEFT_TOP, 23, mosterPanel)

    -- 怪物名称
    local name = self:getControl("NameLabel1", Const.UILabel,mosterPanel)
    name:setString(monster["name"])

        -- 设置宠物相性
    local polar = PetMgr:getPetCfg(monster["name"]).polar
    local polarPath = ResMgr:getPolarImagePath(polar)
    self:setImagePlist("Image", polarPath, mosterPanel)
end

-- 获取改区域的怪物列表
function PracticeMonsterDlg:getMosterList(mapName)
    local mosterList = {}

    for k, v in pairs(normalMonsterList) do
        for i = 1, #v["zoon"] do
            if v["zoon"][i] == mapName then
                local monster = {}
                monster["name"] = k
                monster["icon"] = v["icon"]
                monster["level_req"] = v["level_req"]
                table.insert(mosterList, monster)
            end
        end
    end

    return mosterList
end

function PracticeMonsterDlg:cleanup()
    self:releaseCloneCtrl("monsterPanel")
    self:releaseCloneCtrl("titleLabel")
end
return PracticeMonsterDlg
