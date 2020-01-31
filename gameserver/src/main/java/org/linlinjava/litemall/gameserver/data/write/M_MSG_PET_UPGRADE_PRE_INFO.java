package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.vo.VO_MSG_PET_UPGRADE_PRE_INFO;
import org.linlinjava.litemall.gameserver.domain.BuildFields;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;

import java.util.HashMap;
import java.util.Map;

public class M_MSG_PET_UPGRADE_PRE_INFO extends BaseWrite {

    @Override
    protected void writeO(ByteBuf writeBuf, Object paramObject) {
        VO_MSG_PET_UPGRADE_PRE_INFO vo = (VO_MSG_PET_UPGRADE_PRE_INFO) paramObject;
        GameWriteTool.writeLong(writeBuf, vo.id);
        Map<Object, Object> map = new HashMap();
        map.put("pet_life_shape", vo.pet_life_shape);
        map.put("pet_mag_shape", vo.pet_mag_shape);
        map.put("pet_mana_shape", vo.pet_mana_shape);
        map.put("pet_phy_shape", vo.pet_phy_shape);
        map.put("pet_speed_shape", vo.pet_speed_shape);

        GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
        for (Map.Entry<Object, Object> objectEntry : map.entrySet()) {
            if (BuildFields.data.get((String)objectEntry.getKey()) != null) {
                BuildFields.get((String)objectEntry.getKey()).write(writeBuf, objectEntry.getValue());
            } else {
                System.out.println(objectEntry.getKey());
            }
        }
    }

    @Override
    public int cmd() {
        return 0xB0FC;
    }
}
