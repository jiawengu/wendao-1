package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_MSG_REQUEST_LIST_Item;
import org.linlinjava.litemall.gameserver.data.vo.Vo_MSG_REQUEST_LIST_Item_body;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;

public class M_MSG_REQUEST_LIST_Item extends BaseWrite {
    private String ask_type;
    public M_MSG_REQUEST_LIST_Item(String ask_type) {
        this.ask_type = ask_type;
    }

    @Override
    protected void writeO(ByteBuf buf, Object obj) {
        Vo_MSG_REQUEST_LIST_Item vo = (Vo_MSG_REQUEST_LIST_Item) obj;
        GameWriteTool.writeString(buf, vo.peer_name);
        GameWriteTool.writeShort(buf, vo.list.size());
        vo.list.forEach(item -> {
            new M_MSG_REQUEST_LIST_Item_body(this.ask_type).writeO(buf, item);
        });
    }

    @Override
    public int cmd() {
        return 0;
    }
}
