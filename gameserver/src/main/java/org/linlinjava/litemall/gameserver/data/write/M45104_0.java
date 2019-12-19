//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.data.write;

import io.netty.buffer.ByteBuf;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.data.UtilObjMapshuxing;
import org.linlinjava.litemall.gameserver.data.vo.Vo_45104_0;
import org.linlinjava.litemall.gameserver.domain.BuildFields;
import org.linlinjava.litemall.gameserver.domain.Goods;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;
import org.springframework.stereotype.Service;

@Service
public class M45104_0 extends BaseWrite {
    public M45104_0() {
    }

    protected void writeO(ByteBuf writeBuf, Object object) {
        Vo_45104_0 object1 = (Vo_45104_0)object;
        GameWriteTool.writeString(writeBuf, object1.id);
        GameWriteTool.writeByte(writeBuf, object1.status);
        GameWriteTool.writeInt(writeBuf, object1.endTime);
        Goods goods = object1.goods;
        GameWriteTool.writeShort(writeBuf, 10);
        new HashMap();
        Map map;
        Iterator it;
        Entry entry;
        Iterator var9;
        if (goods.goodsInfo != null) {
            map = UtilObjMapshuxing.GoodsInfo(goods.goodsInfo);
            map.remove("groupNo");
            map.remove("groupType");
            GameWriteTool.writeByte(writeBuf, goods.goodsInfo.groupNo);
            GameWriteTool.writeByte(writeBuf, goods.goodsInfo.groupType);
            it = map.entrySet().iterator();

            while(it.hasNext()) {
                entry = (Entry)it.next();
                if (entry.getValue().equals(0) && entry.getKey().equals("silver_coin")) {
                    it.remove();
                }
            }

            GameWriteTool.writeShort(writeBuf, map.size());
            var9 = map.entrySet().iterator();

            while(var9.hasNext()) {
                entry = (Entry)var9.next();
                if (BuildFields.data.get((String)entry.getKey()) != null) {
                    BuildFields.get((String)entry.getKey()).write(writeBuf, entry.getValue());
                } else {
                    System.out.println(entry.getKey());
                }
            }
        }

        if (goods.goodsBasics != null) {
            map = UtilObjMapshuxing.GoodsBasics(goods.goodsBasics);
            map.remove("groupNo");
            map.remove("groupType");
            GameWriteTool.writeByte(writeBuf, goods.goodsBasics.groupNo);
            GameWriteTool.writeByte(writeBuf, goods.goodsBasics.groupType);
            it = map.entrySet().iterator();

            while(it.hasNext()) {
                entry = (Entry)it.next();
                if (entry.getValue().equals(0)) {
                    it.remove();
                }
            }

            GameWriteTool.writeShort(writeBuf, map.size());
            var9 = map.entrySet().iterator();

            while(var9.hasNext()) {
                entry = (Entry)var9.next();
                if (BuildFields.data.get((String)entry.getKey()) != null) {
                    BuildFields.get((String)entry.getKey()).write(writeBuf, entry.getValue());
                } else {
                    System.out.println(entry.getKey());
                }
            }
        }

        if (goods.goodsLanSe != null) {
            map = UtilObjMapshuxing.GoodsLanSe(goods.goodsLanSe);
            map.remove("groupNo");
            map.remove("groupType");
            GameWriteTool.writeByte(writeBuf, goods.goodsLanSe.groupNo);
            GameWriteTool.writeByte(writeBuf, goods.goodsLanSe.groupType);
            it = map.entrySet().iterator();

            while(it.hasNext()) {
                entry = (Entry)it.next();
                if (entry.getValue().equals(0)) {
                    it.remove();
                }
            }

            GameWriteTool.writeShort(writeBuf, map.size());
            var9 = map.entrySet().iterator();

            while(var9.hasNext()) {
                entry = (Entry)var9.next();
                if (BuildFields.data.get((String)entry.getKey()) != null) {
                    BuildFields.get((String)entry.getKey()).write(writeBuf, entry.getValue());
                } else {
                    System.out.println(entry.getKey());
                }
            }
        }

        if (goods.goodsFenSe != null) {
            map = UtilObjMapshuxing.GoodsFenSe(goods.goodsFenSe);
            map.remove("groupNo");
            map.remove("groupType");
            GameWriteTool.writeByte(writeBuf, goods.goodsFenSe.groupNo);
            GameWriteTool.writeByte(writeBuf, goods.goodsFenSe.groupType);
            it = map.entrySet().iterator();

            while(it.hasNext()) {
                entry = (Entry)it.next();
                if (entry.getValue().equals(0)) {
                    it.remove();
                }
            }

            GameWriteTool.writeShort(writeBuf, map.size());
            var9 = map.entrySet().iterator();

            while(var9.hasNext()) {
                entry = (Entry)var9.next();
                if (BuildFields.data.get((String)entry.getKey()) != null) {
                    BuildFields.get((String)entry.getKey()).write(writeBuf, entry.getValue());
                } else {
                    System.out.println(entry.getKey());
                }
            }
        }

        if (goods.goodsHuangSe != null) {
            map = UtilObjMapshuxing.GoodsHuangSe(goods.goodsHuangSe);
            map.remove("groupNo");
            map.remove("groupType");
            GameWriteTool.writeByte(writeBuf, goods.goodsHuangSe.groupNo);
            GameWriteTool.writeByte(writeBuf, goods.goodsHuangSe.groupType);
            it = map.entrySet().iterator();

            while(it.hasNext()) {
                entry = (Entry)it.next();
                if (entry.getValue().equals(0)) {
                    it.remove();
                }
            }

            GameWriteTool.writeShort(writeBuf, map.size());
            var9 = map.entrySet().iterator();

            while(var9.hasNext()) {
                entry = (Entry)var9.next();
                if (BuildFields.data.get((String)entry.getKey()) != null) {
                    BuildFields.get((String)entry.getKey()).write(writeBuf, entry.getValue());
                } else {
                    System.out.println(entry.getKey());
                }
            }
        }

        if (goods.goodsLvSe != null) {
            map = UtilObjMapshuxing.GoodsLvSe(goods.goodsLvSe);
            map.remove("groupNo");
            map.remove("groupType");
            GameWriteTool.writeByte(writeBuf, goods.goodsLvSe.groupNo);
            GameWriteTool.writeByte(writeBuf, goods.goodsLvSe.groupType);
            it = map.entrySet().iterator();

            while(it.hasNext()) {
                entry = (Entry)it.next();
                if (entry.getValue().equals(0)) {
                    it.remove();
                }
            }

            GameWriteTool.writeShort(writeBuf, map.size());
            var9 = map.entrySet().iterator();

            while(var9.hasNext()) {
                entry = (Entry)var9.next();
                if (BuildFields.data.get((String)entry.getKey()) != null) {
                    BuildFields.get((String)entry.getKey()).write(writeBuf, entry.getValue());
                } else {
                    System.out.println(entry.getKey());
                }
            }
        }

        if (goods.goodsGaiZao != null) {
            map = UtilObjMapshuxing.GoodsGaiZao(goods.goodsGaiZao);
            map.remove("groupNo");
            map.remove("groupType");
            GameWriteTool.writeByte(writeBuf, goods.goodsGaiZao.groupNo);
            GameWriteTool.writeByte(writeBuf, goods.goodsGaiZao.groupType);
            it = map.entrySet().iterator();

            while(it.hasNext()) {
                entry = (Entry)it.next();
                if (entry.getValue().equals(0)) {
                    it.remove();
                }
            }

            GameWriteTool.writeShort(writeBuf, map.size());
            var9 = map.entrySet().iterator();

            while(var9.hasNext()) {
                entry = (Entry)var9.next();
                if (BuildFields.data.get((String)entry.getKey()) != null) {
                    BuildFields.get((String)entry.getKey()).write(writeBuf, entry.getValue());
                } else {
                    System.out.println(entry.getKey());
                }
            }
        }

        if (goods.goodsGaiZaoGongMing != null) {
            map = UtilObjMapshuxing.GoodsGaiZaoGongMing(goods.goodsGaiZaoGongMing);
            map.remove("groupNo");
            map.remove("groupType");
            GameWriteTool.writeByte(writeBuf, goods.goodsGaiZaoGongMing.groupNo);
            GameWriteTool.writeByte(writeBuf, goods.goodsGaiZaoGongMing.groupType);
            it = map.entrySet().iterator();

            while(it.hasNext()) {
                entry = (Entry)it.next();
                if (entry.getValue().equals(0)) {
                    it.remove();
                }
            }

            GameWriteTool.writeShort(writeBuf, map.size());
            var9 = map.entrySet().iterator();

            while(var9.hasNext()) {
                entry = (Entry)var9.next();
                if (BuildFields.data.get((String)entry.getKey()) != null) {
                    BuildFields.get((String)entry.getKey()).write(writeBuf, entry.getValue());
                } else {
                    System.out.println(entry.getKey());
                }
            }
        }

        if (goods.goodsGaiZaoGongMingChengGong != null) {
            map = UtilObjMapshuxing.GoodsGaiZaoGongMingChengGong(goods.goodsGaiZaoGongMingChengGong);
            map.remove("groupNo");
            map.remove("groupType");
            GameWriteTool.writeByte(writeBuf, goods.goodsGaiZaoGongMingChengGong.groupNo);
            GameWriteTool.writeByte(writeBuf, goods.goodsGaiZaoGongMingChengGong.groupType);
            it = map.entrySet().iterator();

            while(it.hasNext()) {
                entry = (Entry)it.next();
                if (entry.getValue().equals(0)) {
                    it.remove();
                }
            }

            GameWriteTool.writeShort(writeBuf, map.size());
            var9 = map.entrySet().iterator();

            while(var9.hasNext()) {
                entry = (Entry)var9.next();
                if (BuildFields.data.get((String)entry.getKey()) != null) {
                    BuildFields.get((String)entry.getKey()).write(writeBuf, entry.getValue());
                } else {
                    System.out.println(entry.getKey());
                }
            }
        }

        if (goods.goodsLvSeGongMing != null) {
            map = UtilObjMapshuxing.GoodsLvSeGongMing(goods.goodsLvSeGongMing);
            map.remove("groupNo");
            map.remove("groupType");
            GameWriteTool.writeByte(writeBuf, goods.goodsLvSeGongMing.groupNo);
            GameWriteTool.writeByte(writeBuf, goods.goodsLvSeGongMing.groupType);
            it = map.entrySet().iterator();

            while(it.hasNext()) {
                entry = (Entry)it.next();
                if (entry.getValue().equals(0)) {
                    it.remove();
                }
            }

            GameWriteTool.writeShort(writeBuf, map.size());
            var9 = map.entrySet().iterator();

            while(var9.hasNext()) {
                entry = (Entry)var9.next();
                if (BuildFields.data.get((String)entry.getKey()) != null) {
                    BuildFields.get((String)entry.getKey()).write(writeBuf, entry.getValue());
                } else {
                    System.out.println(entry.getKey());
                }
            }
        }

    }

    public int cmd() {
        return 45104;
    }
}
