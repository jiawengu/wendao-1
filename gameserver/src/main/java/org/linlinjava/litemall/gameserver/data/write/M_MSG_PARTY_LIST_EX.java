package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.db.domain.Party;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_MSG_PARTY_LIST_EX;
import org.linlinjava.litemall.gameserver.domain.GameParty;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;

public class M_MSG_PARTY_LIST_EX extends BaseWrite {
    protected void writeO(ByteBuf buf, Object object)
    {
        Vo_MSG_PARTY_LIST_EX vo = (Vo_MSG_PARTY_LIST_EX)object;
        GameWriteTool.writeString(buf, vo.type);
        GameWriteTool.writeShort(buf, vo.parts.size());
        vo.parts.forEach(item->{
            String sid = String.valueOf(item.id);
            GameWriteTool.writeString(buf, sid);
            GameWriteTool.writeString(buf, item.data.getName());
            GameWriteTool.writeShort(buf, item.data.getLevel());
            GameWriteTool.writeShort(buf, 1); //population
            GameWriteTool.writeInt(buf, Integer.valueOf(item.data.getConstruction())); //construct
        });
    }
    public int cmd()
    {
        return 0xA011;
    }
}
