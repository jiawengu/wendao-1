package org.linlinjava.litemall.gameserver.data.write;


import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_45090_0;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;


/**
 * MSG_TONGTIANTA_JUMP 通天塔飞升成功
 */
@org.springframework.stereotype.Service
public class M45090_0 extends BaseWrite {

    protected void writeO(ByteBuf writeBuf, Object object) {
        Vo_45090_0 object1 = (Vo_45090_0) object;
        GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.costType));

        GameWriteTool.writeLong(writeBuf, Long.valueOf(object1.costCount));

        GameWriteTool.writeLong(writeBuf, Long.valueOf(object1.jumpCount));
    }

    public int cmd() {
        return 45090;
    }

}