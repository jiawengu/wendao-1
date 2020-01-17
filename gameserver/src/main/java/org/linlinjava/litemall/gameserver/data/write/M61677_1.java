package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.UtilObjMapshuxing;
import org.linlinjava.litemall.gameserver.data.vo.Vo_12023_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_61677_1;
import org.linlinjava.litemall.gameserver.domain.BuildFields;
import org.linlinjava.litemall.gameserver.domain.PetShuXing;
import org.linlinjava.litemall.gameserver.domain.Petbeibao;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;

import java.util.Iterator;
import java.util.Map;

public class M61677_1  extends BaseWrite {

    @Override
    protected void writeO(ByteBuf writeBuf, Object paramObject) {
        Vo_61677_1 vo = (Vo_61677_1)paramObject;

        GameWriteTool.writeString(writeBuf, vo.store_type);
        GameWriteTool.writeInt(writeBuf, vo.npcID);
        GameWriteTool.writeShort(writeBuf, vo.list.size());

        for(Petbeibao petbeibao: vo.list){

            GameWriteTool.writeByte(writeBuf, vo.isGoon);
            GameWriteTool.writeShort(writeBuf, petbeibao.no);

            GameWriteTool.writeShort(writeBuf, petbeibao.petShuXing.size());
            for(PetShuXing petShuXing: petbeibao.petShuXing){
                GameWriteTool.writeByte(writeBuf, petShuXing.no);
                GameWriteTool.writeByte(writeBuf, petShuXing.type1);
                Map<Object, Object> petShuXingmap = UtilObjMapshuxing.PetShuXing(petShuXing);
                petShuXingmap.remove("no");
                petShuXingmap.remove("type1");

                for (Iterator<Map.Entry<Object, Object>> iter = petShuXingmap.entrySet().iterator(); iter.hasNext(); ) {
                    Map.Entry<Object, Object> entry = iter.next();
                    if ((!entry.getKey().equals("all_polar")) && (!entry.getKey().equals("upgrade_magic")) && (!entry.getKey().equals("upgrade_total"))) {
                        if ((entry.getValue().equals(Integer.valueOf(0))) && ((entry.getKey().equals("dex")) || (entry.getKey().equals("def")) || (entry.getKey().equals("mana")) || (entry.getKey().equals("parry")) || (entry.getKey().equals("accurate")) || (entry.getKey().equals("wiz")))) {
                            iter.remove();
                        }
                        if (entry.getValue().equals("")) {
                            iter.remove();
                        }
                    }
                }

                GameWriteTool.writeShort(writeBuf, petShuXingmap.size());
                for (Map.Entry<Object, Object> objectEntry : petShuXingmap.entrySet()) {
                    if (BuildFields.data.get((String)objectEntry.getKey()) != null) {
                        BuildFields.get((String)objectEntry.getKey()).write(writeBuf, objectEntry.getValue());
                    } else {
                        System.out.println(objectEntry.getKey());
                    }
                }

                GameWriteTool.writeShort(writeBuf, 0);
                GameWriteTool.writeShort(writeBuf, petbeibao.tianshu.size());
                for(Vo_12023_0 v: petbeibao.tianshu){
                    GameWriteTool.writeString(writeBuf, v.god_book_skill_name);
                    GameWriteTool.writeShort(writeBuf, v.god_book_skill_level);
                    GameWriteTool.writeShort(writeBuf, v.god_book_skill_power);
                    GameWriteTool.writeByte(writeBuf, v.god_book_skill_disabled);
                }
                GameWriteTool.writeShort(writeBuf, 0);
            }
        }

    }

    @Override
    public int cmd() {
        return 61677;
    }
}