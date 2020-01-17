package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_15855_0;


@org.springframework.stereotype.Service
public class MSG_C_MANA_DELTA extends org.linlinjava.litemall.gameserver.netty.BaseWrite {
    protected void writeO(ByteBuf writeBuf, Object object) {
        Vo_15855_0 object1 = (Vo_15855_0) object;
        GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.id));

        GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.hitter_id));

        GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.point));

        GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.effect_no));
    }

    public int cmd() {
        return 15855;
    }
}
