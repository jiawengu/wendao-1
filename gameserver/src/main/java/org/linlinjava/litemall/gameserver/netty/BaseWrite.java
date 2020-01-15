package org.linlinjava.litemall.gameserver.netty;

import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import org.linlinjava.litemall.gameserver.GameHandler;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.write.MSG_REPLY_ECHO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.util.List;

public abstract class BaseWrite {
    Logger log = LoggerFactory.getLogger(BaseWrite.class);

    private int beforeWrite(ByteBuf writeBuf) {
        GameWriteTool.writeShort(writeBuf, Integer.valueOf(19802));
        GameWriteTool.writeShort(writeBuf, Integer.valueOf(0));
        GameWriteTool.writeInt(writeBuf, Integer.valueOf((int) System.currentTimeMillis() / 1000));
        int writerIndex = writeBuf.writerIndex();
        GameWriteTool.writeShort(writeBuf, Integer.valueOf(0));
        GameWriteTool.writeShort(writeBuf, Integer.valueOf(cmd()));
        return writerIndex;
    }

    private void afterWrite(ByteBuf writeBuf, int writerIndex) {
        int len = writeBuf.writerIndex() - writerIndex - 2;
        writeBuf.markWriterIndex();
        writeBuf.writerIndex(writerIndex).writeShort(len);
        writeBuf.resetWriterIndex();
    }

    public String getName(String name){
        return name.substring(name.lastIndexOf("."));
    }

    public ByteBuf write(Object object) {
        StringBuffer cn = new StringBuffer();
        StackTraceElement[] ns = new Throwable().getStackTrace();
        cn.append(getName(ns[4].getClassName()));
        cn.append(getName(ns[3].getClassName()));
        cn.append(getName(ns[2].getClassName()));
        cn.append(getName(ns[1].getClassName()));
        cn.append(getName(this.getClass().getName()));

        if(! (this instanceof MSG_REPLY_ECHO)){
            System.out.println(String.format("发送消息[%s]：%s", cn.toString(), org.linlinjava.litemall.core.util.JSONUtils.toJSONString(object)));
        }
        int writerIndex = 0;
        ByteBuf writeBuf = Unpooled.buffer();
        writerIndex = beforeWrite(writeBuf);
        writeO(writeBuf, object);
        afterWrite(writeBuf, writerIndex);
        return writeBuf;
    }

    protected abstract void writeO(ByteBuf paramByteBuf, Object paramObject);

    public abstract int cmd();
}

/*
 * Location:
 * C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\
 * gameserver\netty\BaseWrite.class Java compiler version: 8 (52.0) JD-Core
 * Version: 0.7.1
 */