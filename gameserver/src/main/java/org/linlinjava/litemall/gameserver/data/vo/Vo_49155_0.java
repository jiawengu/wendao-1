package org.linlinjava.litemall.gameserver.data.vo;

public class Vo_49155_0
{
    /**
     * 当前层
     */
    public short curLayer;
    /**
     * 目标层
     */
    public short breakLayer;
    /**
     * 当前状态（1：开始挑战，2：挑战下层，3：继续挑战）
     */
    public byte curType;
    public int topLayer;
    public String npc;
    /**
     * 剩余挑战次数
     */
    public int challengeCount;
    /**
     * 奖励类型：exp，tao
     */
    public String bonusType;
    /**
     * 还没用完成神秘房间
     */
    public int hasNotCompletedSmfj;
}

