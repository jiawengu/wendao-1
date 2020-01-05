package org.linlinjava.litemall.gameserver.data.write;


import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;


/**
 * MSG_OPEN_FEISHENG_DLG    打开通天塔飞升界面
 */
@org.springframework.stereotype.Service
public class MSG_OPEN_FEISHENG_DLG extends BaseWrite {

    protected void writeO(ByteBuf writeBuf, Object object) {
    }

    public int cmd() {
        return 45093;
    }

}