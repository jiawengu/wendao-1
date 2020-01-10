package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.db.domain.Npc;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.domain.CharaStatue;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;
import org.springframework.stereotype.Service;


/**
 * MSG_APPEAR
 */
@Service
public class MSG_APPEAR_NPC
        extends BaseWrite {
    protected void writeO(ByteBuf writeBuf, Object object) {
        Npc npc = (Npc) object;

        //人物雕像
        CharaStatue charaStatue = null;

        GameWriteTool.writeInt(writeBuf, npc.getId());

        GameWriteTool.writeShort(writeBuf, npc.getX());

        GameWriteTool.writeShort(writeBuf, npc.getY());

        GameWriteTool.writeShort(writeBuf, Integer.valueOf(7));//朝向

        GameWriteTool.writeInt(writeBuf, charaStatue==null?npc.getIcon():charaStatue.waiguan);

        GameWriteTool.writeInt(writeBuf, charaStatue==null?Integer.valueOf(0):charaStatue.weapon_icon);

        GameWriteTool.writeShort(writeBuf, Integer.valueOf(4));//类型

        GameWriteTool.writeInt(writeBuf, Integer.valueOf(0));

        GameWriteTool.writeInt(writeBuf, Integer.valueOf(0));

        GameWriteTool.writeInt(writeBuf, Integer.valueOf(0));

        GameWriteTool.writeString(writeBuf, charaStatue==null?npc.getName():charaStatue.name);

        GameWriteTool.writeShort(writeBuf, charaStatue==null?Integer.valueOf(0):charaStatue.level);

        GameWriteTool.writeString(writeBuf, "");

        GameWriteTool.writeString(writeBuf, "");

        GameWriteTool.writeString(writeBuf, charaStatue==null?"":charaStatue.partyName);

        GameWriteTool.writeInt(writeBuf, Integer.valueOf(0));

        GameWriteTool.writeInt(writeBuf, charaStatue==null?Integer.valueOf(0):charaStatue.special_icon);//special_icon

        GameWriteTool.writeInt(writeBuf, charaStatue==null?npc.getIcon():charaStatue.waiguan);

        GameWriteTool.writeInt(writeBuf, charaStatue==null?Integer.valueOf(0):charaStatue.suit_icon);//suit_icon

        GameWriteTool.writeInt(writeBuf, charaStatue==null?Integer.valueOf(0):charaStatue.suit_light_effect);//suit_light_effect

        GameWriteTool.writeInt(writeBuf, Integer.valueOf(0));//guard_icon

        GameWriteTool.writeInt(writeBuf, charaStatue==null?Integer.valueOf(0):charaStatue.zuoqiwaiguan);//pet_icon

        GameWriteTool.writeInt(writeBuf, Integer.valueOf(0));

        GameWriteTool.writeInt(writeBuf, Integer.valueOf(0));

        GameWriteTool.writeInt(writeBuf, charaStatue==null?Integer.valueOf(0):charaStatue.zuowaiguan);//mount_icon

        GameWriteTool.writeString(writeBuf, "");

        GameWriteTool.writeString(writeBuf, "");

        GameWriteTool.writeString(writeBuf, "");

        GameWriteTool.writeByte(writeBuf, Integer.valueOf(0));

        GameWriteTool.writeByte(writeBuf, Integer.valueOf(0));

        GameWriteTool.writeByte(writeBuf, Integer.valueOf(0));

        GameWriteTool.writeInt(writeBuf, Integer.valueOf(0));

        GameWriteTool.writeByte(writeBuf, Integer.valueOf(0));

        GameWriteTool.writeInt(writeBuf, Integer.valueOf(0));

        GameWriteTool.writeByte(writeBuf, Integer.valueOf(0));

        GameWriteTool.writeByte(writeBuf, Integer.valueOf(0));

        GameWriteTool.writeByte(writeBuf, Integer.valueOf(0));

        GameWriteTool.writeShort(writeBuf, Integer.valueOf(0));
    }

    public int cmd() {
        return 65529;
    }
}

