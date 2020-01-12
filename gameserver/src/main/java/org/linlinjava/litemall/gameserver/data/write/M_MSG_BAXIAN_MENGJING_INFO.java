package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.vo.BAXIAN_MENGJING_INFO_VO;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;
import org.springframework.stereotype.Component;

@Component
public class M_MSG_BAXIAN_MENGJING_INFO extends BaseWrite {
    protected void writeO(ByteBuf writeBuf, Object object) {
        BAXIAN_MENGJING_INFO_VO baxian_mengjing_info_vo = (BAXIAN_MENGJING_INFO_VO) object;
        GameWriteTool.writeShort(writeBuf, baxian_mengjing_info_vo.getTimes_left());
        GameWriteTool.writeShort(writeBuf, baxian_mengjing_info_vo.getCurCheckpoint());
        GameWriteTool.writeShort(writeBuf, baxian_mengjing_info_vo.getOpenMax());
        GameWriteTool.writeByte(writeBuf, baxian_mengjing_info_vo.getMainState());
        GameWriteTool.writeByte(writeBuf, baxian_mengjing_info_vo.getIsOpenDlg());
    }

    public int cmd() {
        return 0x8023;
    }
}
