package org.linlinjava.litemall.gameserver.data.write;


import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_49157_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_49177_0;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;


/**
 * MSG_TONGTIANTA_BONUS_DLG 通天塔突破修练奖励界面
 */
@org.springframework.stereotype.Service
public class M49157_0 extends BaseWrite {

    protected void writeO(ByteBuf writeBuf, Object object) {
        Vo_49157_0 object1 = (Vo_49157_0) object;
        GameWriteTool.writeString(writeBuf, object1.bonusType);

        GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.dlgType));

        GameWriteTool.writeLong(writeBuf, Long.valueOf(object1.bonusValue));

        GameWriteTool.writeLong(writeBuf, Long.valueOf(object1.bonusTaoPoint));
    }

    public int cmd() {
        return 49157;
    }

}