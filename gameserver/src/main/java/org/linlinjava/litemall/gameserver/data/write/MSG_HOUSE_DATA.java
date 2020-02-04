package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.vo.HOUSE_DATA_VO;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;
import org.springframework.stereotype.Service;

@Service
public class MSG_HOUSE_DATA extends BaseWrite {

    @Override
    protected void writeO(ByteBuf paramByteBuf, Object paramObject) {
        HOUSE_DATA_VO houseDataVo = (HOUSE_DATA_VO) paramObject;
        GameWriteTool.writeString(paramByteBuf, houseDataVo.getHouseId());
        GameWriteTool.writeByte(paramByteBuf, houseDataVo.getHouseType());
        GameWriteTool.writeString(paramByteBuf, houseDataVo.getHousePrefix());
        GameWriteTool.writeShort(paramByteBuf, houseDataVo.getComfort());
        GameWriteTool.writeByte(paramByteBuf, houseDataVo.getCleanliness());
        GameWriteTool.writeByte(paramByteBuf, houseDataVo.getCleanliness());
        GameWriteTool.writeByte(paramByteBuf, houseDataVo.getStoreType());
    }

    @Override
    public int cmd() {
        return 20594;
    }
}

