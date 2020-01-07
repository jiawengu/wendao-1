-- LSNpc.lua
-- Created by huangzz, Nov/23/2017
-- 小岚和小水

local Char = require("obj/Char")
local LSNpc = class("LSNpc", Char)

local SHOW_DIR = 5

local TALK_OFFECT = 20

function LSNpc:getLoadType()
    return LOAD_TYPE.NPC
end

function LSNpc:getDir()
    return SHOW_DIR
end

function LSNpc:isCanTouch()
    return false
end

function LSNpc:endCartoon()
    self:setAct(Const.FA_STAND)
    local action = cc.Sequence:create(
        cc.FadeIn:create(1),
        cc.CallFunc:create(function()
            CharMgr:setNeedHideCharExcepts(nil)
            DlgMgr:setAllDlgVisible(true)
        end),

        cc.FadeOut:create(1),
        
        cc.CallFunc:create(function()
            gf:unfrozenScreen()
            self.isCartoon = false
            if self.lsColorLayer then
                self.lsColorLayer:removeFromParent()
                self.lsColorLayer = nil
            end
        end)
    )
    
    if self.lsColorLayer then
        self.lsColorLayer:runAction(action)
    end
end

function LSNpc:onActionEnd()
    if self.faAct == Const.FA_YONGBAO_ONE or self.faAct == Const.FA_QINQIN_ONE then
        self:endCartoon()
    end
end

function LSNpc:onAnimate(info)
    if not self.charAction then
        return
    end
    
    if info.play_type == 2 then
        self:endCartoon()
        return
    end
    
    local uiLayer = gf:getUILayer()
    if not uiLayer then
        return
    end
    
    gf:frozenScreen(0)
    
    DlgMgr:closeDlg("DramaDlg")

    -- 添加黑幕
    local colorLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 0))
    colorLayer:setContentSize(Const.WINSIZE.width / Const.UI_SCALE, Const.WINSIZE.height / Const.UI_SCALE)
    uiLayer:addChild(colorLayer)
    
    local action = cc.Sequence:create(
        cc.FadeIn:create(1),
        cc.CallFunc:create(function()
            DlgMgr:setAllDlgVisible(false)
            local char = CharMgr:getCharByName(CHS[5410209])
            local excepts = {[self:getId()] = true}
            if char then
                excepts[char:getId()] = true
            end
            
            CharMgr:setNeedHideCharExcepts(excepts)
        end),

        cc.FadeOut:create(1),
        -- 男方喊话
        cc.CallFunc:create(function()
            if info.animate_name == "shuilzy_06" then
                -- 看流星雨
                self.isCartoon = true
                self:setAct(Const.FA_YONGBAO_ONE)
            elseif info.animate_name == "shuilzy_08" then
                -- 有缘相守
                self.isCartoon = true
                local action = cc.Sequence:create(
                    -- 男方喊话
                    cc.CallFunc:create(function()
                        ChatMgr:sendCurChannelMsgOnlyClient({
                            icon = 51526,
                            name = CHS[5410207],
                            msg = CHS[5410180],
                            show_time = 2,
                            id = self:getId()
                        })
                    end),
                    cc.DelayTime:create(2),

                    -- 女方喊话
                    cc.CallFunc:create(function() 
                        ChatMgr:sendCurChannelMsgOnlyClient({
                            icon = 51525,
                            name = CHS[5410208],
                            msg = CHS[5410181],
                            show_time = 1,
                            id = self:getId()
                        })
                    end),
                    cc.DelayTime:create(1),

                    -- 开始动作
                    cc.CallFunc:create(function()
                        self:setAct(Const.FA_QINQIN_ONE)
                    end)
                )

                colorLayer:runAction(action)
            end
        end)
    )

    colorLayer:runAction(action)
    
    self.lsColorLayer = colorLayer
end

-- 点击对象时添加选中特效
function LSNpc:addFocusMagic()
end

-- 当角色失去焦点时移除光效
function LSNpc:removeFocusMagic()
end

function LSNpc:setChat(data)
    if not self.charAction then
        return
    end
    
    local headX, headY = self.charAction:getHeadOffset()

    local dlg = DlgMgr:openDlg("PopUpDlg")
    local bg = dlg:addTip(data.msg, nil, true)
    if data.icon == 51526 then
        -- 小岚喊话
        bg:setPosition(headX + TALK_OFFECT, headY)
    else
        -- 小水喊话
        bg:setPosition(headX - TALK_OFFECT, headY)
    end
    
    -- 显示一定时间后删除
    local action = cc.Sequence:create(
        cc.DelayTime:create(data.show_time),
        cc.RemoveSelf:create()
    )

    self:addToTopLayer(bg)
    bg:runAction(action)
end

function LSNpc:onExitScene()
    if self.isCartoon then
        gf:unfrozenScreen()
        CharMgr:setNeedHideCharExcepts(nil)
        DlgMgr:setAllDlgVisible(true)
    end
    
    if self.lsColorLayer then
        self.lsColorLayer:removeFromParent()
        self.lsColorLayer = nil
    end

    Char.onExitScene(self)
end

return LSNpc
