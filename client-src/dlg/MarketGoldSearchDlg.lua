-- MarketSearchDlg.lua
-- Created by zhengjh Apr/20/2016
-- 珍宝搜索

local MarketSearchDlg = require('dlg/MarketSearchDlg')
local MarketGoldSearchDlg = Singleton("MarketGoldSearchDlg", MarketSearchDlg)

function MarketGoldSearchDlg:getCfgFileName()
    return ResMgr:getDlgCfg("MarketSearchDlg")
end

function MarketGoldSearchDlg:setTradeTypeUI()
    -- 隐藏属性搜索标签页
    self:setCtrlVisible("AttributeSearchCheckBox", false)
end

-- 设置所有hook消息
function MarketGoldSearchDlg:setAllHookMsgs()
    self:hookMsg("MSG_GOLD_STALL_SEARCH_GOODS") 
end

function MarketGoldSearchDlg:selectItemClass(firstClass, secondClass, thirdCladss)
    local marketTabDlg = DlgMgr.dlgs["MarketGoldTabDlg"]
    local dlg

    if self.checkBoxTable[self.selectName]:getSelectedRadioName() == "CheckBox2" then
        if marketTabDlg then
            marketTabDlg.group:setSetlctByName("MarketPublicityDlgCheckBox")
        else
            DlgMgr:openDlg("MarketGlodPublicityDlg")
            DlgMgr.dlgs["MarketGoldTabDlg"].group:setSetlctByName("MarketPublicityDlgCheckBox")
        end

        dlg = DlgMgr:getDlgByName("MarketGlodPublicityDlg")
    else
        if marketTabDlg then
            marketTabDlg.group:setSetlctByName("MarketBuyDlgCheckBox")
        else
            DlgMgr:openDlg("MarketGoldBuyDlg")
            DlgMgr.dlgs["MarketGoldTabDlg"].group:setSetlctByName("MarketBuyDlgCheckBox")
        end

        dlg = DlgMgr:getDlgByName("MarketGoldBuyDlg")
    end
    
    local goldSecondKey = {
        [CHS[3001023]] = CHS[4300170], -- 枪  "全部武器"
        [CHS[3001033]] = CHS[4300170], -- 剑   
        [CHS[3001028]] = CHS[4300170], -- 爪
        [CHS[3001038]] = CHS[4300170], -- "扇"
        [CHS[3001043]] = CHS[4300170], -- "锤"
        
        [CHS[3001048]] = CHS[4300171], -- 男帽  "全部防具"
        [CHS[3001058]] = CHS[4300171], -- 女帽
        [CHS[3001215]] = CHS[4300171], -- "男衣"
        [CHS[3001216]] = CHS[4300171], -- "女衣"
        [CHS[3001217]] = CHS[4300171], -- "鞋"
    }

    dlg:selectItemByClass(CHS[7000306])
    dlg:setCtrlVisible("SecondPanel", false)

    DlgMgr:closeDlg(self.name)
end

function MarketGoldSearchDlg:onInfoButton(sender, eventType)
    
    if self.selectName == "EquipmentSearchCheckBox" then
        local dlg = DlgMgr:openDlg("TreasureRuleDlg")
        dlg:setRuleType("equipmentSearchRule")
    elseif self.selectName == "PetSearchCheckBox" then
        local dlg = DlgMgr:openDlg("TreasureRuleDlg")
        dlg:setRuleType("petSearchRule")
    elseif self.selectName == "AttributeSearchCheckBox" then
        local dlg = DlgMgr:openDlg("TreasureRuleDlg")
        dlg:setRuleType("attributeSearchRule")
    elseif self.selectName == "NormalSearchCheckBox" then
        local dlg = DlgMgr:openDlg("TreasureRuleDlg")
        dlg:setRuleType("normalSearchRule")
    elseif self.selectName == "JewelrySearchCheckBox" then
        local dlg = DlgMgr:openDlg("MarketRuleDlg")
        dlg:setRuleType("JewelrySearchCheckBox")
    end
end

function MarketGoldSearchDlg:MSG_GOLD_STALL_SEARCH_GOODS()
    self:MSG_MARKET_SEARCH_RESULT()
end

function MarketGoldSearchDlg:tradeType()
    return MarketMgr.TradeType.goldType
end

return MarketGoldSearchDlg
