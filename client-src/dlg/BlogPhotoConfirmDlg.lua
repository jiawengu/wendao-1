-- BlogPhotoConfirmDlg.lua
-- Created by songcw Oct/24/2017
-- 头像预览

local BlogPhotoConfirmDlg = Singleton("BlogPhotoConfirmDlg", Dialog)

function BlogPhotoConfirmDlg:init()
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("AgainButton", self.onAgainButton)
    self.data = nil
    self.path = nil
end

function BlogPhotoConfirmDlg:setData(data, path, parentDlg)
    self:setLabelText("NameLabel", data.name)

    local panel = self:getControl("ShapePanel", Const.UIImage, "ShowPanel")
    if panel then
        panel:removeAllChildren()
        if string.isNilOrEmpty(path) then return end
        local sp = cc.Sprite:create(path)
        if not sp then return end
        local contentSize = sp:getContentSize()
        local pSize = panel:getContentSize()
        sp:setScale((pSize.width / contentSize.width))
        sp:setPosition(cc.p(pSize.width / 2, pSize.height / 2))
        panel:addChild(sp)
    end

    --self:setImage("ShapeImage", path)
    self:setCtrlVisible("ShapeImage", false)

    local polarPath = ResMgr:getSuitPolarImagePath(data.polar)
    local polarImage = self:getControl("TypeImage", nil, "ShowPanel")
    if polarImage and polarPath then
        polarImage:loadTexture(polarPath, ccui.TextureResType.plistType)
    end

    self.data = data
    self.path = path
    self.parentDlg = parentDlg
    self:setCtrlEnabled("ConfirmButton", true)
end

function BlogPhotoConfirmDlg:onFinishUploadIcon(files, uploads)
    self:setCtrlEnabled("ConfirmButton", true)
    if #files ~= #uploads then
        gf:ShowSmallTips(CHS[2000447])
        ChatMgr:sendMiscMsg(CHS[2000447])
        return
    end

    gf:CmdToServer("CMD_BLOG_CHANGE_ICON", { icon_img = uploads[1] })
    self:onCloseButton()
end


function BlogPhotoConfirmDlg:onConfirmButton(sender, eventType)
    self:setCtrlEnabled("ConfirmButton", false)
    BlogMgr:cmdUpload(BLOG_OP_TYPE.BLOG_OP_UPLOAD_ICON, self.parentDlg, "onFinishUploadIcon", self.path)
    self:onCloseButton()
end

function onBlogPhotoConfirmDlgPortraitUpload(filePath)
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


    DlgMgr:sendMsg("BlogPhotoConfirmDlg", "resetData", filePath)
end

function BlogPhotoConfirmDlg:resetData(path)
    local data = self.data
    self:setLabelText("NameLabel", data.name)

    local panel = self:getControl("ShapePanel", Const.UIImage, "ShowPanel")
    if panel then
        panel:removeAllChildren()
        if string.isNilOrEmpty(path) then return end
        local sp = cc.Sprite:create(path)
        if not sp then return end
        local contentSize = sp:getContentSize()
        local pSize = panel:getContentSize()
        sp:setScale((pSize.width / contentSize.width))
        sp:setPosition(cc.p(pSize.width / 2, pSize.height / 2))
        panel:addChild(sp)
    end

    --self:setImage("ShapeImage", path)
    self:setCtrlVisible("ShapeImage", false)

    local polarPath = ResMgr:getSuitPolarImagePath(data.polar)
    local polarImage = self:getControl("TypeImage", nil, "ShowPanel")
    if polarImage and polarPath then
        polarImage:loadTexture(polarPath, ccui.TextureResType.plistType)
    end

    self.data = data
    self.path = path
    self:setCtrlEnabled("ConfirmButton", true)
end

function BlogPhotoConfirmDlg:onAgainButton(sender, eventType)
    local cw, ch = BlogMgr:getPortraitClipRange()
    gf:comDoOpenPhoto(0, "onBlogPhotoConfirmDlgPortraitUpload", cc.size(cw, ch), cc.size(256, 256), 80)
end

return BlogPhotoConfirmDlg
