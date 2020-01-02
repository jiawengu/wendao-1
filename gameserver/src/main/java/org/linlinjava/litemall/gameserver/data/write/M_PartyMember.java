package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.domain.PartyMember;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;

public class M_PartyMember extends BaseWrite {
    @Override
    protected void writeO(ByteBuf buf, Object obj) {
        PartyMember m = (PartyMember)obj;
        GameWriteTool.writeString(buf, m.name);
        GameWriteTool.writeShort(buf, m.no);
        GameWriteTool.writeShort(buf, m.level);
        GameWriteTool.writeInt(buf, m.currentScore);
        GameWriteTool.writeInt(buf, m.levelupScore);
    }

    @Override
    public int cmd() {
        return 0;
    }
}
