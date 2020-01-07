package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.domain.GameParty;
import org.linlinjava.litemall.gameserver.domain.PartyMember;
import org.linlinjava.litemall.gameserver.game.GameMap;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;

public class M_MSG_PARTY_QUERY_MEMBER extends BaseWrite {
    private GameParty party;
    public M_MSG_PARTY_QUERY_MEMBER(GameParty party){
        this.party = party;
    }

    @Override
    protected void writeO(ByteBuf buf, Object obj) {
        PartyMember m = (PartyMember)obj;

    }

    @Override
    public int cmd() {
        return 0xF0A5;
    }
}
