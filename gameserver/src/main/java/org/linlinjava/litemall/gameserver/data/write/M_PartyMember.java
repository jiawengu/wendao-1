package org.linlinjava.litemall.gameserver.data.write;

import com.alibaba.druid.sql.visitor.functions.Char;
import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.core.util.JSONUtils;
import org.linlinjava.litemall.db.domain.Characters;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.domain.GameParty;
import org.linlinjava.litemall.gameserver.domain.PartyMember;
import org.linlinjava.litemall.gameserver.game.GameData;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
import org.linlinjava.litemall.gameserver.game.PartyMgr;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;

public class M_PartyMember extends BaseWrite {
    private GameParty party;
    public M_PartyMember(GameParty party){
        this.party = party;
    }

    @Override
    protected void writeO(ByteBuf buf, Object obj) {
        PartyMember m = (PartyMember)obj;

        Chara chara = this.getChar(m.id);
        GameWriteTool.writeString(buf, String.valueOf(this.party.id));
        GameWriteTool.writeString(buf, chara.name);
        GameWriteTool.writeShort(buf, this.isOnline(m.id));
        GameWriteTool.writeShort(buf, 0); //portrait
        GameWriteTool.writeString(buf, "帮主"); //job
        GameWriteTool.writeShort(buf, chara.level);
        GameWriteTool.writeString(buf, ""); //family
        GameWriteTool.writeInt(buf, m.construction);
        GameWriteTool.writeInt(buf, 0); //active
        GameWriteTool.writeShort(buf, 0); //polor
        GameWriteTool.writeShort(buf, chara.sex);
        GameWriteTool.writeInt(buf, 0); //lastWeekActive
        GameWriteTool.writeInt(buf, 0); //thisWeekActive
        GameWriteTool.writeInt(buf, m.joinTime);
        GameWriteTool.writeInt(buf, 0); //tao
        GameWriteTool.writeShort(buf, 0); //warTimes
        GameWriteTool.writeInt(buf, 0); //logoutTime
        GameWriteTool.writeInt(buf, 0); //curWarTimes

    }

    @Override
    public int cmd() {
        return 0;
    }

    private Chara getChar(int id){
        GameObjectChar c = GameObjectCharMng.getGameObjectChar(id);
        if(c != null){
            return c.chara;
        }
        Characters cs = GameData.that.baseCharactersService.findById(id);
        return JSONUtils.parseObject(cs.getData(), Chara.class);
    }

    private int isOnline(int id){
        return GameObjectCharMng.getGameObjectChar(id) == null ? 0 : 1;
    }
}
