package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.vo.MSG_PLAY_SCENARIOD_VO;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;
import org.springframework.stereotype.Service;

@Service
public class MSG_PLAY_SCENARIOD extends BaseWrite {
    protected void writeO(ByteBuf writeBuf, Object object) {
        MSG_PLAY_SCENARIOD_VO object1 = (MSG_PLAY_SCENARIOD_VO) object;
        GameWriteTool.writeInt(writeBuf, object1.id);
        GameWriteTool.writeString(writeBuf, object1.name);
        GameWriteTool.writeShort(writeBuf, object1.portrait);
        GameWriteTool.writeShort(writeBuf, object1.pic_no);
        GameWriteTool.writeString2(writeBuf, object1.content);
        GameWriteTool.writeShort(writeBuf, object1.isComplete);
        GameWriteTool.writeByte(writeBuf, object1.isInCombat);
        GameWriteTool.writeShort(writeBuf, object1.playTime);
        GameWriteTool.writeString(writeBuf, object1.task_type);
    }

    public int cmd() {
        return 0xB000;
    }
}
