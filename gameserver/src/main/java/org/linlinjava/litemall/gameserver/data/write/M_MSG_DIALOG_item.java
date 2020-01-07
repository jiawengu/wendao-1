package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_MSG_DIALOG_item;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;

public class M_MSG_DIALOG_item extends BaseWrite {
    private  String ask_type;
    public M_MSG_DIALOG_item(String ask_type){ this.ask_type = ask_type; }
    @Override
    protected void writeO(ByteBuf buf, Object obj) {
        Vo_MSG_DIALOG_item vo = (Vo_MSG_DIALOG_item)obj;
        GameWriteTool.writeInt(buf, vo.org_icon);
        GameWriteTool.writeShort(buf, vo.bf_list.size());
        vo.bf_list.forEach(bf->{
            new M_BuildField().writeO(buf, bf);
        });
        GameWriteTool.writeByte(buf, vo.teamMembersCount);
        GameWriteTool.writeByte(buf, vo.comeback_flag);
        if(this.ask_type.compareTo("csc_around_player") == 0 || this.ask_type.compareTo("csc_around_team") == 0){
            GameWriteTool.writeString(buf, vo.stageStr);
            GameWriteTool.writeString(buf, vo.combat_mode);
        }
    }

    @Override
    public int cmd() {
        return 0;
    }
}
