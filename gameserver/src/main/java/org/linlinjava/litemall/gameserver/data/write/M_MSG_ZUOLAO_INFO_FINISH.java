package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_MSG_ZUOLAO_INFO;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;
import org.springframework.stereotype.Component;

@Component
public class M_MSG_ZUOLAO_INFO_FINISH extends BaseWrite {
    protected void writeO(ByteBuf buf, Object object)
    {

    }

    public int cmd()
    {
        return 0xB0B1;
    }
}
