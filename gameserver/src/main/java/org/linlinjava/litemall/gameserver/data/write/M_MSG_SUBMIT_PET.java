package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_MSG_REQUEST_LIST;
import org.linlinjava.litemall.gameserver.data.vo.Vo_MSG_SUBMIT_PET;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;
import org.springframework.stereotype.Service;

@Service
public class M_MSG_SUBMIT_PET extends BaseWrite {

    @Override
    protected void writeO(ByteBuf buf, Object obj) {
        Vo_MSG_SUBMIT_PET vo = (Vo_MSG_SUBMIT_PET)obj;
        GameWriteTool.writeShort(buf, Integer.valueOf( vo.type));
        GameWriteTool.writeShort(buf, Integer.valueOf(vo.petCount));
        vo.petNameList.forEach(item->{
            GameWriteTool.writeString(buf, item);
        });
        GameWriteTool.writeLong(buf, Long.valueOf(vo.petState));
    }

    @Override
    public int cmd() {
        return 0xB018;
    }
}
