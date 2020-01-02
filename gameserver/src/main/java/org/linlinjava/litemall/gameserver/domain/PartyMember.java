package org.linlinjava.litemall.gameserver.domain;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.db.domain.Characters;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;

public class PartyMember {
    public int id = 0;
    public String name = "";
    public int no = 0;
    public int level = 0;
    public int currentScore = 0;
    public int levelupScore = 0;

    public PartyMember(Chara c){
        this.id = c.id;
        this.name = c.name;
        this.no = 0;
        this.level = c.level;
        this.currentScore = 0;
        this.levelupScore = 10;
    }
}
