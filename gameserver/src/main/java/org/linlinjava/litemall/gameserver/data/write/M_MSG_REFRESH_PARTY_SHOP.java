package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_MSG_REFRESH_PARTY_SHOP;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;

public class M_MSG_REFRESH_PARTY_SHOP extends BaseWrite {
    @Override
    protected void writeO(ByteBuf buf, Object obj) {
        Vo_MSG_REFRESH_PARTY_SHOP vo = (Vo_MSG_REFRESH_PARTY_SHOP)obj;
        GameWriteTool.writeInt(buf, vo.costWing);
        GameWriteTool.writeByte(buf, vo.list.size());

        vo.list.forEach(item->{
            GameWriteTool.writeString(buf, item.name);
            GameWriteTool.writeShort(buf, item.num);
            GameWriteTool.writeInt(buf, item.cost);
        });
    }

    @Override
    public int cmd() {
        return 0x8017;
    }
}
