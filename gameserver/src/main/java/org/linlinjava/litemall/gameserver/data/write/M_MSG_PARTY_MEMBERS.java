package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_MSG_PARTY_MEMBERS;
import org.linlinjava.litemall.gameserver.domain.GameParty;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;

public class M_MSG_PARTY_MEMBERS extends BaseWrite {
    private GameParty party;
    public M_MSG_PARTY_MEMBERS(GameParty party){
        this.party = party;
    }
    @Override
    protected void writeO(ByteBuf buf, Object obj) {
        Vo_MSG_PARTY_MEMBERS vo = (Vo_MSG_PARTY_MEMBERS)obj;
        GameWriteTool.writeShort(buf, vo.page);
        GameWriteTool.writeShort(buf, vo.tail);
        GameWriteTool.writeShort(buf, vo.members.size());
        vo.members.forEach(m->{
            M_PartyMember M_m = new M_PartyMember(this.party);
            M_m.writeO(buf, m);
        });
    }

    @Override
    public int cmd() {
        return 0xF0A3;
    }
}
