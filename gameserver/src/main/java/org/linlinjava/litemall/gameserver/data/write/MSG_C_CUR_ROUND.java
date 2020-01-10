package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_45141_0;


/**
 * MSG_C_CUR_ROUND
 */
@org.springframework.stereotype.Service
public class MSG_C_CUR_ROUND extends org.linlinjava.litemall.gameserver.netty.BaseWrite {
    protected void writeO(ByteBuf writeBuf, Object object) {
        Vo_45141_0 object1 = (Vo_45141_0) object;
        GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.round));

        GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.animate_done));
    }

    public int cmd() {
        return 45141;
    }
}

