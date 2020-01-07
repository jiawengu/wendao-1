-- MasterMgr.lua
-- Created by songcw June/1/2016
-- 拜师系统管理器

MasterMgr = Singleton()

local MATSER_LEVEL = 72     -- 当师傅、出师等级  MSG_NOTIFY_CHUSHI_LEVEL会改变该值
local MATSER_DEFAULT_LEVEL = 72     -- 默认出师等级
local MASTER_MIN_LEVEL = 20 -- 当徒弟的最小等级

MasterMgr.teachersInfo = {}     -- 登记的师父列表
MasterMgr.teacherListLastTime = 0   -- 上次请求的时间
MasterMgr.studentInfo = {}      -- 登记的徒弟列表
MasterMgr.studentListLastTime = 0   -- 上次请求的时间
MasterMgr.applyInfo = {}        -- 申请的列表
MasterMgr.applyListLastTime = 0   -- 上次请求的时间
MasterMgr.myMasterInfo = {}     -- 我的师徒信息

local TIME_INTERVAL = 3000

local SHOUYE_TASK_INFO = {
    [1] = {index = 1, name = CHS[6000106], intro = CHS[4200109], round = 10, level = 10},
    [2] = {index = 2, name = CHS[3000270], intro = CHS[4200110], round = 20, level = 20},
    [3] = {index = 3, name = CHS[3000279], intro = CHS[4200111], round = 5, level = 30},
    [4] = {index = 4, name = CHS[3000283], intro = CHS[4200112], round = 10, level = 30},
    [5] = {index = 5, name = CHS[3000734], intro = CHS[4200113], round = 2, level = 35},
    [6] = {index = 6, name = CHS[3000295], intro = CHS[4200114], round = 1, level = 35},
    [7] = {index = 7, name = CHS[6000107], intro = CHS[4200115], round = 1, level = 35},
    [8] = {index = 8, name = CHS[2000073], intro = CHS[4200116], round = 1, level = 60},
    [9] = {index = 9, name = CHS[3000314], intro = CHS[4200117], round = 1, level = 60},
}

function MasterMgr:clearData()
    MasterMgr.teachersInfo = {}     -- 登记的师父列表
    MasterMgr.teacherListLastTime = 0   -- 上次请求的时间
    MasterMgr.studentInfo = {}      -- 登记的徒弟列表
    MasterMgr.studentListLastTime = 0   -- 上次请求的时间
    MasterMgr.applyInfo = {}        -- 申请的列表
    MasterMgr.applyListLastTime = 0   -- 上次请求的时间
    MasterMgr.myMasterInfo = {}     -- 我的师徒信息

    MasterMgr.lookingForSMsg = nil
    MasterMgr.lookingForTMsg = nil
end

function MasterMgr:getBeMasterLevel()
    return MATSER_LEVEL
end

function MasterMgr:getMinMasterLevel()
    return MASTER_MIN_LEVEL
end

-- 查询我的师徒信息
function MasterMgr:cmdQueryMyMaster()
    Log:D("============查询我的师徒信息====================")
    gf:CmdToServer("CMD_MY_APPRENTICE_INFO")
end

function MasterMgr:getMyMasterInfo()
    return MasterMgr.myMasterInfo
end

-- 是否已存在师徒关系   若未收到服务器消息，默认无
function MasterMgr:isHasMasterRelation()
    if next(MasterMgr.myMasterInfo) and MasterMgr.myMasterInfo.count > 0 then
        return true
    end

    return
end

-- 我是否有师父
function MasterMgr:meHasTeacher()
    if next(MasterMgr.myMasterInfo) and MasterMgr.myMasterInfo.count ~= 0 and not self:isTeacher() then
        return true
    end

    return
end

function MasterMgr:getMastersInfo()
    return self.teachersInfo
end

-- 是否登记过寻师
function MasterMgr:isRegistTeach()
    if next(self.teachersInfo) then return end
    for i = 1, self.teachersInfo.count do
        local teacher = self.teachersInfo.userInfo[i]
        if teacher.name == Me:getName() then
            return true
        end
    end

    return false
end

-- 是否是我师父
function MasterMgr:isMyTeacherByName(name)
    if not next(MasterMgr.myMasterInfo) or self:isTeacher() then
        return false
    end


    for i = 1, MasterMgr.myMasterInfo.count do
        local play = MasterMgr.myMasterInfo.userInfo[i]
        if play.name == name and play.isMaster == 1 then
            return true
        end
    end

    return false
end

-- 是否是我徒弟
function MasterMgr:isMyStudentByName(name)
    if not next(MasterMgr.myMasterInfo) or not self:isTeacher() then
        return false
    end

    for i = 1, MasterMgr.myMasterInfo.count do
        local play = MasterMgr.myMasterInfo.userInfo[i]
        if play.name == name and play.isMaster == 0 then
            return true
        end
    end

    return false
end

-- 是否是我师父
function MasterMgr:isMyTeacherByGid(gid)
    if not next(MasterMgr.myMasterInfo) or self:isTeacher() then
        return false
    end


    for i = 1, MasterMgr.myMasterInfo.count do
        local play = MasterMgr.myMasterInfo.userInfo[i]
        if play.gid == gid and play.isMaster == 1 then
            return true
        end
    end

    return false
end

-- 是否是我徒弟
function MasterMgr:isMyStudentByGid(gid)
    if not next(MasterMgr.myMasterInfo) or not self:isTeacher() then
        return false
    end

    for i = 1, MasterMgr.myMasterInfo.count do
        local play = MasterMgr.myMasterInfo.userInfo[i]
        if play.gid == gid and play.isMaster == 0 then
            return true
        end
    end

    return false
end

-- 获取登记的徒弟列表
function MasterMgr:getStudentInfo()
    return self.studentInfo
end

-- 获取申请列表
function MasterMgr:getApplyInfo()

    return self.applyInfo
end

function MasterMgr:releaseRelation(gid)
    if not gid then return end
    if self:isTeacher() then
        gf:CmdToServer("CMD_RELEASE_APPRENTICE_RELATION", {type = 2, gid = gid})
    else
        gf:CmdToServer("CMD_RELEASE_APPRENTICE_RELATION", {type = 1, gid = gid})
    end
end

-- 查询师父列表    如果小于时间间隔，则不发送，返回false，
function MasterMgr:searchTeacherList(refreshOldData)
    if gfGetTickCount() - self.teacherListLastTime >= TIME_INTERVAL then
        Log:D("============查询师父列表====================")
        gf:CmdToServer("CMD_REQUEST_APPRENTICE_INFO", {type = 1})
        self.teacherListLastTime = gfGetTickCount()
        return true
    end

    if refreshOldData and MasterMgr:getMastersInfo() then
        DlgMgr:sendMsg("MasterDlg", "MSG_SEARCH_MASTER_INFO")
    end
    return false
end

-- 查询徒弟列表
function MasterMgr:searchStudentList(refreshOldData)
    if gfGetTickCount() - self.studentListLastTime >= TIME_INTERVAL then
        Log:D("============查询徒弟列表====================")
        gf:CmdToServer("CMD_REQUEST_APPRENTICE_INFO", {type = 2})
        self.studentListLastTime = gfGetTickCount()
        return true
    end

    if refreshOldData and MasterMgr:getStudentInfo() then
        DlgMgr:sendMsg("MasterDlg", "MSG_SEARCH_APPRENTICE_INFO")
    end
    return false
end

-- 查询申请列表
function MasterMgr:searchApplyList(refreshOldData)
    if gfGetTickCount() - self.applyListLastTime >= TIME_INTERVAL then
        Log:D("============查询申请列表====================")
        gf:CmdToServer("CMD_REQUEST_APPRENTICE_INFO", {type = 5})
        self.applyListLastTime = gfGetTickCount()
        return true
    end

    if refreshOldData and MasterMgr:getApplyInfo() then
        DlgMgr:sendMsg("MasterDlg", "MSG_REQUEST_APPENTICE_INFO")
    end
    return false
end

-- 我要寻找师    type:1表示发布
function MasterMgr:cmdLookingTeacher(str)
    Log:D("============发布寻师====================")
    gf:CmdToServer("CMD_SEARCH_MASTER", {type = 1, msg = str})
end

-- 我要寻找徒    type:1表示发布
function MasterMgr:cmdLookingStudent(str)
    Log:D("============发布寻徒====================")
    gf:CmdToServer("CMD_SEARCH_APPRENTICE", {type = 1, msg = str})
end

-- 申请拜师
function MasterMgr:cmdBeStudent(gid, str)
    if not gid then return end
    gf:CmdToServer("CMD_APPLY_FOR_APPRENTICE", {type = 1, gid = gid, message = str})
end

-- 申请收徒
function MasterMgr:cmdBeTeacher(gid, str)
    if not gid then return end
    gf:CmdToServer("CMD_APPLY_FOR_MASTER", {type = 1, gid = gid, message = str})
end

-- 同意对方拜师申请
function MasterMgr:cmdIdoBecomeTeacher(gid, isNeedTip)
    if not gid then return end
    if isNeedTip then
        gf:CmdToServer("CMD_APPLY_FOR_APPRENTICE", {type = 2, gid = gid, message = "1"})
    else
        gf:CmdToServer("CMD_APPLY_FOR_APPRENTICE", {type = 2, gid = gid, message = "0"})
    end
end

-- 拒绝对方拜师申请
function MasterMgr:cmdIRefusedBecomeTeacher(gid, isNeedTip)
    if not gid then return end
    if isNeedTip then
        gf:CmdToServer("CMD_APPLY_FOR_APPRENTICE", {type = 3, gid = gid, message = "1"})
    else
        gf:CmdToServer("CMD_APPLY_FOR_APPRENTICE", {type = 3, gid = gid, message = "0"})
    end
end

-- 同意对方收徒申请
function MasterMgr:cmdIdoBecomeStudent(gid, isNeedTip)
    if not gid then return end
    if isNeedTip then
        gf:CmdToServer("CMD_APPLY_FOR_MASTER", {type = 2, gid = gid, message = "1"})
    else
        gf:CmdToServer("CMD_APPLY_FOR_MASTER", {type = 2, gid = gid, message = "0"})
    end
end

-- 拒绝对方收徒申请
function MasterMgr:cmdIRefusedBecomeStudent(gid, isNeedTip)
    if not gid then return end
    if isNeedTip then
        gf:CmdToServer("CMD_APPLY_FOR_MASTER", {type = 3, gid = gid, message = "1"})
    else
        gf:CmdToServer("CMD_APPLY_FOR_MASTER", {type = 3, gid = gid, message = "0"})
    end
end

-- 撤销寻师、寻徒
function MasterMgr:cmdCancelLooking()
    if self:isTeacher() then
        gf:CmdToServer("CMD_SEARCH_APPRENTICE", {type = 3, msg = ""})
    else
        gf:CmdToServer("CMD_APPLY_FOR_MASTER", {type = 3, msg = ""})
    end
end

-- 修改寻师、寻徒留言
function MasterMgr:cmdModifyLookingForMsg(msg)
    if self:isTeacher() then
        MasterMgr:cmdModifyLookingForStudentMsg(msg)
    else
        MasterMgr:cmdModifyLookingForTeacherMsg(msg)
    end
end

-- 修改寻徒留言
function MasterMgr:cmdModifyLookingForStudentMsg(msg)
    gf:CmdToServer("CMD_SEARCH_APPRENTICE", {type = 2, msg = msg})
end

-- 修改寻师留言
function MasterMgr:cmdModifyLookingForTeacherMsg(msg)
    gf:CmdToServer("CMD_SEARCH_MASTER", {type = 2, msg = msg})
end

-- 撤销留言
function MasterMgr:cmdCancelLookingForMsg(msg)
    if self:isTeacher() then
        MasterMgr:cmdCancelLookingForStudentMsg(msg)
    else
        MasterMgr:cmdCancelLookingForTeacherMsg(msg)
    end
end

-- 撤销寻师
function MasterMgr:cmdCancelLookingForTeacherMsg(msg)
    gf:CmdToServer("CMD_SEARCH_MASTER", {type = 3, msg = msg})
end

-- 撤销寻徒
function MasterMgr:cmdCancelLookingForStudentMsg(msg)
    gf:CmdToServer("CMD_SEARCH_APPRENTICE", {type = 3, msg = msg})
end

-- 修改关系界面中师父留言
function MasterMgr:modifyRelationTeacherMsg(msg)
    gf:CmdToServer("CMD_CHANGE_MASTER_MESSAGE", {msg = msg})
end

-- 请求徒弟今日随机任务
function MasterMgr:requestTodayTask(gid)
    gf:CmdToServer("CMD_REQUEST_CDSY_TODAY_TASK", {gid = gid})
end

-- 发布传道授业任务
function MasterMgr:publishTask(gid, name)
    gf:CmdToServer("CMD_PUBLISH_CDSY_TASK", {gid = gid, name = name})
end

function MasterMgr:getTeacherInfoInMaster()
    if not next(MasterMgr.myMasterInfo) then
        return
    end

    for i = 1, MasterMgr.myMasterInfo.count do
        local play = MasterMgr.myMasterInfo.userInfo[i]
        if play.isMaster == 1 then
            return play
        end
    end
    return
end

function MasterMgr:getMeInfoInMaster()
    if not next(MasterMgr.myMasterInfo) then
        return
    end

    for i = 1, MasterMgr.myMasterInfo.count do
        local play = MasterMgr.myMasterInfo.userInfo[i]
        if play.gid == Me:queryBasic("gid") then
            return play
        end
    end
    return
end

-- 获取我的师父
function MasterMgr:getMyTeacherInfo()
    if not next(MasterMgr.myMasterInfo) then
        return
    end

    for i = 1, MasterMgr.myMasterInfo.count do
        local play = MasterMgr.myMasterInfo.userInfo[i]
        if play.isMaster == 1 and play.gid ~= Me:queryBasic("gid") then
            return play
        end
    end
    return
end

-- 获取我的徒弟
function MasterMgr:getMyStudentsInfo()
    if not next(MasterMgr.myMasterInfo) then
        return
    end

    local students = {}
    for i = 1, MasterMgr.myMasterInfo.count do
        local play = MasterMgr.myMasterInfo.userInfo[i]
        if play.isMaster == 1 and play.gid ~= Me:queryBasic("gid") then
            return
        elseif play.isMaster == 0 then
            table.insert(students, play)
        end
    end

    return students
end

function MasterMgr:isMaster()
    -- 如果没有师徒关系
    if not next(MasterMgr.myMasterInfo) or MasterMgr.myMasterInfo.count == 0 then
        return false
    end

    for i = 1, MasterMgr.myMasterInfo.count do
        local play = MasterMgr.myMasterInfo.userInfo[i]
        if play.gid == Me:queryBasic("gid") and play.isMaster == 1 then
            return true
        end
    end
    return false
end

function MasterMgr:isTeacher()
    -- 等级少于72徒弟   MATSER_LEVEL
    if Me:queryBasicInt("level") < 72 then
        return false
    end

    -- 如果没有师徒关系，等级大于73算师父
    if not next(MasterMgr.myMasterInfo) or MasterMgr.myMasterInfo.count == 0 then
        return true
    end

    for i = 1, MasterMgr.myMasterInfo.count do
        local play = MasterMgr.myMasterInfo.userInfo[i]
        if play.gid == Me:queryBasic("gid") and play.isMaster == 1 then
            return true
        end
    end
    return false
end

function MasterMgr:MSG_SEARCH_APPRENTICE_INFO(data)
    MasterMgr.studentInfo = data
end

function MasterMgr:MSG_SEARCH_MASTER_INFO(data)
    MasterMgr.teachersInfo = data
end

function MasterMgr:MSG_REQUEST_APPENTICE_INFO(data)
    MasterMgr.applyInfo = data
end

function MasterMgr:getLastMyMasterInfo()
    return MasterMgr.lastMyMasterInfo
end

function MasterMgr:MSG_MY_APPENTICE_INFO(data)
    -- 上一次师徒信息，用于刷新列表
    local tempData = gf:deepCopy(MasterMgr.myMasterInfo)
    if tempData and next(tempData) and tempData.count ~= data.count then
        MasterMgr.lastMyMasterInfo = tempData
    else
        MasterMgr.lastMyMasterInfo = nil
    end

    -- 当前师徒数据
    MasterMgr.myMasterInfo = data
    for i = 1, MasterMgr.myMasterInfo.count do
        local user = MasterMgr.myMasterInfo.userInfo[i]
        if user.isMaster == 0 and user.gid == Me:queryBasic("gid") then
            user.studentOrder = 1
        else
            user.studentOrder = 0
        end

        local shouyeCompleteCount = 0
        -- 计算完成情况
        for i = 1, user.shouyeCount do
            user.shouyeInfo[i].taskName = SHOUYE_TASK_INFO[user.shouyeInfo[i].index].name
            user.shouyeInfo[i].timeMax = SHOUYE_TASK_INFO[user.shouyeInfo[i].index].round
            user.shouyeInfo[i].intro = SHOUYE_TASK_INFO[user.shouyeInfo[i].index].intro
            user.shouyeInfo[i].isComplete = (user.shouyeInfo[i].completeTimes >= user.shouyeInfo[i].timeMax)
            if user.shouyeInfo[i].isComplete then shouyeCompleteCount = shouyeCompleteCount + 1 end
        end
        user.shouyeCompleteCount = shouyeCompleteCount
    end

    table.sort(MasterMgr.myMasterInfo.userInfo, function(l, r)
        if l.isMaster > r.isMaster then return true end
        if l.isMaster < r.isMaster then return false end
        if l.studentOrder > r.studentOrder then return true end
        if l.studentOrder < r.studentOrder then return false end
        if l.masterTime < r.masterTime then return true end
        if l.masterTime > r.masterTime then return false end
    end)
end

function MasterMgr:MSG_REQUEST_APPRENTICE_SUCCESS(data)
    local count = 0
    if data.type == 2 then
        if self.teachersInfo then
            count = self.teachersInfo.count or 0
        end
        for i = 1, count do
            if self.teachersInfo.userInfo[i].gid == data.gid then
                self.teachersInfo.userInfo[i].isApply = 1
            end
        end
    elseif data.type == 1 then
        if self.studentInfo then
            count = self.studentInfo.count or 0
        end
        for i = 1, count do
            if self.studentInfo.userInfo[i].gid == data.gid then
                self.studentInfo.userInfo[i].isApply = 1
            end
        end
    end
end

function MasterMgr:MSG_MY_SEARCH_MASTER_MESSAGE(data)
    MasterMgr.lookingForTMsg = data
    if not next(self.studentInfo) then return end
    for i = 1, self.studentInfo.count do
        if self.studentInfo.userInfo[i].name == Me:getName() then
            self.studentInfo.userInfo[i].message = data.message
        end
    end
end

function MasterMgr:MSG_MY_SEARCH_APPRENTICE_MESSAGE(data)
    MasterMgr.lookingForSMsg = data
    if not next(self.teachersInfo) then return end
    for i = 1, self.teachersInfo.count do
        if self.teachersInfo.userInfo[i].name == Me:getName() then
            self.teachersInfo.userInfo[i].message = data.message
        end
    end
end

function MasterMgr:MSG_MY_MASTER_MESSAGE(data)
    self.myTeacherMsg = data.message
end

function MasterMgr:getShouyeTaskInfo()
    return SHOUYE_TASK_INFO
end

function MasterMgr:getRewardMaster()
    local data = {}
    data.name = CHS[4200086] -- [4200086] = "师徒任务",
    data.time = CHS[4200046] -- [4200046] = "不限",
    data.level = string.format(CHS[4200089], MATSER_LEVEL)
    data.team = CHS[4200048] -- [4200048] = "师徒组队",
    data.desc = CHS[4200090]
    data.studentReward = CHS[4200091]
    data.teacherReward = CHS[5420350]
    return data
end

function MasterMgr:getRewardGraduate()
    local data = {}
    data.name = CHS[4200045] -- [4200045] = "出师任务",
    data.time = CHS[4200046] -- [4200046] = "不限",
    data.level = string.format(CHS[4200047], MATSER_DEFAULT_LEVEL) -- [4200047] = "徒弟等级大于等于%d级",
    data.team = CHS[4200048] -- [4200048] = "师徒组队",
    data.desc = CHS[4200049] -- [4200049] = "师徒二人需共同完成出师任务考验，进行最后一次授业。",
    data.reward = CHS[4200050] -- "#I道行|道行#I#I武学|武学#I#I物品|超级灵石#I#I物品|超级晶石#I",
    return data
end

function MasterMgr:getRewardChuandao()
    local data = {}
    data.name = CHS[4200099] -- [4200099] = "传道授业",
    data.time = CHS[4200118]
    data.introduce = CHS[4200119]
    data.studentReward = CHS[4200120]
    data.teacherReward =  CHS[4200121]
    return data
end

function MasterMgr:MSG_NOTIFY_CHUSHI_LEVEL(data)
    MATSER_LEVEL = data.chushiLevel
    DlgMgr:closeDlg("MasterDlg")
    DlgMgr:closeDlg("MasterRelationDlg")
    DlgMgr:closeDlg("MessageDlg")
end

function MasterMgr:meIsChuShi()
    return Me:queryBasicInt("chushi_ex") == 1
end


MessageMgr:regist("MSG_NOTIFY_CHUSHI_LEVEL", MasterMgr)
MessageMgr:regist("MSG_REQUEST_APPRENTICE_SUCCESS", MasterMgr)
MessageMgr:regist("MSG_MY_APPENTICE_INFO", MasterMgr)
MessageMgr:regist("MSG_REQUEST_APPENTICE_INFO", MasterMgr)
MessageMgr:regist("MSG_SEARCH_APPRENTICE_INFO", MasterMgr)
MessageMgr:regist("MSG_SEARCH_MASTER_INFO", MasterMgr)
MessageMgr:regist("MSG_MY_SEARCH_MASTER_MESSAGE", MasterMgr)
MessageMgr:regist("MSG_MY_SEARCH_APPRENTICE_MESSAGE", MasterMgr)
MessageMgr:regist("MSG_MY_MASTER_MESSAGE", MasterMgr)


return MasterMgr
