package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.db.domain.Party;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_57523_0;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;

public class M57523_0 extends BaseWrite {
    protected void writeO(ByteBuf buf, Object object)
    {
        Vo_57523_0 vo = (Vo_57523_0)object;
        GameWriteTool.writeShort(buf, vo.parts.size());
        for(int i = 0; i < vo.parts.size(); i ++){
            Party p = vo.parts.get(i);
            GameWriteTool.writeString(buf, String.valueOf(p.getId()));
            GameWriteTool.writeString(buf, p.getName());
            GameWriteTool.writeString(buf, ""); //baseInfo
            GameWriteTool.writeString2(buf, p.getAnnounce());
            GameWriteTool.writeShort(buf, 0); //rights
            GameWriteTool.writeLong(buf, Long.valueOf(p.getConstruction())); //construct
            GameWriteTool.writeLong(buf, 0L); //money
            GameWriteTool.writeLong(buf, 0L); // createTime
            GameWriteTool.writeLong(buf, 0L); //salary

            GameWriteTool.writeLong(buf, 0L); //autoAcceptLevel
            GameWriteTool.writeString(buf, "xx"); // creator
            GameWriteTool.writeShort(buf, 0); // skillCount

            GameWriteTool.writeShort(buf, 0); //population
            GameWriteTool.writeShort(buf, 0); //onLineCount
            GameWriteTool.writeShort(buf, p.getLevel());
            GameWriteTool.writeShort(buf, 0); //partyMap
            GameWriteTool.writeString(buf, ""); //heir
            GameWriteTool.writeLong(buf, 0L); //lastAutoJoinTime

            GameWriteTool.writeString(buf, ""); // icon_md5
            GameWriteTool.writeString(buf, ""); //review_icon_md5
            GameWriteTool.writeShort(buf, 0); //leaderCount
        }
    }
    public int cmd()
    {
        return 32780;
    }
}
