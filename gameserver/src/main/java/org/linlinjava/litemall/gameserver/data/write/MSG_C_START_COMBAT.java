//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_3583_0;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;
import org.springframework.stereotype.Service;
//MSG_C_START_COMBAT    开始战斗
@Service
public class MSG_C_START_COMBAT extends BaseWrite {
    public MSG_C_START_COMBAT() {
    }

    protected void writeO(ByteBuf writeBuf, Object object) {
        Vo_3583_0 object1 = (Vo_3583_0)object;
        GameWriteTool.writeShort(writeBuf, object1.a);//flag
        GameWriteTool.writeByte(writeBuf, ((Vo_3583_0)object).b);//mode
    }

    public int cmd() {
        return 3583;
    }
}
