package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.vo.MSG_PICTURE_DIALOG_VO;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;
import org.springframework.stereotype.Component;

/**
 * 通知客户端显示图片对话框
 */
@Component
public class M_MSG_PICTURE_DIALOG extends BaseWrite {
    @Override
    protected void writeO(ByteBuf buf, Object obj) {
        MSG_PICTURE_DIALOG_VO picture_dialog_vo = (MSG_PICTURE_DIALOG_VO)obj;
        GameWriteTool.writeInt(buf, picture_dialog_vo.getId());
        GameWriteTool.writeString(buf, picture_dialog_vo.getNpcName());
        GameWriteTool.writeByte(buf, picture_dialog_vo.getPortrait());
        GameWriteTool.writeByte(buf, picture_dialog_vo.getPicId());
        GameWriteTool.writeString(buf, picture_dialog_vo.getContent());
    }

    @Override
    public int cmd() {
        return 0xF0D9;
    }

}
