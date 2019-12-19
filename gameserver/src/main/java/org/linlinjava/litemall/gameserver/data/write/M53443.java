package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;

public class M53443 extends org.linlinjava.litemall.gameserver.netty.BaseWrite{

        protected void writeO(ByteBuf writeBuf, Object object)
        {
            GameWriteTool.writeShort(writeBuf, 2);
            GameWriteTool.writeString(writeBuf, "这个是做装备");
            GameWriteTool.writeString(writeBuf, "我是在做装备");
        }
        public int cmd() { return 53443; }
}
