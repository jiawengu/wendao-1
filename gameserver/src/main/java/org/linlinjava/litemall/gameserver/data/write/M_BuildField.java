package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.vo.Vo_BuildField;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;

public class M_BuildField extends BaseWrite {
    @Override
    protected void writeO(ByteBuf buf, Object obj) {
        Vo_BuildField vo = (Vo_BuildField) obj;
        GameWriteTool.writeShort(buf, vo.field_no);
        buf.writeByte(vo.type);

        switch(vo.type){
            case Vo_BuildField.FIELD_INT8:
            case Vo_BuildField.FIELD_UINT8:
                GameWriteTool.writeByte(buf, vo.int_data);
                break;
            case Vo_BuildField.FIELD_INT16:
            case Vo_BuildField.FIELD_UINT16:
                GameWriteTool.writeShort(buf, vo.int_data);
                break;
            case Vo_BuildField.FIELD_INT32:
            case Vo_BuildField.FIELD_UINT32:
                GameWriteTool.writeInt(buf, vo.int_data);
                break;
            case Vo_BuildField.FIELD_STRING:
            case Vo_BuildField.FIELD_LONGSTRING:
                GameWriteTool.writeString(buf, vo.str_data);
                break;
            default:
                try {
                    throw new Exception("error type:" + vo.type);
                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;
        }
    }

    @Override
    public int cmd() {
        return 0;
    }
}
