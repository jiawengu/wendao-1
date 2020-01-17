package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_15855_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_41027_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_BuildField;


@org.springframework.stereotype.Service
public class MSG_C_UPDATE_COMBAT_INFO extends org.linlinjava.litemall.gameserver.netty.BaseWrite {
    private static M_BuildField m_buildField = new M_BuildField();

    protected void writeO(ByteBuf writeBuf, Object object) {
        Vo_41027_0 object1 = (Vo_41027_0) object;
        GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.id));
        GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.isSet));
        GameWriteTool.writeInt(writeBuf, 2);

        m_buildField.writeO(writeBuf, Vo_BuildField.int32(11, object1.mana));//mana
        m_buildField.writeO(writeBuf, Vo_BuildField.int32(12, object1.max_mana));//max_mana
    }

    public int cmd() {
        return 41027;
    }
}
