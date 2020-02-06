package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_MSG_PET_UPGRADE_SUCC;
import org.linlinjava.litemall.gameserver.data.vo.Vo_MSG_PK_RECORD;
import org.linlinjava.litemall.gameserver.domain.BuildFields;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;
import org.springframework.stereotype.Component;

@Component
public class M_MSG_PK_RECORD extends BaseWrite {
    protected void writeO(ByteBuf buf, Object object)
    {
        Vo_MSG_PK_RECORD vo = (Vo_MSG_PK_RECORD) object;
        GameWriteTool.writeString(buf, vo.type);
        GameWriteTool.writeShort(buf, vo.items.size());
        vo.items.forEach(item->{
            //BuildFields.get("str").write(buf, item.name);
            GameWriteTool.writeString(buf, item.gid);
            GameWriteTool.writeString(buf, item.update_time);
            GameWriteTool.writeString(buf, item.server_name);
            GameWriteTool.writeShort(buf, 3);
            write(buf, "name", item.name);
            write(buf, "level", item.level);
            write(buf, "icon", item.icon);

//            BuildFields.get("iid_str").write(buf, item.gid);
//            BuildFields.get("level").write(buf, item.level);
//            BuildFields.get("icon").write(buf, item.icon);
//            BuildFields.get("server_name").write(buf, item.server_name);
        });
    }

    public void write(ByteBuf writeBuf, String key, Object str) {
            BuildFields fields = BuildFields.get(key);
             if ((str instanceof String)) {
               writeBuf.writeShort(fields.key+1);
               writeBuf.writeByte(4);
               GameWriteTool.writeString(writeBuf, String.valueOf(str));
             } else {
               writeBuf.writeShort(fields.key+1);
               writeBuf.writeByte(3);
               GameWriteTool.writeInt(writeBuf, Integer.valueOf(String.valueOf(str)));
             }
           }

    public int cmd()
    {
        return 0xB0A8;
    }
}
