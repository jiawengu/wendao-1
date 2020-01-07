-- GoodVoiceMgr.lua
-- created by songcw Mar/20/2019
-- 好声音管理器

GoodVoiceMgr = Singleton()

GoodVoiceMgr.LIST_DATA_TYPE = {
    RANDOM = 0,             -- 发现声音
    POPULAR = 1,            -- 人气声音
    NEW = 2,                -- 今日新声
    COLLECT = 3,            -- 收藏声音
    SEARCH = 4,             -- 搜索声音
}

GoodVoiceMgr.collectData = {}

function GoodVoiceMgr:getLocalVoiceFile()
    return ChatMgr:getMediaSavePath() .. "config.lua"
end

function GoodVoiceMgr:getLocalVoiceInfo()

    if not GoodVoiceMgr.localVoiceInfo then

        local file = GoodVoiceMgr:getLocalVoiceFile()
		--gf:ShowSmallTips(file)
        if not cc.FileUtils:getInstance():isFileExist(file) then
            gfSaveFile("", file)
            return {}
        end

        local f = io.open(file, "rb")
        local content = f:read("*a")
        f:close()

        local ret = {}
        if content ~= "" then
            ret = json.decode(content)
        end

        -- 刚刚读取的时候验证下有效性
        for gid, vData in pairs(ret) do
            for fileName, info in pairs(vData) do
                if not cc.FileUtils:getInstance():isFileExist(fileName) then
                    ret[gid][fileName] = nil
                end
            end
        end

        GoodVoiceMgr.localVoiceInfo = ret
    end

    return GoodVoiceMgr.localVoiceInfo
end

function GoodVoiceMgr:getMyLocalVoiceData()
    local ret = GoodVoiceMgr:getLocalVoiceInfo()
    return ret[Me:queryBasic("gid")] or {}
end

function GoodVoiceMgr:deleteVoice(data)
    local ret = GoodVoiceMgr:getLocalVoiceInfo()
    -- 保存的时候验证下有效性把
    if not ret[Me:queryBasic("gid")] then ret[Me:queryBasic("gid")] = {} end

    for fileName, info in pairs(ret[Me:queryBasic("gid")]) do
        if not cc.FileUtils:getInstance():isFileExist(fileName) then
            ret[Me:queryBasic("gid")][fileName] = nil
        end
    end

    if not ret[Me:queryBasic("gid")] then ret[Me:queryBasic("gid")] = {} end
    ret[Me:queryBasic("gid")][data.fileName] = nil
    os.remove(data.fileName)

    local f = io.open(GoodVoiceMgr:getLocalVoiceFile(), "wb")
    local content = json.encode(ret)

    f:write(content)
    f:flush()
    f:close()
end

function GoodVoiceMgr:removeLoadVoice()
    local ret = GoodVoiceMgr:getLocalVoiceInfo()
    if not ret["isLoad"] then return end
    for fileName, time in pairs(ret["isLoad"]) do
        if gf:getServerTime() - time >= 60 * 60 * 24 * 7 then
            if cc.FileUtils:getInstance():isFileExist(fileName) then
                os.remove(fileName)
            end

            ret["isLoad"][fileName] = nil
        end
    end
    
    GoodVoiceMgr:refreshLocalVoice()
end

function GoodVoiceMgr:refreshLocalVoice(data, isLoad)
    local ret = GoodVoiceMgr:getLocalVoiceInfo()

    if not data then
        local f = io.open(GoodVoiceMgr:getLocalVoiceFile(), "wb")
        local content = json.encode(ret)
    
        f:write(content)
        f:flush()
        f:close()
        return
    end


-- 如果是下载的，直接保存起来就好了
    if isLoad then
        if not ret["isLoad"] then ret["isLoad"] = {} end
        ret["isLoad"][data] = gf:getServerTime()
    else

        -- 保存的时候验证下有效性把
        if not ret[Me:queryBasic("gid")] then ret[Me:queryBasic("gid")] = {} end
        --
        for fileName, info in pairs(ret[Me:queryBasic("gid")]) do
            if not cc.FileUtils:getInstance():isFileExist(fileName) then
                ret[Me:queryBasic("gid")][fileName] = nil
            end
        end
        --]]

        if not ret[Me:queryBasic("gid")] then ret[Me:queryBasic("gid")] = {} end
        ret[Me:queryBasic("gid")][data.fileName] = data
    end

    local f = io.open(GoodVoiceMgr:getLocalVoiceFile(), "wb")
    local content = json.encode(ret)

    f:write(content)
    f:flush()
    f:close()
end

-- 发布留言
function GoodVoiceMgr:requestAddMessage(target_gid, target_iid, msg, gid, distName, targetDist, para)
    gf:CmdToServer("CMD_LEAVE_MESSAGE_WRITE", {host_gid = gid, target_gid = target_gid or "", target_iid = target_iid or "", msg = msg, user_dist = distName, target_dist = targetDist, para = para })
end

-- 请求留言信息
function GoodVoiceMgr:requestMessageData(message, num, gid, type, distName)
    type = type or 1
    gf:CmdToServer("CMD_LEAVE_MESSAGE_VIEW", {host_gid = gid, message_iid = message.iid or "", message_time = message.time or 0, message_num = num, query_type = type, user_dist = distName})
end


function GoodVoiceMgr:MSG_GOOD_VOICE_SEASON_DATA(data)
    GoodVoiceMgr.seasonData = data
end

function GoodVoiceMgr:MSG_GOOD_VOICE_COLLECT(data)
    GoodVoiceMgr.collectData = data
end

function GoodVoiceMgr:MSG_GOOD_VOICE_SHOW_LIST(data)
    if not GoodVoiceMgr.cache then GoodVoiceMgr.cache = {} end
    GoodVoiceMgr.cache[data.list_type] = {}
    GoodVoiceMgr.cache[data.list_type].data = data
    GoodVoiceMgr.cache[data.list_type].receiveTime = gfGetTickCount()
end

function GoodVoiceMgr:MSG_GOOD_VOICE_MY_VOICE(data)
    GoodVoiceMgr.myVoiceData = data
end

function GoodVoiceMgr:MSG_GOOD_VOICE_QUERY_VOICE(data)
--[[
    data.voice_addr = ChatMgr:getMediaSavePath() .. "forText.mp3"
 --   data.voice_dur = SoundMgr:getMusicDurationByName(data.voice_addr)

--]]

    local dlg = DlgMgr:getDlgByName("GoodVoiceDetailsDlg")
    if not dlg then
        dlg = DlgMgr:openDlg("GoodVoiceDetailsDlg")
        dlg:setPlayState(false, true)
        dlg:setMainInfo(data)
    else
        dlg:setMainInfo(data, true)
    end

end

function GoodVoiceMgr:stopPlayGoodVoiceAndReplayMusic()
    AudioEngine.stopMusic()
    if Me:isInCombat() or Me:isLookOn() then
        SoundMgr:playFightingBackupMusic()
    else
        SoundMgr:playMusic(MapMgr:getCurrentMapName())
    end
    SoundMgr:replayMusicAndSound()
end

function GoodVoiceMgr:generateScore(num)
    -- 生成颜色字符串控件
    local info = ATLAS_FONT_INFO["AtlasLabel0001"]
    local label = ccui.TextAtlas:create(tostring(num), ResMgr.ui.atlasLabel0001, info.width, info.height, info.startCharMap)

  -- local img = ccui.ImageView:create(ResMgr.ui.atlasLabel0001_add, ccui.TextureResType.localType)
   -- local imgSize = img:getContentSize()

    local layer = ccui.Layout:create()
    layer:setContentSize(cc.size(info.width, info.height))
    layer:ignoreAnchorPointForPosition(false)
    layer:setAnchorPoint(0.5, 0)


    label:setPosition((info.width / 2), info.height / 2)

    layer:addChild(label)
    return layer
end

MessageMgr:regist("MSG_GOOD_VOICE_QUERY_VOICE", GoodVoiceMgr)

MessageMgr:regist("MSG_GOOD_VOICE_MY_VOICE", GoodVoiceMgr)
MessageMgr:regist("MSG_GOOD_VOICE_SHOW_LIST", GoodVoiceMgr)
MessageMgr:regist("MSG_GOOD_VOICE_COLLECT", GoodVoiceMgr)
MessageMgr:regist("MSG_GOOD_VOICE_SEASON_DATA", GoodVoiceMgr)
