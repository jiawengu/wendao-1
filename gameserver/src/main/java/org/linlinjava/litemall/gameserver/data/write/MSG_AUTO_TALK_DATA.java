package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_32913_0;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;
import org.springframework.stereotype.Service;

/**
 * 通知客户端自动喊话信息
 */
@Service
public class MSG_AUTO_TALK_DATA extends BaseWrite {
    @Override
    protected void writeO(ByteBuf writeBuf, Object paramObject) {
        Vo_32913_0 vo_32913_0 = (Vo_32913_0) paramObject;

        GameWriteTool.writeInt(writeBuf, vo_32913_0.id);
        GameWriteTool.writeString(writeBuf, vo_32913_0.content);
    }
    @Override
    public int cmd() {
        return 32913;
    }
}

