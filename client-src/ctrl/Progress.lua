-- Progress.lua
-- Created by chenyq Dec/9/2012
-- 进度条控件

local Progress = class('Progress', function()
    return cc.Sprite:create()
end)

function Progress:ctor(bgImgFile, imgFile, topFile)
    local bg = cc.Sprite:create(bgImgFile)
    self:addChild(bg)

    local tc = cc.Director:getInstance():getTextureCache()
    tc:addImage(imgFile)
    self.progressBar = ccui.LoadingBar:create(imgFile, 100)
    self:addChild(self.progressBar)
    
    if topFile then
        self:addChild(cc.Sprite:create(topFile))
    end
end

function Progress:setPercent(percent)
    if self.progressBar then
        self.progressBar:setPercent(percent)
    end
end

return Progress
