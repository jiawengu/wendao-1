package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_MSG_PK_FINGER;
import org.linlinjava.litemall.gameserver.data.vo.Vo_MSG_ZUOLAO_INFO;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;
import org.springframework.stereotype.Component;

@Component
public class M_MSG_ZUOLAO_INFO extends BaseWrite {
    protected void writeO(ByteBuf buf, Object object)
    {
        Vo_MSG_ZUOLAO_INFO vo = (Vo_MSG_ZUOLAO_INFO) object;
        GameWriteTool.writeInt(buf, Integer.valueOf( vo.items.size()));
        vo.items.forEach(item->{
            GameWriteTool.writeString(buf, item.gid);
            GameWriteTool.writeString(buf, item.name);
            GameWriteTool.writeShort(buf, Integer.valueOf( item.level));
            GameWriteTool.writeString(buf, item.family);
            GameWriteTool.writeShort(buf, Integer.valueOf( item.polar));
            GameWriteTool.writeString(buf, item.server_name);
            GameWriteTool.writeInt(buf, Integer.valueOf((int) item.last_ti));
        });
    }

    public int cmd()
    {
        return 0xB0AD;
    }
}
