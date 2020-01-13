package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.vo.BAXIAN_LEFT_TIME_VO;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;
import org.springframework.stereotype.Service;

@Service
public class M_MSG_BAXIAN_LEFT_TIMES extends BaseWrite {
    protected void writeO(ByteBuf writeBuf, Object object) {
        BAXIAN_LEFT_TIME_VO object1 = (BAXIAN_LEFT_TIME_VO) object;
        GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.left_time));
    }

    public int cmd() {
        return 0x6001;
    }
}
