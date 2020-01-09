package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;

public class M_MSG_CREATE_PARTY_SUCC extends BaseWrite {
    protected void writeO(ByteBuf buf, Object object)
    {
        String name = (String)object;
        GameWriteTool.writeString(buf, name);
    }

    public int cmd()
    {
        return 0xB045;
    }
}
