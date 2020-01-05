package org.linlinjava.litemall.gameserver.data.write;


import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_49155_0;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;


/**
 * MSG_TONGTIANTA_INFO
 */
@org.springframework.stereotype.Service
public class MSG_TONGTIANTA_INFO extends BaseWrite {

    protected void writeO(ByteBuf writeBuf, Object object) {
        Vo_49155_0 object1 = (Vo_49155_0) object;
        GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.curLayer));

        GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.breakLayer));

        GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.curType));

        GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.topLayer));

        GameWriteTool.writeString(writeBuf, object1.npc);

        GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.challengeCount));

        GameWriteTool.writeString(writeBuf, object1.bonusType);

        GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.hasNotCompletedSmfj));
    }

    public int cmd() {
        return 49155;
    }

}