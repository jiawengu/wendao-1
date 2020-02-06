package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_MSG_RELEASE_SUCC;
import org.linlinjava.litemall.gameserver.data.vo.Vo_MSG_ZUOLAO_INFO;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;
import org.springframework.stereotype.Component;

@Component
public class M_MSG_RELEASE_SUCC extends BaseWrite {
    protected void writeO(ByteBuf buf, Object object)
    {
        Vo_MSG_RELEASE_SUCC vo = (Vo_MSG_RELEASE_SUCC) object;
        GameWriteTool.writeString(buf, vo.gid);
    }

    public int cmd()
    {
        return 0xB0B0;
    }
}
