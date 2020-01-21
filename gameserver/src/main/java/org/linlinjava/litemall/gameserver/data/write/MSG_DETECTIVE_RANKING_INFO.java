package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;

/**
 * 十佳捕快排行榜
 */
@org.springframework.stereotype.Service
public class MSG_DETECTIVE_RANKING_INFO extends org.linlinjava.litemall.gameserver.netty.BaseWrite{
    @Override
    protected void writeO(ByteBuf paramByteBuf, Object paramObject) {

    }

    @Override
    public int cmd() {
        return 20711;
    }
}
