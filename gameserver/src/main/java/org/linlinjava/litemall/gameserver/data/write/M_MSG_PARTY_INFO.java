package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.domain.GameParty;
import org.linlinjava.litemall.gameserver.domain.PartyOfficers;
import org.linlinjava.litemall.gameserver.game.PartyMgr;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;

public class M_MSG_PARTY_INFO extends BaseWrite {
    protected void writeO(ByteBuf buf, Object object)
    {
        GameParty p = (GameParty)object;
        GameWriteTool.writeString(buf, PartyMgr.makeIdStr(p.id));
        GameWriteTool.writeString(buf, p.data.getName());
        GameWriteTool.writeString(buf, ""); //baseInfo
        GameWriteTool.writeString2(buf, p.data.getAnnounce());
        GameWriteTool.writeShort(buf, 0); //rights
        GameWriteTool.writeInt(buf, p.data.getConstruction());; //construct
        GameWriteTool.writeInt(buf, 0); //money
        GameWriteTool.writeInt(buf, 0); // createTime
        GameWriteTool.writeInt(buf, 0); //salary

        GameWriteTool.writeInt(buf, 0); //autoAcceptLevel
        GameWriteTool.writeString(buf, p.data.getCreator()); // creator
        GameWriteTool.writeShort(buf, 0); // skillCount

        GameWriteTool.writeShort(buf, 0); //population
        GameWriteTool.writeShort(buf, 0); //onLineCount
        GameWriteTool.writeShort(buf, p.data.getLevel());
        GameWriteTool.writeShort(buf, 0); //partyMap
        GameWriteTool.writeString(buf, ""); //heir
        GameWriteTool.writeInt(buf, 0); //lastAutoJoinTime

        GameWriteTool.writeString(buf, ""); // icon_md5
        GameWriteTool.writeString(buf, ""); //review_icon_md5

        GameWriteTool.writeShort(buf, p.officers.size()); //leaderCount
        p.officers.forEach((job, office)->{
            GameWriteTool.writeString(buf, job);
            GameWriteTool.writeString(buf,  office.name);
        });
    }

    public int cmd()
    {
        return 0xF0A1;
    }
}
