package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_7659_0;

/**
 * MSG_C_WAIT_COMMAND
 */
@org.springframework.stereotype.Service
public class MSG_C_WAIT_COMMAND extends org.linlinjava.litemall.gameserver.netty.BaseWrite {
    protected void writeO(ByteBuf writeBuf, Object object) {
        Vo_7659_0 object1 = (Vo_7659_0) object;
        GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.a));

        GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.id));
        //等待时间
        GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.time));

        GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.question));

        GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.round));

        GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.curTime));
    }

    public int cmd() {
        return 7659;
    }
}

