-- created by cheny Feb/19/2014
-- 保持连接

local KeepAlive = class("KeepAlive")

-- ECHO(keep alive)间隔时间（秒）
local ECHO_INTERVAL = 10

-- ECHO(keep alive)间隔时间（毫秒）
local ECHO_MILSEC_INTERVAL = (ECHO_INTERVAL * 1000)

function KeepAlive:ctor()
	self._lastSendTime   = 0 -- 最后一次发送CMD_ECHO的时间
	self._lastRecvTime   = 0 -- 最后一次收到MSG_REPLY_ECHO的时间
	self._replyTime      = 0 -- 上次收到CMD_ECHO时应答的时间
	self._peerTime       = 0 -- 上次收到CMD_REPLY_ECHO中对方指明的时间
end

function KeepAlive:sendCmdEcho(conn)
	local currentTime = gfGetTickCount()
	if currentTime - self._lastSendTime < ECHO_MILSEC_INTERVAL then
		return
	end
	self._lastSendTime = currentTime

	-- current_time     本地的时间
	-- peer_time        对方的时间（在最后一次CMD_REPLY_ECHO应答中获得）
	gf:CmdToServer("CMD_ECHO", {
		current_time = self._lastSendTime,
		peer_time = self._peerTime
	})
end

function KeepAlive:onRecvCmdEcho()
	self._replyTime = gfGetTickCount()

	-- reply_time 应答时携带的本地时间
	gf:CmdToServer("MSG_REPLY_ECHO", {
		reply_time = self._replyTime
	})
end

function KeepAlive:onRecvMsgReplyEcho(peer_time)
	self._peerTime = peer_time
	-- 更新收到应答时间
	self._lastRecvTime = gfGetTickCount()
end

return KeepAlive
