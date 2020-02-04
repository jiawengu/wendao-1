package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_20576_0;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;

import java.util.Map;

public class M20576_0 extends BaseWrite{

    @Override
    protected void writeO(ByteBuf paramByteBuf, Object paramObject) {
        Vo_20576_0 vo_20576_0 = (Vo_20576_0) paramObject;
        GameWriteTool.writeString(paramByteBuf, vo_20576_0.getAction());
        GameWriteTool.writeString(paramByteBuf, vo_20576_0.getLastHouse());
        GameWriteTool.writeString(paramByteBuf, vo_20576_0.getCurHouse());
        GameWriteTool.writeInt(paramByteBuf, vo_20576_0.getPrice());
        if(vo_20576_0.getSelects() != null){
            for (Map.Entry<String, Integer> entry : vo_20576_0.getSelects().entrySet()) {
                GameWriteTool.writeByte(paramByteBuf, entry.getValue());
            }
        }

    }

    @Override
    public int cmd() {
        return 20576;
    }
}

