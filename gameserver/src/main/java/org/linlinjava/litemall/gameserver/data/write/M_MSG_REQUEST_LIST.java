package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_MSG_REQUEST_LIST;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;

public class M_MSG_REQUEST_LIST extends BaseWrite {
    @Override
    protected void writeO(ByteBuf buf, Object obj) {
        Vo_MSG_REQUEST_LIST vo = (Vo_MSG_REQUEST_LIST)obj;
        GameWriteTool.writeString(buf, vo.ask_type);
        GameWriteTool.writeShort(buf, vo.list.size());
        vo.list.forEach(item->{
            new M_MSG_REQUEST_LIST_Item(vo.ask_type).writeO(buf, item);
        });
    }

    @Override
    public int cmd() {
        return 0xD1ED;
    }
}
