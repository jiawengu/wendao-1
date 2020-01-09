-- GuardCardDlg.lua
-- Created by zhengjh Feb/6/2015
-- 守护名片信息

local GuardCardDlg = Singleton("GuardCardDlg", Dialog)

local CARD_CONFIG = 
{
    -- 一个中文空格
    wordSpace = CHS[3002774],
    -- 7个中文空格
    lineSpace = CHS[3002775],
}

local firstAdvanceLevel = 35
local secondeAdvaceLevel = 65

function GuardCardDlg:init()
    self:bindListener("NoteButton", self.onNoteButton)
end

-- name                     名称
-- raw_name                 原始名称
-- polar                    相性
-- level                    等级
-- max_life                 气血
-- intimacy                 亲密度
-- fight_score               战力
-- phy_power                物伤
-- mag_power                法伤
-- speed                    速度
-- def                      防御

-- con                      总体质
-- develop_con              培养增加的总体质
-- str                      总力量
-- develop_str              培养增加的总力量
-- wiz                      总灵力
-- develop_wiz              培养增加的总灵力
-- dex                      总敏捷
-- develop_dex              培养增加的总敏捷

-- metal                    金(总)
-- wood                     木(总)
-- water                    水(总)
-- fire                     火(总)
-- earth                    土(总)


-- develop_power                    培养基础攻击
-- develop_def                      培养基础防御
-- rebuild_level            培养等级
-- degree                   进度

function GuardCardDlg:setGuardCardInfo(guard)
    self:bindListener("GuardCardDlg", self.onCloseButton)
    self.guard = guard
    
    -- 设置守护左边基本信息
    self:setGuardLeftPanel(guard)
    
    -- 设置基本信息
    self:setBasicInfo(guard)   
    
    -- 设置属性
    self:setAttribInfo(guard)
    
    -- 设置相性
    self:setPolarInfo(guard)
    
    -- 设置培养
    self:setDevelopInfo(guard)
    
    -- 所有相性
   -- self.polar = math.floor(guard["rebuild_level"]/10)
   --[[self.polar = 0
    
    local infoStr = ""
    
    -- 属性
    infoStr = infoStr..self:getAttributeStr(guard)
   
    -- 相性 
    infoStr = infoStr..self:getPolareStr(guard)
    
    -- 培养
    infoStr = infoStr..self:getDevelopStr(guard)
    
    -- 强化等级
    --infoStr = infoStr..self:getStrengthStr(guard)
   
    -- 装备改造 
    --infoStr = infoStr..self:getRebuildStr(guard)
 
    -- 把拼接的字符加入面板
    local panel = self:getControl("GuardInfoPanel")
    if panel == nil then return end    
    local size = panel:getContentSize(); 
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(20)
    textCtrl:setString(infoStr)
    textCtrl:setContentSize(size.width, 0)
    textCtrl:updateNow()
    
    local textW, textH = textCtrl:getRealSize()
    self.root:setContentSize(self.root:getContentSize().width, self.root:getContentSize().height-(size.height-textH))
    panel:setContentSize(textW, textH)
    textCtrl:setPosition(0, textH)
    panel:addChild(tolua.cast(textCtrl, "cc.LayerColor"))]]
end

function GuardCardDlg:setGuardLeftPanel(guard)
    -- 设置守护形象
    self:setPortrait("ShapePanel", guard["icon"], 0, nil, true)
    self:setLabelText("NameLabel_1", guard.raw_name)

    local guardQuality = gf:geGuardRank(guard.rank)
    if guardQuality == CHS[3002776] then
        self:setLabelText("NameLabel_2", guard.raw_name, nil, COLOR3.BLUE) -- 蓝色
    elseif guardQuality == CHS[3002777] then 
        self:setLabelText("NameLabel_2", guard.raw_name, nil, COLOR3.PURPLE)  -- 粉色
    elseif guardQuality == CHS[3002778] then 
        self:setLabelText("NameLabel_2", guard.raw_name, nil, COLOR3.YELLOW)   -- 金色
    end
    
    -- 等级
    self:setLabelText("LevelLabel", "LV."..guard["level"])
    
    -- 相性
    local polarPath = ResMgr:getPolarImagePath(gf:getPolar(guard.polar))
    local polarImage = self:getControl("SmallImage", Const.UIImage, panel)
    polarImage:loadTexture(polarPath, ccui.TextureResType.plistType)
    
    -- 历练
    
    local rank_now = guard.rank
    local advaceStr = ""
    local callInfo = GuardMgr:getGuardCalledInfoByRawName(guard.raw_name)
    
    if  callInfo[8] ~= GUARD_RANK.SHENLING then
        if rank_now == GUARD_RANK.TONGZI  then
            advaceStr = firstAdvanceLevel..CHS[3002779]
        elseif rank_now == GUARD_RANK.ZHANGLAO  then
            advaceStr = secondeAdvaceLevel..CHS[3002779]
        elseif rank_now == GUARD_RANK.SHENLING  then
            advaceStr = CHS[3002780]
        end  
    else
        advaceStr = CHS[3002781]
    end
    
    self:setLabelText("QualityLabel", advaceStr)
    
end

function GuardCardDlg:setGuardName(guard)
   local panel = self:getControl("GuardNamePanel")
    
    if panel == nil then return end    
    
    local size = panel:getContentSize()
--    local nameStr = string.format("#Y%s(%s)#n #W%s#n", guard["raw_name"], gf:geGuardRank(guard["rank"]), gf:getPolar(guard["polar"]))
    
    -- 根据守卫的品质类型，设置守卫名字的颜色
    local nameStr
    local guardQuality = gf:geGuardRank(guard.rank)
    if guardQuality == CHS[3002776] then
        nameStr = string.format("#B%s#n #W%s#n", guard.raw_name, gf:getPolar(guard.polar))  -- 蓝色
    elseif guardQuality == CHS[3002777] then 
        nameStr = string.format("#O%s#n #W%s#n", guard.raw_name, gf:getPolar(guard.polar))  -- 粉色
    elseif guardQuality == CHS[3002778] then 
        nameStr = string.format("#Y%s#n #W%s#n", guard.raw_name, gf:getPolar(guard.polar))  -- 金色
    else 
        Log:W("Guard quality not matched!")
        return
    end
    
    
    local nameCtrl = CGAColorTextList:create()
    nameCtrl:setFontSize(20)
    nameCtrl:setString(nameStr)
    nameCtrl:setContentSize(size.width, 0)
    nameCtrl:updateNow()
    
    -- 居中显示
    local textW, textH = nameCtrl:getRealSize()
    nameCtrl:setPosition(size.width/2 - textW/2, size.height)
    local layer = tolua.cast(nameCtrl, "cc.LayerColor")
    panel:addChild(layer)
end

function GuardCardDlg:setBasicInfo(guard)
    local callInfo = GuardMgr:getGuardCalledInfoByRawName(guard.raw_name)
    self:setCtrlVisible("CatchLevelPanel", true)
    self:setLabelValueByPanel("CatchLevelPanel", callInfo[1]..CHS[3002782])
    self:setLabelValueByPanel("LifePanel", guard["max_life"])
    self:setLabelValueByPanel("IntimacyPanel", guard["intimacy"])
    self:setLabelValueByPanel("PhyPowerPanel", guard["phy_power"])
    self:setLabelValueByPanel("MagPowerPanel", guard["mag_power"])
    self:setLabelValueByPanel("SpeedPanel", guard["speed"])
    self:setLabelValueByPanel("DefencePanel", guard["def"])
end

function GuardCardDlg:setLabelValueByPanel(panelName, value)
    local panel = self:getControl(panelName)
    self:setLabelText("ValueLabel", value, panel)
end


-- 设置属性
function GuardCardDlg:setAttribInfo(guard)
    self:setLabelValueByPanel("ConPanel", guard["con"])
    self:setLabelValueByPanel("StrPanel", guard["str"])
    self:setLabelValueByPanel("WizPanel", guard["wiz"])
    self:setLabelValueByPanel("DexPanel", guard["dex"])
end

-- 设置相性
function GuardCardDlg:setPolarInfo(guard)
    self:setLabelValueByPanel("MetalPanel", guard["metal"])
    self:setLabelValueByPanel("WoodPanel", guard["wood"])
    self:setLabelValueByPanel("WaterPanel", guard["water"])
    self:setLabelValueByPanel("FirePanel", guard["fire"])
    self:setLabelValueByPanel("EarthPanel", guard["earth"])
end

-- 设置培养属性
function GuardCardDlg:setDevelopInfo(guard)
    -- 培养等级
    local developStr 
    if guard["degree"] == 0 then
        developStr = string.format(CHS[3002783], tonumber(guard["rebuild_level"]))
    else
        developStr = string.format(CHS[3002784], tonumber(guard["rebuild_level"]), guard["degree"])
    end
    
    self:setLabelValueByPanel("DevelopLevelPanel", developStr)
    
    -- 伤害
    local addAttrib = GuardMgr:getDevelopBasciAttrib(guard["rebuild_level"])
    local powerStr = string.format("%d", math.floor(guard["develop_power"] * addAttrib["add_attack"]))
    self:setLabelValueByPanel("PowerPanel", "+".. powerStr)
    self:setLabelValueByPanel("PowerPanel2", "+".. math.floor(guard["develop_power"] * addAttrib["add_attack"] * 0.75))
    
    -- 防御
    local defenceStr = string.format("+%d", math.floor(guard["develop_def"] * addAttrib["add_defense"]))
    self:setLabelValueByPanel("DevelopDefencePanel", defenceStr)
end


-- 显示守护简介
function GuardCardDlg:onNoteButton(sender, eventType)

    local guardDecribe = GuardMgr:getGarudDescirbe()
    local polar = gf:getPolar(self.guard.polar)
    local rank = self.guard.rank
    gf:showTipInfo(guardDecribe[polar][rank], sender)
end

-- 获取属性
function GuardCardDlg:getAttributeStr(guard)    
    local strTable = {}

    -- 体质
    table.insert(strTable, self:getOnestr(CHS[6000014], guard["con"], 0)) 

    -- 灵气
    table.insert(strTable, self:getOnestr(CHS[6000012], guard["wiz"], 0))

    -- 力量 
    table.insert(strTable, self:getOnestr(CHS[6000011], guard["str"], 0))

    -- 敏捷 
    table.insert(strTable, self:getOnestr(CHS[6000013], guard["dex"], 0))

    return self:makeStrLine(CHS[6000017],strTable,3)
end

-- 获取相性 
function GuardCardDlg:getPolareStr(guard)
    local strTable = {}

    -- 金
    table.insert(strTable, self:getOnestr(CHS[6000021], guard["metal"], self.polar)) 

    -- 木
    table.insert(strTable, self:getOnestr(CHS[6000022], guard["wood"], self.polar))

    -- 水
    table.insert(strTable, self:getOnestr(CHS[6000023], guard["water"], self.polar))

    -- 火 
    table.insert(strTable, self:getOnestr(CHS[6000024], guard["fire"], self.polar))
    
    -- 土
    table.insert(strTable, self:getOnestr(CHS[6000025], guard["earth"], self.polar))
    
    return self:makeStrLine(CHS[6000018], strTable, 3)
end 


-- 获取一个属性或者相性的显示内容
function GuardCardDlg:getOnestr(key, totalValue, addValue)
    local str = key..CARD_CONFIG.wordSpace
    local basicValue = totalValue - addValue
    if totalValue == basicValue then
        str = str..totalValue
    else
        str = str..totalValue
        str = str..string.format(CHS[6000028], basicValue, addValue)
    end
    
    return str..CARD_CONFIG.wordSpace
end

-- 培养信息
function GuardCardDlg:getDevelopStr(guard)
    local developStr = ""
    
    -- 培养等级
    developStr = developStr..CHS[6000019].."#G"
    developStr = developStr..string.format(CHS[3002785], guard["rebuild_level"])
    
    -- 换行缩进
    developStr = developStr.."\n"..CARD_CONFIG.lineSpace
    
    local addAttrib = GuardMgr:getDevelopBasciAttrib(guard["rebuild_level"])
    
    -- 伤害
    developStr = developStr..string.format("%s %d+%d%%", CHS[4000032], guard["develop_power"], addAttrib["add_attack"] * 100)..CARD_CONFIG.wordSpace
    
    -- 防御
    developStr = developStr..string.format("%s %d+%d%%", CHS[3002786], guard["develop_def"], addAttrib["add_defense"] * 100)..CARD_CONFIG.wordSpace
    
    return developStr
end

-- 获取强化等级信息
function GuardCardDlg:getStrengthStr(guard)
    local strengthStr = ""
    local guardStrenLev = guard["rebuild_level"]
    local guardRank = guard["rank"]
    
    -- 不显示
    if guard["degree"] == 0 and guardStrenLev == 0 then
        return strengthStr
    end
    
    -- 强化等级
    strengthStr = strengthStr..CHS[6000019].."#G"
    strengthStr = strengthStr..string.format(CHS[6000026], guard["rebuild_level"])
    if guard["degree"] ~= 0 then 
        local guardComCount = GuardMgr:getComCount(guardStrenLev, guardRank)
        strengthStr = string.format("%s(%d/%d)",strengthStr, guard["degree"], guardComCount)
    end
    
    -- 伤害和所有相性
    local hurt =  Formula:getGuardStrengthPower(guardStrenLev, guardRank)
    
    if hurt ~= 0 or self.polar ~= 0 then 
        strengthStr = strengthStr.."\n"..CARD_CONFIG.lineSpace
    end
    
    if hurt ~= 0 then
        strengthStr = strengthStr..string.format("%s(+%d)", CHS[4000032], hurt)..CARD_CONFIG.wordSpace
    end
    
    if self.polar ~= 0 then 
        strengthStr = strengthStr..string.format("%s(+%d)", CHS[4000031], self.polar)..CARD_CONFIG.wordSpace
    end
     
    return strengthStr.."#n".."\n \n"
end

-- 获取装备改造信息
function GuardCardDlg:getRebuildStr(guard)
    local strTable = {}
    
    -- 武器
    table.insert(strTable,self:getOneRebuildStr(CHS[4000058], guard["weapon"]))
    
    -- 帽子
    table.insert(strTable,self:getOneRebuildStr(CHS[4000060], guard["helmet"]))
    
    -- 衣服
    table.insert(strTable,self:getOneRebuildStr(CHS[4000059], guard["armor"]))
    
    -- 鞋子
    table.insert(strTable,self:getOneRebuildStr(CHS[4000061], guard["boot"]))
    
    return self:makeStrLine(CHS[6000020], strTable, 2)
end

-- 获取单个装备改造信息
function GuardCardDlg:getOneRebuildStr(key, rebuildTable)
   local oneRebuildStr = ""   
   
   -- 不显示
   local level,star = Formula:getGuardLevAndStar(rebuildTable["rebuild_level"])
   if level == 0 and star == 0 and rebuildTable["degree"] == 0 then 
        return oneRebuildStr
   end
   
   oneRebuildStr = oneRebuildStr..key..CARD_CONFIG.wordSpace
   oneRebuildStr = oneRebuildStr..string.format(CHS[4000101], level, star)
   
    if rebuildTable["degree"] ~=0 then
        oneRebuildStr = string.format("%s(%d/%d)", oneRebuildStr, rebuildTable["degree"], rebuildTable["max_degree"])   
   end
   
    return oneRebuildStr..CARD_CONFIG.wordSpace
end

-- 根据每行显示几个信息来换行
function GuardCardDlg:makeStrLine(title, strTable, lineCount)
    local str = ""
    
    -- 要显示的个数
    local count = 0
    for i = 1, #strTable do
       if strTable[i] ~= "" then
           count = count + 1
           
           -- 加入标题
           if count == 1 then
               str = string.format("%s%s", title, "#G")
           end
           
           str = string.format("%s%s", str, strTable[i])
           
           -- 换行
           if count%lineCount == 0  and lineCount ~= #strTable then
               str =string.format("%s%s%s", str, "\n", CARD_CONFIG.lineSpace)
           end
           
        end
     end 
     
     if str ~= "" then
        str = string.format("%s#n%s", str, "\n \n")
     end
     
     return str
end

return GuardCardDlg
