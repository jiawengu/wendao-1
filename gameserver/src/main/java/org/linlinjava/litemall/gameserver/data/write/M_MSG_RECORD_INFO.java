package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.vo.Vo_MSG_PK_RECORD;
import org.linlinjava.litemall.gameserver.data.vo.Vo_MSG_RECORD_INFO;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;
import org.springframework.stereotype.Component;

@Component
public class M_MSG_RECORD_INFO extends BaseWrite {
    protected void writeO(ByteBuf buf, Object object)
    {
        Vo_MSG_RECORD_INFO vo = (Vo_MSG_RECORD_INFO) object;

    }

    public int cmd()
    {
        return 0xB0A9;
    }
}
