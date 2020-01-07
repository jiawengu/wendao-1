package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_MSG_DIALOG;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;

public class M_MSG_DIALOG extends BaseWrite {
    @Override
    protected void writeO(ByteBuf buf, Object obj) {
        Vo_MSG_DIALOG vo = (Vo_MSG_DIALOG)obj;
        GameWriteTool.writeString(buf, vo.caption);
        GameWriteTool.writeString(buf, vo.content);
        GameWriteTool.writeString(buf, vo.peer_name);
        GameWriteTool.writeString(buf, vo.ask_type);
        GameWriteTool.writeShort(buf, vo.list.size());
        vo.list.forEach(item->{
            new M_MSG_DIALOG_item(vo.ask_type).writeO(buf, item);
        });
        GameWriteTool.writeByte(buf, vo.flag);
    }

    @Override
    public int cmd() {
        return 0x4FF3;
    }
}
