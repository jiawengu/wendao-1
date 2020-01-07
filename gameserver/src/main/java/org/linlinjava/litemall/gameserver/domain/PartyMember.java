package org.linlinjava.litemall.gameserver.domain;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.db.domain.Characters;
import org.linlinjava.litemall.db.domain.Party;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;

public class PartyMember {
    public int id = 0;
    public int construction = 0;
    public int joinTime = 0;

    public PartyMember(){
    }
}
