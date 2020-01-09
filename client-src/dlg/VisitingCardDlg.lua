-- VisitingCardDlg.lua
-- Created by
-- 角色名片界面
-- 界面比较简单，继承 CharMenuContentDlg

local CharMenuContentDlg = require('dlg/CharMenuContentDlg')
local Bitset = require("core/Bitset")
local VisitingCardDlg = Singleton("VisitingCardDlg", CharMenuContentDlg)

local TEAM_BUTTON_TYPE =
{
    invite = 1,
    request = 2,
}

function VisitingCardDlg:init()


    local mainPanel = self:getControl("InfoPanel")
    self.panelSize = self.panelSize or mainPanel:getContentSize()
    self.rootSize = self.rootSize or self.root:getContentSize()
    self.rect = nil
    self.backCharInfo = nil -- 已经有的数据，如果服务器下发， MSG_FIND_CHAR_MENU_FAIL，则显示该数据
    self.charPanelOrgSz = self:getCtrlContentSize("CharInfoPanel")

    self.showBtnCou = 1

    self:bindListener("RelationshipButton", self.onRelationshipButton)

    self.buttonCell = self:retainCtrl("Button1")

    self:hookMsg("MSG_FRIEND_ADD_CHAR")
    self:hookMsg("MSG_FRIEND_REMOVE_CHAR")
    self:hookMsg("MSG_CHAR_INFO")
    self:hookMsg("MSG_LOOK_PLAYER_EQUIP")
    self:hookMsg("MSG_FIND_CHAR_MENU_FAIL")
    self:hookMsg("MSG_FRIEND_MEMO")
    self:hookMsg("MSG_TEMP_FRIEND_STATE")
end

function VisitingCardDlg:getMenuList()
    local menus = {}

    -- 加为好友
    if FriendMgr:hasFriend(self.curChar.gid) then
        table.insert(menus, {["button"] = CHS[5000062],["tag"] = 3})
    else
        table.insert(menus, {["button"] = CHS[5000064],["tag"] = 3})
    end

    -- 交　　流
    table.insert(menus, {button = CHS[3000057], tag = 2})

    -- 黑名单
    if FriendMgr:isBlackByGId(self.curChar.gid) then
        table.insert(menus, {["button"] = CHS[5000063], ["tag"] = 8})
    else
        table.insert(menus, {["button"] = CHS[5000065], ["tag"] = 8})
    end

    -- 查看空间
    table.insert(menus, {button = CHS[2000425], tag = 16})

    -- 查看居所
    table.insert(menus, {button = CHS[2100099], tag = 100})


    -- 组队
    if TeamMgr:inTeamEx(Me:getId()) == false and
            (self:isOperateMonsterInMasquerade() or (self.curChar.charStatus and self.curChar.charStatus:isSet(CHAR_STATUS.IN_TEAM))) == true then
        -- Me为单人，对方为队伍中  申请组队
        table.insert(menus, {["button"] = CHS[4000276],["tag"] = 6})
        self.teamButtonType = TEAM_BUTTON_TYPE.request
    elseif TeamMgr:getLeaderId() == Me:getId() then
        -- Me为队长
        table.insert(menus, {["button"] = CHS[4000275],["tag"] = 6})
        self.teamButtonType = TEAM_BUTTON_TYPE.invite
    elseif not TeamMgr:inTeamEx(Me:getId()) and
            (self:isOperateMonsterInMasquerade() or (self.curChar.charStatus and not self.curChar.charStatus:isSet(CHAR_STATUS.IN_TEAM))) then
        -- 双方都是单人 邀请
        table.insert(menus, {["button"] = CHS[4000275],["tag"] = 6})
        self.teamButtonType = TEAM_BUTTON_TYPE.invite
    end

    return menus
end

function VisitingCardDlg:onClickButton(sender)
    if sender:getTitleText() == CHS[2100099] then
        if GameMgr:IsCrossDist() then
            gf:ShowSmallTips(CHS[5000267])
        else
            -- 请求居所信息
            HomeMgr:showHomeData(self.curChar.gid, HOUSE_QUERY_TYPE.QUERY_BY_CHAR_GID)
        end

        self:onCloseButton()
    end
end

-- 策划要求，设置完备注后，刷新界面高度
function VisitingCardDlg:refreshDlgHeight(btnCou)


    self:setCtrlContentSize("CharInfoPanel", self.charPanelOrgSz.width, charInfoSetHeight)

    if not self.showBtnCou then
        return
    end
    local charInfoSetHeight = self.charPanelOrgSz.height
    -- 根据操作按钮的高度，重新计算操作Panel的显示高度
    local operatePanelSz = self:getCtrlContentSize("OperatePanel")
    local addHeight = (math.ceil(self.showBtnCou / 2) - 1) * self:getControl("Button1"):getContentSize().height

    -- 重新设置InfoPanel与root的高度
    local rootHeight = charInfoSetHeight + operatePanelSz.height + addHeight + 10
    self:setCtrlContentSize("InfoPanel", self.rootSize.width, rootHeight)
    self.root:setContentSize(self.rootSize.width, rootHeight)
    self:updateLayout("InfoPanel")
end

-- 子类有些不需要显示等级
function VisitingCardDlg:somethingForChild()
    --self:setNumImgForPanel("PortraitPanel", ART_FONT_COLOR.NORMAL_TEXT, char.level, false, LOCATE_POSITION.LEFT_TOP, 21)
    self:removeNumImgForPanel("PortraitPanel", LOCATE_POSITION.LEFT_TOP)

    self:setCtrlVisible("FDValueLabel", true)
    self:setCtrlVisible("FDTypeLabel", true)

    self:setLabelText("FDTypeLabel", CHS[4101135])
    self:setLabelText("FDValueLabel", self.curChar.level)

            -- 舞会场地不显示线路
            self:setLabelText("LineLabel", "")
            self:setCtrlVisible("LineBKImage", false)

end

function VisitingCardDlg:MSG_CHAR_INFO(data)

    self.curChar = data
    self.curChar.settingFlag = Bitset.new(data.setting_flag)

    self.curChar.charStatus = Bitset.new(data.char_status)
    self:setInfo(self.curChar)
    self:updateRelationShip()
    self:setVisible(true)
    if self.rect then
        self:setFloatingFramePos(self.rect)
    end
end

return VisitingCardDlg
