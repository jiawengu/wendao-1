package org.linlinjava.litemall.gameserver.data.write;


import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_45704_0;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;


/**
 * MSG_TTT_NEW_XING 当前通天塔的星君
 */
@org.springframework.stereotype.Service
public class MSG_TTT_NEW_XING extends BaseWrite {

    protected void writeO(ByteBuf writeBuf, Object object) {
        Vo_45704_0 object1 = (Vo_45704_0) object;
        GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.result));

        GameWriteTool.writeString(writeBuf, object1.xing_name);
    }

    public int cmd() {
        return 45704;
    }

}