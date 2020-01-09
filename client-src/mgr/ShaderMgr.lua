-- ShaderMgr.lua
-- created by cheny Jan/30/2015
-- shader 管理器

ShaderMgr = Singleton()

ShaderMgr.grayShader = nil
ShaderMgr.loadFromRes = true

-- 初始化
function ShaderMgr:init()
    self:getGrayShader()
end

-- 获取置灰 shader
function ShaderMgr:getGrayShader()
    if not self.grayShader then
        if self.loadFromRes then
            local vf = ResMgr:getShaderPath('TexturePos.vert')
            local ff = ResMgr:getShaderPath('GrayTexture.frag')
            local glp = cc.GLProgram:createWithFilenames(vf, ff)
            if glp then
                self.grayShader = cc.GLProgramState:getOrCreateWithGLProgram(glp)
            else
                -- 创建异常，使用默认shader并上传日志
                self.grayShader = self:getRawShader()
                gf:ftpUploadEx(string.format("Failed to create glProgame, vf:%s, ff:%s, isInbackground:%s\n%s", vf, ff, tostring(GameMgr:isInBackground()), debug.traceback()))
            end
        else
            self.grayShader = cc.GLProgramState:getOrCreateWithGLProgramName("ShaderTextureGray")
        end
        self.grayShader:retain()
    end

    return self.grayShader
end

function ShaderMgr:getRawShader()
    return cc.GLProgramState:getOrCreateWithGLProgramName("ShaderPositionTextureColor_noMVP")
end

function ShaderMgr:getColorChangeShader(id)
    if not self.colorChangeShader then
        self.colorChangeShader = {}
    end

    if not self.colorChangeShader[id] then
        self.colorChangeShader[id] = self:createColorChangeShader()
        self.colorChangeShader[id]:retain()
    end

    return self.colorChangeShader[id]
end

-- 获取换色shader
-- 由于会修改shader的uniform变量，不复用
function ShaderMgr:createColorChangeShader()
    local colorChangeShader
    if self.loadFromRes then
        local vf = ResMgr:getShaderPath('TexturePos.vert')
        local ff = ResMgr:getShaderPath('ColorChange.frag')
        local glp = cc.GLProgram:createWithFilenames(vf, ff)
        if glp then
            colorChangeShader = cc.GLProgramState:create(glp)
        else
            -- 创建异常，使用默认shader并上传日志
            colorChangeShader = self:getRawShader()
            gf:ftpUploadLog(string.format("Failed to create glProgame, vf:%s, ff:%s", vf, ff), 300)
        end
    else
        colorChangeShader = tolua.cast(gfCreateGLProgrameState("ShaderTextureColorChange"), "cc.GLProgramState")
    end

    return colorChangeShader
end

function ShaderMgr:getSimpleColorChangeShader(id)
    if not self.simpleColorChangeShader then
        self.simpleColorChangeShader = {}
    end

    if not self.simpleColorChangeShader[id] then
        self.simpleColorChangeShader[id] = self:createSimpleColorChangeShader()
        self.simpleColorChangeShader[id]:retain()
    end

    return self.simpleColorChangeShader[id]
end

-- 单位矩阵
local I_MAT4 = {
    1.0, 0.0, 0.0, 0.0,
    0.0, 1.0, 0.0, 0.0,
    0.0, 0.0, 1.0, 0.0,
    0.0, 0.0, 0.0, 1.0,
}

-- 获取精简版的换色shader
-- 由于会修改shader的uniform变量，不复用
function ShaderMgr:createSimpleColorChangeShader()
    local simpleColorChangeShader

    if self.loadFromRes then
        local vf = ResMgr:getShaderPath('TexturePos.vert')
        local ff = ResMgr:getShaderPath('SimpleColorChange.frag')
        local glp = cc.GLProgram:createWithFilenames(vf, ff)
        if glp then
            simpleColorChangeShader  = cc.GLProgramState:create(glp)
        else
            -- 创建异常，使用默认shader并上传日志
            simpleColorChangeShader  = self:getRawShader()
            gf:ftpUploadLog(string.format("Failed to create glProgame, vf:%s, ff:%s", vf, ff), 300)
        end
    else
        simpleColorChangeShader = tolua.cast(gfCreateGLProgrameState("ShaderTextureSimpleColorChange"), "cc.GLProgramState")
    end

    if simpleColorChangeShader then
        simpleColorChangeShader:setUniformMat4("rate", I_MAT4)
    end

    return simpleColorChangeShader
end

-- 抗锯齿shader
function ShaderMgr:createAntiAliasingShader()
    local vf = ResMgr:getShaderPath('AntiAliasing.vert')
    local ff = ResMgr:getShaderPath('AntiAliasing.frag')
    local glp = cc.GLProgram:createWithFilenames(vf, ff)
    if glp then
        local shader = cc.GLProgramState:getOrCreateWithGLProgram(glp)
        if shader then
            return shader 
        end
    end
end

function ShaderMgr:releaseAllShader()
    if self.grayShader then
        self.grayShader:release()
        self.grayShader = nil
    end

    if self.simpleColorChangeShader then
        for _, v in pairs(self.simpleColorChangeShader) do
            if v then v:release() end
        end
        self.simpleColorChangeShader = nil
    end

    if self.colorChangeShader then
        for _, v in pairs(self.colorChangeShader) do
            if v then v:release() end
        end
        self.colorChangeShader = nil
    end
end

ShaderMgr:init()