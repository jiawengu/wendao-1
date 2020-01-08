package org.linlinjava.litemall.gameserver.process;

import org.linlinjava.litemall.gameserver.*;
import org.springframework.stereotype.*;
import io.netty.channel.*;
import io.netty.buffer.*;
import org.linlinjava.litemall.gameserver.game.*;
import org.linlinjava.litemall.gameserver.data.*;
import org.linlinjava.litemall.db.util.*;
import org.linlinjava.litemall.gameserver.data.game.*;
import org.linlinjava.litemall.gameserver.data.write.*;
import org.apache.commons.collections.*;
import java.util.*;
import java.util.Map;

import org.linlinjava.litemall.gameserver.data.vo.*;
import org.linlinjava.litemall.gameserver.domain.*;
import org.linlinjava.litemall.db.domain.*;

@Service
public class C32776_0 implements GameHandler
{
    @Override
    public void process(final ChannelHandlerContext ctx, final ByteBuf buff) {
        int pos = GameReadTool.readShort(buff);
        final int type = GameReadTool.readByte(buff);
        final String para = GameReadTool.readString(buff);
        final Chara chara = GameObjectChar.getGameObjectChar().chara;
        if (pos < 0) {
            pos = 129 + pos + 127;
        }
        if (13 == type) {
            for (int i = 0; i < chara.backpack.size(); ++i) {
                final Goods goods = chara.backpack.get(i);
                if (goods.pos == pos) {
                    final int attrib = goods.goodsInfo.attrib + 10;
                    String current = "";
                    List<ZhuangbeiInfo> infoList = (List<ZhuangbeiInfo>)GameData.that.baseZhuangbeiInfoService.findByAttrib(Integer.valueOf(attrib));
                    for (int j = 0; j < infoList.size(); ++j) {
                        if (infoList.get(j).getAmount() == goods.goodsInfo.amount) {
                            current = infoList.get(j).getStr();
                        }
                    }
                    final Hashtable hashMap = new Hashtable();
                    final Map<Object, Object> goodsLanSe = UtilObjMapshuxing.GoodsLanSe(goods.goodsLanSe);
                    for (final Map.Entry<Object, Object> entry : goodsLanSe.entrySet()) {
                        if (!entry.getKey().equals("groupNo")) {
                            if (entry.getKey().equals("groupType")) {
                                continue;
                            }
                            if (0 == (int)entry.getValue()) {
                                continue;
                            }
                            hashMap.put(entry.getKey(), entry.getValue());
                        }
                    }
                    final List<Hashtable<String, Integer>> hashtables = ForgingEquipmentUtils.appraisalALLEquipment(goods.goodsInfo.amount, goods.goodsInfo.attrib, hashMap);
                    if (hashtables.size() > 0) {
                        final ZhuangbeiInfo zhuangbeiInfo = GameData.that.baseZhuangbeiInfoService.findOneByStr(current);
                        for (final Hashtable<String, Integer> maps : hashtables) {
                            if (maps.get("groupNo") == 2) {
                                maps.put("groupType", 2);
                                final GoodsLanSe gooodsLanSe = (GoodsLanSe)JSONUtils.parseObject(JSONUtils.toJSONString((Object)maps), (Class)GoodsLanSe.class);
                                GameUtil.huodezhuangbei(chara, zhuangbeiInfo, 0, 1, gooodsLanSe);
                            }
                        }
                        GameUtil.removemunber(chara, goods, 1);
                        final Vo_40964_0 vo_40964_0 = new Vo_40964_0();
                        vo_40964_0.type = 1;
                        vo_40964_0.name = zhuangbeiInfo.getStr();
                        vo_40964_0.param = "20691134";
                        vo_40964_0.rightNow = 0;
                        GameObjectChar.send(new M40964_0(), vo_40964_0);
                        final Vo_9129_0 vo_9129_0 = new Vo_9129_0();
                        vo_9129_0.notify = 10000;
                        vo_9129_0.para = "20691134";
                        GameObjectChar.send(new M9129_0(), vo_9129_0);
                        final Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                        vo_20481_0.msg = "你成功合成了1个#R" + zhuangbeiInfo.getStr() + "#n。";
                        vo_20481_0.time = 1562987118;
                        GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                    }
                    else {
                        final Vo_20481_0 vo_20481_2 = new Vo_20481_0();
                        vo_20481_2.msg = "合成失败!";
                        vo_20481_2.time = 1562987118;
                        GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_2);
                    }
                    final int coin = ConsumeMoneyUtils.appraisalMoney(attrib);
                    if(chara.balance<coin) {return;}
                    chara.balance -= coin;
                    final ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
                    GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
                    if (goods.goodsInfo.attrib >= 100) {
                        infoList = (List<ZhuangbeiInfo>)GameData.that.baseZhuangbeiInfoService.findByAttrib(Integer.valueOf(70));
                        for (int k = 0; k < infoList.size(); ++k) {
                            if (infoList.get(k).getAmount() == goods.goodsInfo.amount) {
                                current = infoList.get(k).getStr();
                            }
                        }
                        GameUtil.removemunber(chara, current, 2);
                    }
                    else {
                        GameUtil.removemunber(chara, "超级女娲石", 2);
                    }
                }
            }
        }
        if (6 == type) {
            final String[] split = para.split("\\_");
            final String pos2 = split[0];
            final int pos3 = Integer.parseInt(split[1]);
            final int pos4 = Integer.parseInt(split[2]);
            int ClassCurrent = 0;
            final int count = 0;
            String current2 = "";
            final ZhuangbeiInfo zhuangbeiInfo2 = GameData.that.baseZhuangbeiInfoService.findOneByStr(pos2);
            if (zhuangbeiInfo2.getAttrib() <= 50) {
                ClassCurrent = zhuangbeiInfo2.getAttrib() - 15;
            }
            else {
                ClassCurrent = zhuangbeiInfo2.getAttrib() - 10;
            }
            final List<ZhuangbeiInfo> infoList2 = (List<ZhuangbeiInfo>)GameData.that.baseZhuangbeiInfoService.findByAttrib(Integer.valueOf(ClassCurrent));
            for (int l = 0; l < infoList2.size(); ++l) {
                if (infoList2.get(l).getAmount() == zhuangbeiInfo2.getAmount()) {
                    current2 = infoList2.get(l).getStr();
                }
            }
            if (pos4 == 1) {
                int currentcount = 0;
                for (int m = 0; m < chara.backpack.size(); ++m) {
                    final Goods goods2 = chara.backpack.get(m);
                    if (current2.equals(goods2.goodsInfo.str)) {
                        currentcount += goods2.goodsInfo.owner_id;
                    }
                }
                final int owner_id = currentcount / 3;
                GameUtil.removemunber(chara, current2, owner_id * 3);
                GameUtil.huodezhuangbei(chara, zhuangbeiInfo2, 0, owner_id);
                final Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                vo_20481_0.msg = "你成功合成了1个#R" + pos2 + "#n。";
                vo_20481_0.time = 1562987118;
                for (int i2 = 0; i2 < owner_id; ++i2) {
                    GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                }
                final int coin2 = ConsumeMoneyUtils.appraisalMoney(zhuangbeiInfo2.getAttrib());
                if(chara.balance<coin2 * owner_id) {return;}
                chara.balance -= coin2 * owner_id;
                final ListVo_65527_0 listVo_65527_2 = GameUtil.a65527(chara);
                GameObjectChar.send(new MSG_UPDATE(), listVo_65527_2);
            }
            else {
                if (zhuangbeiInfo2.getAttrib() <= 70) {
                    GameUtil.removemunber(chara, current2, 3);
                    GameUtil.huodezhuangbei(chara, zhuangbeiInfo2, 0, 1);
                }
                else {
                    final List<Hashtable<String, Integer>> hashtables2 = ForgingEquipmentUtils.appraisalALLEquipment(zhuangbeiInfo2.getAmount(), zhuangbeiInfo2.getAttrib(), null);
                    GameUtil.removemunber(chara, current2, 1);
                    GameUtil.removemunber(chara, "超级女娲石", 2);
                    if (hashtables2.size() >= 0) {
                        for (final Hashtable<String, Integer> maps2 : hashtables2) {
                            if (maps2.get("groupNo") == 2) {
                                maps2.put("groupType", 2);
                                final GoodsLanSe gooodsLanSe2 = (GoodsLanSe)JSONUtils.parseObject(JSONUtils.toJSONString((Object)maps2), (Class)GoodsLanSe.class);
                                GameUtil.huodezhuangbei(chara, zhuangbeiInfo2, 0, 1, gooodsLanSe2);
                            }
                        }
                    }
                }
                final Vo_20481_0 vo_20481_3 = new Vo_20481_0();
                vo_20481_3.msg = "你成功合成了1个#R" + pos2 + "#n。";
                vo_20481_3.time = 1562987118;
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_3);
                final int coin3 = ConsumeMoneyUtils.appraisalMoney(zhuangbeiInfo2.getAttrib());
                if(chara.balance<coin3) {return;}
                chara.balance -= coin3;
                final ListVo_65527_0 listVo_65527_3 = GameUtil.a65527(chara);
                GameObjectChar.send(new MSG_UPDATE(), listVo_65527_3);
            }
            final Vo_9129_0 vo_9129_2 = new Vo_9129_0();
            vo_9129_2.notify = 10000;
            vo_9129_2.para = "20643387";
            GameObjectChar.send(new M9129_0(), vo_9129_2);
        }
        if (24 == type) {
            for (int i = 0; i < chara.backpack.size(); ++i) {
                final String[] split2 = para.split("\\|");
                final int pos5 = Integer.parseInt(split2[0]);
                final int pos6 = Integer.parseInt(split2[1]);
                final Goods goods3 = chara.backpack.get(i);
                boolean has = true;
                if (pos == goods3.pos) {
                    final Map<Object, Object> goodsGaiZaoGongMing = UtilObjMapshuxing.GoodsGaiZaoGongMing(goods3.goodsGaiZaoGongMing);
                    for (final Map.Entry<Object, Object> entry : goodsGaiZaoGongMing.entrySet()) {
                        if (!entry.getKey().equals("groupNo")) {
                            if (entry.getKey().equals("groupType")) {
                                continue;
                            }
                            if ((int)entry.getValue() == 0) {
                                continue;
                            }
                            has = false;
                        }
                    }
                    final List<Hashtable<String, Integer>> hashtables = ForgingEquipmentUtils.resonanceEquipMent(goods3.goodsInfo.attrib, goods3.goodsInfo.color, pos5, has);
                    if (hashtables.size() > 0) {
                        for (final Hashtable<String, Integer> maps3 : hashtables) {
                            if (maps3.get("groupNo") == 27) {
                                maps3.put("groupType", 2);
                                final GoodsGaiZaoGongMing goodsLvSeGongMing = (GoodsGaiZaoGongMing)JSONUtils.parseObject(JSONUtils.toJSONString((Object)maps3), (Class)GoodsGaiZaoGongMing.class);
                                goods3.goodsGaiZaoGongMing = goodsLvSeGongMing;
                            }
                        }
                        final List<Goods> list = new ArrayList<Goods>();
                        list.add(goods3);
                        GameObjectChar.send(new MSG_INVENTORY(), list);
                        final Vo_41191_0 vo_41191_0 = new Vo_41191_0();
                        vo_41191_0.flag = 1;
                        vo_41191_0.opType = "";
                        GameObjectChar.send(new M41191_0(), vo_41191_0);
                        final Vo_20481_0 vo_20481_4 = new Vo_20481_0();
                        vo_20481_4.msg = "恭喜你，炼化成功!";
                        vo_20481_4.time = 1562987118;
                        GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_4);
                    }
                    else {
                        final Vo_41191_0 vo_41191_2 = new Vo_41191_0();
                        vo_41191_2.flag = 0;
                        vo_41191_2.opType = "";
                        GameObjectChar.send(new M41191_0(), vo_41191_2);
                        final Vo_20481_0 vo_20481_3 = new Vo_20481_0();
                        vo_20481_3.msg = "炼化失败，请继续努力";
                        vo_20481_3.time = 1562987118;
                        GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_3);
                    }
                    final int coin = ConsumeMoneyUtils.remakeMoney(goods3.goodsInfo.attrib);
                    if(chara.balance<coin) {return;}
                    chara.balance -= coin;
                    final ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
                    GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
                    GameUtil.removemunber(chara, "装备共鸣石", pos5);
                }
            }
        }
        if (5 == type) {
            final String[] split = para.split("\\|");
            final int pos7 = Integer.parseInt(split[0]);
            final int pos3 = Integer.parseInt(split[1]);
            final int pos4 = Integer.parseInt(split[2]);
            for (int i3 = 0; i3 < chara.backpack.size(); ++i3) {
                final Goods goods4 = chara.backpack.get(i3);
                if (pos == goods4.pos) {
                    goods4.goodsInfo.suit_enabled = pos3;
                    final List<Hashtable<String, Integer>> hashtables3 = ForgingEquipmentUtils.appraisalGreenEquipment(goods4.goodsInfo.amount, goods4.goodsInfo.attrib, pos3);
                    for (final Hashtable<String, Integer> maps4 : hashtables3) {
                        if (maps4.get("groupNo") == 12) {
                            maps4.put("groupType", 2);
                            GoodsLvSe goodsLvSe = (GoodsLvSe)JSONUtils.parseObject(JSONUtils.toJSONString((Object)maps4), (Class)GoodsLvSe.class);
                            if (goodsLvSe == null) {
                                goodsLvSe = new GoodsLvSe();
                            }
                            goods4.goodsLvSe = goodsLvSe;
                        }
                        if (maps4.get("groupNo") == 8) {
                            maps4.put("groupType", 2);
                            final GoodsLvSeGongMing goodsLvSeGongMing2 = (GoodsLvSeGongMing)JSONUtils.parseObject(JSONUtils.toJSONString((Object)maps4), (Class)GoodsLvSeGongMing.class);
                            goods4.goodsLvSeGongMing = goodsLvSeGongMing2;
                        }
                    }
                    final int coin4 = ConsumeMoneyUtils.appendEqMoney(goods4.goodsInfo.attrib);
                    if(chara.balance<coin4) {return;}
                    chara.balance -= coin4;
                    GameUtil.MSG_UPDATE_IMPROVEMENT(chara);
                    final List<Goods> list = new ArrayList<Goods>();
                    list.add(goods4);
                    final ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
                    GameObjectChar.send(new MSG_INVENTORY(), list);
                    GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
                    final Vo_41191_0 vo_41191_3 = new Vo_41191_0();
                    vo_41191_3.flag = 1;
                    vo_41191_3.opType = "";
                    GameObjectChar.send(new M41191_0(), vo_41191_3);
                    final Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                    vo_20481_0.msg = "恭喜你，炼化成功，属性已生成";
                    vo_20481_0.time = 1562987118;
                    GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                    GameUtil.removemunber(chara, "超级绿水晶", 1);
                }
            }
        }
        if (3 == type) {
            final String[] split = para.split("\\_");
            if (split.length == 1) {
                return;
            }
            final int pos7 = Integer.parseInt(split[0]);
            final int pos3 = Integer.parseInt(split[1]);
            int iswuqi = 0;
            for (int i3 = 0; i3 < chara.backpack.size(); ++i3) {
                final Goods goods4 = chara.backpack.get(i3);
                if (pos == goods4.pos) {
                    iswuqi = goods4.goodsInfo.amount;
                    String str = null;
                    final Map<Object, Object> goodsGaiZai = UtilObjMapshuxing.GoodsGaiZaoGongMing(goods4.goodsGaiZaoGongMing);
                    final int[] ints = ForgingEquipmentUtils.remakeAttrib(goods4.goodsInfo.color, goods4.goodsInfo.store_exp, pos7);
                    if (ints[0] != goods4.goodsInfo.color) {
                        goods4.goodsInfo.store_exp = 0;
                        for (final Map.Entry<Object, Object> entry2 : goodsGaiZai.entrySet()) {
                            if (!entry2.getKey().equals("groupNo")) {
                                if (entry2.getKey().equals("groupType")) {
                                    continue;
                                }
                                if ((int)entry2.getValue() == 0) {
                                    continue;
                                }
                                str = (String) entry2.getKey();
                            }
                        }
                        final List<Hashtable<String, Integer>> hashtables2 = ForgingEquipmentUtils.appraisalRemakeEquipment(str, goods4.goodsInfo.amount, goods4.goodsInfo.attrib, goods4.goodsInfo.color + 1);
                        for (final Hashtable<String, Integer> maps2 : hashtables2) {
                            if (maps2.get("groupNo") == 27) {
                                maps2.put("groupType", 2);
                                final GoodsGaiZaoGongMing goodsGaiZaoGongMing2 = (GoodsGaiZaoGongMing)JSONUtils.parseObject(JSONUtils.toJSONString((Object)maps2), (Class)GoodsGaiZaoGongMing.class);
                                goods4.goodsGaiZaoGongMing = goodsGaiZaoGongMing2;
                            }
                            if (maps2.get("groupNo") == 10) {
                                maps2.put("groupType", 2);
                                final GoodsGaiZao goodsGaiZao = (GoodsGaiZao)JSONUtils.parseObject(JSONUtils.toJSONString((Object)maps2), (Class)GoodsGaiZao.class);
                                goods4.goodsGaiZao = goodsGaiZao;
                            }
                        }
                        final GoodsInfo goodsInfo = goods4.goodsInfo;
                        ++goodsInfo.color;
                        GameObjectChar.send(new M32775_0(), goods4);
                        final List<Goods> listgood = new ArrayList<Goods>();
                        listgood.add(goods4);
                        GameObjectChar.send(new MSG_INVENTORY(), listgood);
                        final Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                        vo_20481_0.msg = "恭喜你，改造成功！装备的改造等级提升到1级";
                        vo_20481_0.time = 1562987118;
                        GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                        GameUtil.MSG_UPDATE_IMPROVEMENT(chara);
                        final Vo_41191_0 vo_41191_4 = new Vo_41191_0();
                        vo_41191_4.flag = 1;
                        vo_41191_4.opType = "";
                        GameObjectChar.send(new M41191_0(), vo_41191_4);
                    }
                    else {
                        goods4.goodsInfo.store_exp = ints[1];
                        final List<Goods> listgood2 = new ArrayList<Goods>();
                        listgood2.add(goods4);
                        GameObjectChar.send(new MSG_INVENTORY(), listgood2);
                        final Vo_20481_0 vo_20481_4 = new Vo_20481_0();
                        vo_20481_4.msg = "改造失败，再接再厉";
                        vo_20481_4.time = 1562987118;
                        GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_4);
                        final Vo_41191_0 vo_41191_5 = new Vo_41191_0();
                        vo_41191_5.flag = 0;
                        vo_41191_5.opType = "";
                        GameObjectChar.send(new M41191_0(), vo_41191_5);
                    }
                    final int coin5 = ConsumeMoneyUtils.remakeMoney(goods4.goodsInfo.attrib);
                    if(chara.balance<coin5) {return;}
                    chara.balance -= coin5;
                    final ListVo_65527_0 listVo_65527_4 = GameUtil.a65527(chara);
                    GameObjectChar.send(new MSG_UPDATE(), listVo_65527_4);
                    if (iswuqi == 1) {
                        GameUtil.removemunber(chara, "超级灵石", pos7);
                    }
                    else {
                        GameUtil.removemunber(chara, "超级晶石", pos7);
                    }
                    GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
                    return;
                }
            }
        }
        if (8 == type) {
            final String[] split = para.split("\\|");
            final int pos7 = Integer.parseInt(split[0]);
            final int pos3 = Integer.parseInt(split[1]);
            final int pos4 = Integer.parseInt(split[2]);
            for (int i3 = 0; i3 < chara.backpack.size(); ++i3) {
                final Goods goods4 = chara.backpack.get(i3);
                if (goods4.pos == pos) {
                    final Map<Object, Object> goodsHuangSe = UtilObjMapshuxing.GoodsHuangSe(goods4.goodsHuangSe);
                    final Map<Object, Object> goodsLanSe2 = UtilObjMapshuxing.GoodsLanSe(goods4.goodsLanSe);
                    final Map<Object, Object> goodsFenSe = UtilObjMapshuxing.GoodsFenSe(goods4.goodsFenSe);
                    HashSet set = new HashSet();
                    final List a = new ArrayList();
                    for (final Map.Entry<Object, Object> entry3 : goodsHuangSe.entrySet()) {
                        if (!entry3.getKey().equals("groupNo")) {
                            if (entry3.getKey().equals("groupType")) {
                                continue;
                            }
                            if ((int)entry3.getValue() == 0) {
                                continue;
                            }
                            a.add(entry3.getKey());
                            set.add(entry3.getKey());
                        }
                    }
                    for (final Map.Entry<Object, Object> entry3 : goodsLanSe2.entrySet()) {
                        if (!entry3.getKey().equals("groupNo")) {
                            if (entry3.getKey().equals("groupType")) {
                                continue;
                            }
                            if ((int)entry3.getValue() == 0) {
                                continue;
                            }
                            a.add(entry3.getKey());
                            set.add(entry3.getKey());
                        }
                    }
                    for (final Map.Entry<Object, Object> entry3 : goodsFenSe.entrySet()) {
                        if (!entry3.getKey().equals("groupNo")) {
                            if (entry3.getKey().equals("groupType")) {
                                continue;
                            }
                            if ((int)entry3.getValue() == 0) {
                                continue;
                            }
                            a.add(entry3.getKey());
                            set.add(entry3.getKey());
                        }
                    }
                    final Collection rs = CollectionUtils.disjunction((Collection)a, (Collection)set);
                    set = new HashSet();
                    final Object[] objects = rs.toArray();
                    for (int j2 = 0; j2 < objects.length; ++j2) {
                        set.add(objects[j2]);
                    }
                    final List<Hashtable<String, Integer>> hashtables4 = ForgingEquipmentUtils.appraisalYellowEquipment(goods4.goodsInfo.amount, goods4.goodsInfo.attrib, 4, set, pos7);
                    if (hashtables4.size() > 0) {
                        final Vo_41191_0 vo_41191_6 = new Vo_41191_0();
                        vo_41191_6.flag = 1;
                        vo_41191_6.opType = "gold_refine";
                        GameObjectChar.send(new M41191_0(), vo_41191_6);
                        for (final Hashtable<String, Integer> maps5 : hashtables4) {
                            System.out.println(maps5.values());
                            System.out.println(maps5.keys());
                            maps5.put("groupType", 2);
                            final GoodsHuangSe goodsLanSeObj = (GoodsHuangSe)JSONUtils.parseObject(JSONUtils.toJSONString((Object)maps5), (Class)GoodsHuangSe.class);
                            goods4.goodsHuangSe = goodsLanSeObj;
                            GameUtil.MSG_UPDATE_IMPROVEMENT(chara);
                            final List list2 = new ArrayList();
                            list2.add(goods4);
                            GameObjectChar.send(new MSG_INVENTORY(), list2);
                            final Vo_9129_0 vo_9129_3 = new Vo_9129_0();
                            vo_9129_3.notify = 50;
                            vo_9129_3.para = "39563320";
                            GameObjectChar.send(new M9129_0(), vo_9129_3);
                        }
                    }
                    else {
                        final Vo_41191_0 vo_41191_6 = new Vo_41191_0();
                        vo_41191_6.flag = 0;
                        vo_41191_6.opType = "gold_refine";
                        GameObjectChar.send(new M41191_0(), vo_41191_6);
                        final Vo_20481_0 vo_20481_5 = new Vo_20481_0();
                        vo_20481_5.msg = "炼化失败，请继续努力！";
                        vo_20481_5.time = 1564556611;
                        GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_5);
                    }
                    final int coin6 = ConsumeMoneyUtils.yellowMoney(goods4.goodsInfo.attrib);
                    if(chara.balance<coin6) {return;}
                    chara.balance -= coin6;
                    final ListVo_65527_0 listVo_65527_5 = GameUtil.a65527(chara);
                    GameObjectChar.send(new MSG_UPDATE(), listVo_65527_5);
                    GameUtil.removemunber(chara, "黄水晶", pos3);
                }
            }
        }
        if (7 == type) {
            for (int i = 0; i < chara.backpack.size(); ++i) {
                final Goods goods = chara.backpack.get(i);
                if (goods.pos == pos) {
                    final Map<Object, Object> goodsHuangSe2 = UtilObjMapshuxing.GoodsHuangSe(goods.goodsHuangSe);
                    final Map<Object, Object> goodsLanSe3 = UtilObjMapshuxing.GoodsLanSe(goods.goodsLanSe);
                    final Map<Object, Object> goodsFenSe2 = UtilObjMapshuxing.GoodsFenSe(goods.goodsFenSe);
                    HashSet set2 = new HashSet();
                    final List a2 = new ArrayList();
                    for (final Map.Entry<Object, Object> entry : goodsHuangSe2.entrySet()) {
                        if (!entry.getKey().equals("groupNo")) {
                            if (entry.getKey().equals("groupType")) {
                                continue;
                            }
                            if ((int)entry.getValue() == 0) {
                                continue;
                            }
                            set2.add(entry.getKey());
                            a2.add(entry.getKey());
                        }
                    }
                    for (final Map.Entry<Object, Object> entry : goodsLanSe3.entrySet()) {
                        if (!entry.getKey().equals("groupNo")) {
                            if (entry.getKey().equals("groupType")) {
                                continue;
                            }
                            if ((int)entry.getValue() == 0) {
                                continue;
                            }
                            set2.add(entry.getKey());
                            a2.add(entry.getKey());
                        }
                    }
                    for (final Map.Entry<Object, Object> entry : goodsFenSe2.entrySet()) {
                        if (!entry.getKey().equals("groupNo")) {
                            if (entry.getKey().equals("groupType")) {
                                continue;
                            }
                            if ((int)entry.getValue() == 0) {
                                continue;
                            }
                            set2.add(entry.getKey());
                            a2.add(entry.getKey());
                        }
                    }
                    final Collection rs2 = CollectionUtils.disjunction((Collection)a2, (Collection)set2);
                    set2 = new HashSet();
                    final Object[] objects2 = rs2.toArray();
                    for (int j3 = 0; j3 < objects2.length; ++j3) {
                        set2.add(objects2[j3]);
                    }
                    final List<Hashtable<String, Integer>> hashtables2 = ForgingEquipmentUtils.appraisalEquipment(goods.goodsInfo.amount, goods.goodsInfo.attrib, 3, set2);
                    for (final Hashtable<String, Integer> maps2 : hashtables2) {
                        maps2.put("groupType", 2);
                        final GoodsFenSe goodsLanSeObj2 = (GoodsFenSe)JSONUtils.parseObject(JSONUtils.toJSONString((Object)maps2), (Class)GoodsFenSe.class);
                        goods.goodsFenSe = goodsLanSeObj2;
                        GameUtil.MSG_UPDATE_IMPROVEMENT(chara);
                        GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
                        final int coin7 = ConsumeMoneyUtils.pinkMoney(goods.goodsInfo.attrib);
                        if(chara.balance<coin7) {return;}
                        chara.balance -= coin7;
                        final ListVo_65527_0 listVo_65527_6 = GameUtil.a65527(chara);
                        GameObjectChar.send(new MSG_UPDATE(), listVo_65527_6);
                        final Vo_41191_0 vo_41191_7 = new Vo_41191_0();
                        vo_41191_7.flag = 1;
                        vo_41191_7.opType = "gold_refine";
                        GameObjectChar.send(new M41191_0(), vo_41191_7);
                        final Vo_9129_0 vo_9129_4 = new Vo_9129_0();
                        vo_9129_4.notify = 50;
                        vo_9129_4.para = "39563320";
                        GameObjectChar.send(new M9129_0(), vo_9129_4);
                    }
                    GameUtil.removemunber(chara, "超级粉水晶", 1);
                }
            }
        }
        if (10 == type) {
            final String[] split = para.split("\\|");
            final int pos7 = Integer.parseInt(split[0]);
            final String pos8 = split[1];
            final int pos4 = Integer.parseInt(split[2]);
            int count2 = 0;
            for (int i4 = 0; i4 < chara.backpack.size(); ++i4) {
                if (chara.backpack.get(i4).pos == pos7) {
                    ++count2;
                }
            }
            if (count2 == 0) {
                final Vo_20481_0 vo_20481_6 = new Vo_20481_0();
                vo_20481_6.msg = "请放入超级黑水晶！";
                vo_20481_6.time = 1562987118;
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_6);
                return;
            }
            int leve = 0;
            final Goods backpack1 = null;
            Boolean has2 = false;
            for (int i5 = 0; i5 < chara.backpack.size(); ++i5) {
                final Goods goods5 = chara.backpack.get(i5);
                if (goods5.pos == pos) {
                    leve = goods5.goodsInfo.attrib;
                    final Map<Object, Object> goodsLanSe4 = UtilObjMapshuxing.GoodsFenSe(goods5.goodsFenSe);
                    for (final Map.Entry<Object, Object> entry3 : goodsLanSe4.entrySet()) {
                        final String name = GameData.that.baseShuxingduiyingService.findOneByYingwen(pos8).getName();
                        final String equipmentKeyByName = ForgingEquipmentUtils.getEquipmentKeyByName(name, true);
                        if (entry3.getKey().equals(equipmentKeyByName)) {
                            final int[] equipmentKeyByNames = ForgingEquipmentUtils.appendAttrib(equipmentKeyByName, (Integer) entry3.getValue(), goods5.goodsInfo.attrib, goods5.goodsInfo.amount);
                            final int value = equipmentKeyByNames[0];
                            if ((int)entry3.getValue() < value) {
                                has2 = true;
                            }
                            goodsLanSe4.put(entry3.getKey(), value);
                            final GoodsFenSe goodsHuangSeObj1 = (GoodsFenSe)JSONUtils.parseObject(JSONUtils.toJSONString((Object)goodsLanSe4), (Class)GoodsFenSe.class);
                            goods5.goodsFenSe = goodsHuangSeObj1;
                            final List list2 = new ArrayList();
                            list2.add(goods5);
                            GameObjectChar.send(new MSG_INVENTORY(), list2);
                        }
                    }
                    GameUtil.removemunber(chara, "超级圣水晶", 1);
                }
            }
            if (has2) {
                for (int i5 = 0; i5 < chara.backpack.size(); ++i5) {
                    final Goods goods5 = chara.backpack.get(i5);
                    if (goods5.pos == pos7) {
                        final List<Goods> listbeibao = new ArrayList<Goods>();
                        final Goods goods6 = new Goods();
                        goods6.goodsBasics = null;
                        goods6.goodsInfo = null;
                        goods6.goodsLanSe = null;
                        goods6.goodsHuangSe = null;
                        goods6.goodsLvSe = null;
                        goods6.goodsFenSe = null;
                        goods6.pos = pos7;
                        listbeibao.add(goods6);
                        GameObjectChar.send(new MSG_INVENTORY(), listbeibao);
                        chara.backpack.remove(chara.backpack.get(i5));
                        GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
                        break;
                    }
                }
                final Vo_20481_0 vo_20481_2 = new Vo_20481_0();
                vo_20481_2.msg = "强化成功，请再接再厉！";
                vo_20481_2.time = 1562987118;
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_2);
                final Vo_41191_0 vo_41191_0 = new Vo_41191_0();
                vo_41191_0.flag = 1;
                vo_41191_0.opType = "";
                GameObjectChar.send(new M41191_0(), vo_41191_0);
            }
            else {
                final Vo_20481_0 vo_20481_2 = new Vo_20481_0();
                vo_20481_2.msg = "强化失败!";
                vo_20481_2.time = 1562987118;
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_2);
                final Vo_41191_0 vo_41191_0 = new Vo_41191_0();
                vo_41191_0.flag = 0;
                vo_41191_0.opType = "";
                GameObjectChar.send(new M41191_0(), vo_41191_0);
            }
            GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
            final Vo_9129_0 vo_9129_5 = new Vo_9129_0();
            vo_9129_5.notify = 51;
            vo_9129_5.para = "33927504";
            GameObjectChar.send(new M9129_0(), vo_9129_5);
            final int coin5 = ConsumeMoneyUtils.appendEqMoney(leve);
            if(chara.balance<coin5) {return;}
            chara.balance -= coin5;
            final ListVo_65527_0 listVo_65527_4 = GameUtil.a65527(chara);
            GameObjectChar.send(new MSG_UPDATE(), listVo_65527_4);
        }
        if (11 == type) {
            final String[] split = para.split("\\|");
            final int pos7 = Integer.parseInt(split[0]);
            final String pos8 = split[1];
            final int pos4 = Integer.parseInt(split[2]);
            int count2 = 0;
            for (int i4 = 0; i4 < chara.backpack.size(); ++i4) {
                if (chara.backpack.get(i4).pos == pos7) {
                    ++count2;
                }
            }
            if (count2 == 0) {
                final Vo_20481_0 vo_20481_6 = new Vo_20481_0();
                vo_20481_6.msg = "请放入超级黑水晶！";
                vo_20481_6.time = 1562987118;
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_6);
                return;
            }
            int leve = 0;
            final Goods backpack1 = null;
            Boolean has2 = false;
            for (int i5 = 0; i5 < chara.backpack.size(); ++i5) {
                final Goods goods5 = chara.backpack.get(i5);
                if (goods5.pos == pos) {
                    leve = goods5.goodsInfo.attrib;
                    final Map<Object, Object> goodsLanSe4 = UtilObjMapshuxing.GoodsHuangSe(goods5.goodsHuangSe);
                    for (final Map.Entry<Object, Object> entry3 : goodsLanSe4.entrySet()) {
                        final String name = GameData.that.baseShuxingduiyingService.findOneByYingwen(pos8).getName();
                        final String equipmentKeyByName = ForgingEquipmentUtils.getEquipmentKeyByName(name, true);
                        if (entry3.getKey().equals(equipmentKeyByName)) {
                            final int[] equipmentKeyByNames = ForgingEquipmentUtils.appendAttrib(equipmentKeyByName, (int)entry3.getValue(), goods5.goodsInfo.attrib, goods5.goodsInfo.amount);
                            final int value = equipmentKeyByNames[0];
                            if ((int)entry3.getValue() < value) {
                                has2 = true;
                            }
                            goodsLanSe4.put(entry3.getKey(), value);
                            final GoodsHuangSe goodsHuangSeObj2 = (GoodsHuangSe)JSONUtils.parseObject(JSONUtils.toJSONString((Object)goodsLanSe4), (Class)GoodsHuangSe.class);
                            goods5.goodsHuangSe = goodsHuangSeObj2;
                            final List list2 = new ArrayList();
                            list2.add(goods5);
                            GameObjectChar.send(new MSG_INVENTORY(), list2);
                        }
                    }
                    GameUtil.removemunber(chara, "超级圣水晶", 1);
                }
            }
            if (has2) {
                for (int i5 = 0; i5 < chara.backpack.size(); ++i5) {
                    final Goods goods5 = chara.backpack.get(i5);
                    if (goods5.pos == pos7) {
                        final List<Goods> listbeibao = new ArrayList<Goods>();
                        final Goods goods6 = new Goods();
                        goods6.goodsBasics = null;
                        goods6.goodsInfo = null;
                        goods6.goodsLanSe = null;
                        goods6.goodsHuangSe = null;
                        goods6.goodsLvSe = null;
                        goods6.goodsFenSe = null;
                        goods6.pos = pos7;
                        listbeibao.add(goods6);
                        GameObjectChar.send(new MSG_INVENTORY(), listbeibao);
                        chara.backpack.remove(chara.backpack.get(i5));
                        GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
                        break;
                    }
                }
                final Vo_20481_0 vo_20481_2 = new Vo_20481_0();
                vo_20481_2.msg = "强化成功，请再接再厉！";
                vo_20481_2.time = 1562987118;
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_2);
                final Vo_41191_0 vo_41191_0 = new Vo_41191_0();
                vo_41191_0.flag = 1;
                vo_41191_0.opType = "";
                GameObjectChar.send(new M41191_0(), vo_41191_0);
            }
            else {
                final Vo_20481_0 vo_20481_2 = new Vo_20481_0();
                vo_20481_2.msg = "强化失败！";
                vo_20481_2.time = 1562987118;
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_2);
                final Vo_41191_0 vo_41191_0 = new Vo_41191_0();
                vo_41191_0.flag = 0;
                vo_41191_0.opType = "";
                GameObjectChar.send(new M41191_0(), vo_41191_0);
            }
            final Vo_9129_0 vo_9129_5 = new Vo_9129_0();
            vo_9129_5.notify = 51;
            vo_9129_5.para = "33927504";
            GameObjectChar.send(new M9129_0(), vo_9129_5);
            final int coin5 = ConsumeMoneyUtils.appendEqMoney(leve);
            if(chara.balance<coin5) {return;}
            chara.balance -= coin5;
            final ListVo_65527_0 listVo_65527_4 = GameUtil.a65527(chara);
            GameObjectChar.send(new MSG_UPDATE(), listVo_65527_4);
        }
        if (9 == type) {
            final String[] split = para.split("\\|");
            final int pos7 = Integer.parseInt(split[0]);
            final String pos8 = split[1];
            final int pos4 = Integer.parseInt(split[2]);
            int count2 = 0;
            for (int i4 = 0; i4 < chara.backpack.size(); ++i4) {
                if (chara.backpack.get(i4).pos == pos7) {
                    ++count2;
                }
            }
            if (count2 == 0) {
                final Vo_20481_0 vo_20481_6 = new Vo_20481_0();
                vo_20481_6.msg = "请放入超级黑水晶！";
                vo_20481_6.time = 1562987118;
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_6);
                return;
            }
            int leve = 0;
            final Goods backpack1 = null;
            Boolean has2 = false;
            for (int i5 = 0; i5 < chara.backpack.size(); ++i5) {
                final Goods goods5 = chara.backpack.get(i5);
                if (goods5.pos == pos) {
                    leve = goods5.goodsInfo.attrib;
                    final Map<Object, Object> goodsLanSe4 = UtilObjMapshuxing.GoodsLanSe(goods5.goodsLanSe);
                    for (final Map.Entry<Object, Object> entry3 : goodsLanSe4.entrySet()) {
                        final String name = GameData.that.baseShuxingduiyingService.findOneByYingwen(pos8).getName();
                        final String equipmentKeyByName = ForgingEquipmentUtils.getEquipmentKeyByName(name, true);
                        if (entry3.getKey().equals(equipmentKeyByName)) {
                            final int[] equipmentKeyByNames = ForgingEquipmentUtils.appendAttrib(equipmentKeyByName, (int)entry3.getValue(), goods5.goodsInfo.attrib, goods5.goodsInfo.amount);
                            final int value = equipmentKeyByNames[0];
                            if ((int)entry3.getValue() < value) {
                                has2 = true;
                            }
                            goodsLanSe4.put(entry3.getKey(), value);
                            final GoodsLanSe goodsHuangSeObj3 = (GoodsLanSe)JSONUtils.parseObject(JSONUtils.toJSONString((Object)goodsLanSe4), (Class)GoodsLanSe.class);
                            goods5.goodsLanSe = goodsHuangSeObj3;
                            final List list2 = new ArrayList();
                            list2.add(goods5);
                            GameObjectChar.send(new MSG_INVENTORY(), list2);
                        }
                    }
                    GameUtil.removemunber(chara, "超级圣水晶", 1);
                }
            }
            if (has2) {
                for (int i5 = 0; i5 < chara.backpack.size(); ++i5) {
                    final Goods goods5 = chara.backpack.get(i5);
                    if (goods5.pos == pos7) {
                        final List<Goods> listbeibao = new ArrayList<Goods>();
                        final Goods goods6 = new Goods();
                        goods6.goodsBasics = null;
                        goods6.goodsInfo = null;
                        goods6.goodsLanSe = null;
                        goods6.goodsHuangSe = null;
                        goods6.goodsLvSe = null;
                        goods6.goodsFenSe = null;
                        goods6.pos = pos7;
                        listbeibao.add(goods6);
                        GameObjectChar.send(new MSG_INVENTORY(), listbeibao);
                        chara.backpack.remove(chara.backpack.get(i5));
                        GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
                        break;
                    }
                }
                final Vo_20481_0 vo_20481_2 = new Vo_20481_0();
                vo_20481_2.msg = "强化成功，请再接再厉！";
                vo_20481_2.time = 1562987118;
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_2);
                final Vo_41191_0 vo_41191_0 = new Vo_41191_0();
                vo_41191_0.flag = 1;
                vo_41191_0.opType = "";
                GameObjectChar.send(new M41191_0(), vo_41191_0);
                final Vo_9129_0 vo_9129_0 = new Vo_9129_0();
                vo_9129_0.notify = 51;
                vo_9129_0.para = "33927504";
                GameObjectChar.send(new M9129_0(), vo_9129_0);
            }
            else {
                final Vo_20481_0 vo_20481_2 = new Vo_20481_0();
                vo_20481_2.msg = "强化失败!";
                vo_20481_2.time = 1562987118;
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_2);
                final Vo_41191_0 vo_41191_0 = new Vo_41191_0();
                vo_41191_0.flag = 0;
                vo_41191_0.opType = "";
                GameObjectChar.send(new M41191_0(), vo_41191_0);
            }
            final int coin = ConsumeMoneyUtils.appendEqMoney(leve);
            if(chara.balance<coin) {return;}
            chara.balance -= coin;
            final ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
            GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
        }
        if (4 == type) {
            final ZhuangbeiInfo zhuangbeiInfo3 = GameData.that.baseZhuangbeiInfoService.findOneByType(Integer.valueOf(pos));
            final int coin8 = ConsumeMoneyUtils.createMoney(zhuangbeiInfo3.getAttrib());
            if(chara.balance<coin8) {return;}
            chara.balance -= coin8;
            final ListVo_65527_0 listVo_65527_7 = GameUtil.a65527(chara);
            GameObjectChar.send(new MSG_UPDATE(), listVo_65527_7);
            final String[] split3 = para.split("\\|");
            final int pos9 = Integer.parseInt(split3[0]);
            final int pos10 = Integer.parseInt(split3[1]);
            final int pos11 = Integer.parseInt(split3[2]);
            final Goods goods7 = new Goods();
            final Map<Object, Object> goodsLanSe5 = UtilObjMapshuxing.GoodsLanSe(goods7.goodsLanSe);
            Goods backpack2 = null;
            Goods backpack3 = null;
            Goods backpack4 = null;
            for (int i2 = 0; i2 < chara.backpack.size(); ++i2) {
                final Goods goods8 = chara.backpack.get(i2);
                if (goods8.pos == pos9) {
                    final Map<Object, Object> goodsLanSe6 = UtilObjMapshuxing.GoodsLanSe(goods8.goodsLanSe);
                    for (final Map.Entry<Object, Object> entry4 : goodsLanSe6.entrySet()) {
                        if (!entry4.getKey().equals("groupNo")) {
                            if (entry4.getKey().equals("groupType")) {
                                continue;
                            }
                            if (0 == (int)entry4.getValue()) {
                                continue;
                            }
                            goodsLanSe5.put(entry4.getKey(), entry4.getValue());
                        }
                    }
                    final List<Goods> listbeibao2 = new ArrayList<Goods>();
                    final Goods goods9 = new Goods();
                    goods9.goodsBasics = null;
                    goods9.goodsInfo = null;
                    goods9.goodsLanSe = null;
                    goods9.pos = pos9;
                    listbeibao2.add(goods9);
                    backpack2 = chara.backpack.get(i2);
                    GameObjectChar.send(new MSG_INVENTORY(), listbeibao2);
                }
                if (chara.backpack.get(i2).pos == pos10) {
                    final Map<Object, Object> goodsLanSe6 = UtilObjMapshuxing.GoodsLanSe(goods8.goodsLanSe);
                    for (final Map.Entry<Object, Object> entry4 : goodsLanSe6.entrySet()) {
                        if (!entry4.getKey().equals("groupNo")) {
                            if (entry4.getKey().equals("groupType")) {
                                continue;
                            }
                            if (0 == (int)entry4.getValue()) {
                                continue;
                            }
                            goodsLanSe5.put(entry4.getKey(), entry4.getValue());
                        }
                    }
                    final List<Goods> listbeibao2 = new ArrayList<Goods>();
                    final Goods goods9 = new Goods();
                    goods9.goodsBasics = null;
                    goods9.goodsInfo = null;
                    goods9.goodsLanSe = null;
                    goods9.pos = pos10;
                    listbeibao2.add(goods9);
                    backpack3 = chara.backpack.get(i2);
                    GameObjectChar.send(new MSG_INVENTORY(), listbeibao2);
                }
                if (chara.backpack.get(i2).pos == pos11) {
                    final Map<Object, Object> goodsLanSe6 = UtilObjMapshuxing.GoodsLanSe(goods8.goodsLanSe);
                    for (final Map.Entry<Object, Object> entry4 : goodsLanSe6.entrySet()) {
                        if (!entry4.getKey().equals("groupNo")) {
                            if (entry4.getKey().equals("groupType")) {
                                continue;
                            }
                            if (0 == (int)entry4.getValue()) {
                                continue;
                            }
                            goodsLanSe5.put(entry4.getKey(), entry4.getValue());
                        }
                    }
                    final List<Goods> listbeibao2 = new ArrayList<Goods>();
                    final Goods goods9 = new Goods();
                    goods9.goodsBasics = null;
                    goods9.goodsInfo = null;
                    goods9.goodsLanSe = null;
                    goods9.pos = pos11;
                    listbeibao2.add(goods9);
                    backpack4 = chara.backpack.get(i2);
                    GameObjectChar.send(new MSG_INVENTORY(), listbeibao2);
                }
            }
            final Vo_40964_0 vo_40964_2 = new Vo_40964_0();
            vo_40964_2.type = 1;
            vo_40964_2.name = zhuangbeiInfo3.getStr();
            vo_40964_2.param = "32271173";
            vo_40964_2.rightNow = 0;
            GameObjectChar.send(new M40964_0(), vo_40964_2);
            chara.backpack.remove(backpack2);
            chara.backpack.remove(backpack3);
            chara.backpack.remove(backpack4);
            GameUtil.huodezhuangbei(chara, zhuangbeiInfo3, 0, goods7);
            final GoodsLanSe goodsHuangSeObj4 = (GoodsLanSe)JSONUtils.parseObject(JSONUtils.toJSONString((Object)goodsLanSe5), (Class)GoodsLanSe.class);
            goods7.goodsLanSe = goodsHuangSeObj4;
            final List<Goods> listbeibao3 = new ArrayList<Goods>();
            listbeibao3.add(goods7);
            GameObjectChar.send(new MSG_INVENTORY(), listbeibao3);
            final Vo_9129_0 vo_9129_6 = new Vo_9129_0();
            vo_9129_6.notify = 49;
            vo_9129_6.para = "32271173";
            GameObjectChar.send(new M9129_0(), vo_9129_6);
        }
        if (type == 2) {
            for (int i = 0; i < chara.backpack.size(); ++i) {
                final boolean has3 = false;
                if (chara.backpack.get(i).pos == pos) {
                    final int coin9 = ConsumeMoneyUtils.removeMoney(chara.backpack.get(i).goodsInfo.attrib);
                    if(chara.balance<coin9) {return;}
                    chara.balance -= coin9;
                    final ListVo_65527_0 listVo_65527_8 = GameUtil.a65527(chara);
                    GameObjectChar.send(new MSG_UPDATE(), listVo_65527_8);
                    final Random random = new Random();
                    final Goods goods4 = chara.backpack.get(i);
                    final Map<Object, Object> goodsLanSe = UtilObjMapshuxing.GoodsLanSe(goods4.goodsLanSe);
                    final Map<Object, Object> goodsHuangSe3 = UtilObjMapshuxing.GoodsHuangSe(goods4.goodsHuangSe);
                    final Map<Object, Object> goodsFenSe = UtilObjMapshuxing.GoodsFenSe(goods4.goodsFenSe);
                    String name2 = "";
                    int cont = random.nextInt(10);
                    if (para.equals("3")) {
                        cont = 2;
                    }
                    int jilv = 2;
                    for (final Map.Entry<Object, Object> entry5 : goodsLanSe.entrySet()) {
                        if ((int)entry5.getValue() != 0 && cont <= jilv) {
                            if (entry5.getKey().equals("groupNo")) {
                                continue;
                            }
                            if (entry5.getKey().equals("groupType")) {
                                continue;
                            }
                            final Goods good = new Goods();
                            final Map<Object, Object> goodsLanSe7 = UtilObjMapshuxing.GoodsLanSe(good.goodsLanSe);
                            goodsLanSe7.put(entry5.getKey(), entry5.getValue());
                            name2 = ForgingEquipmentUtils.getEquipmentKeyByName((String) entry5.getKey(), false);
                            if (name2.contentEquals("伤害_最低伤害")) {
                                name2 = "伤害";
                            }
                            final StoreInfo storeInfo = GameData.that.baseStoreInfoService.findOneByName("超级黑水晶");
                            final GoodsLanSe goodsLanSeObj3 = (GoodsLanSe)JSONUtils.parseObject(JSONUtils.toJSONString((Object)goodsLanSe7), (Class)GoodsLanSe.class);
                            good.goodsLanSe = goodsLanSeObj3;
                            GameUtil.huodecaifen(chara, storeInfo, 1, goods4.goodsInfo.attrib, (int)entry5.getValue(), name2, good, goods4.goodsInfo.amount);
                            goodsLanSe.remove(entry5.getKey());
                            final GoodsLanSe goodsLanSeObj4 = (GoodsLanSe)JSONUtils.parseObject(JSONUtils.toJSONString((Object)goodsLanSe), (Class)GoodsLanSe.class);
                            goods4.goodsLanSe = goodsLanSeObj4;
                            final List list3 = new ArrayList();
                            list3.add(goods4);
                            GameObjectChar.send(new MSG_INVENTORY(), list3);
                            jilv = 0;
                            break;
                        }
                    }
                    for (final Map.Entry<Object, Object> entry5 : goodsHuangSe3.entrySet()) {
                        if ((int)entry5.getValue() != 0 && cont <= jilv) {
                            if (entry5.getKey().equals("groupNo")) {
                                continue;
                            }
                            if (entry5.getKey().equals("groupType")) {
                                continue;
                            }
                            final Goods good = new Goods();
                            final Map<Object, Object> goodsHuangSe4 = UtilObjMapshuxing.GoodsLanSe(good.goodsLanSe);
                            goodsHuangSe4.put(entry5.getKey(), entry5.getValue());
                            name2 = ForgingEquipmentUtils.getEquipmentKeyByName((String) entry5.getKey(), false);
                            if (name2.contentEquals("伤害_最低伤害")) {
                                name2 = "伤害";
                            }
                            final StoreInfo storeInfo = GameData.that.baseStoreInfoService.findOneByName("超级黑水晶");
                            final GoodsLanSe goodsHuangSeObj5 = (GoodsLanSe)JSONUtils.parseObject(JSONUtils.toJSONString((Object)goodsHuangSe4), (Class)GoodsLanSe.class);
                            good.goodsLanSe = goodsHuangSeObj5;
                            GameUtil.huodecaifen(chara, storeInfo, 1, goods4.goodsInfo.attrib, (Integer) entry5.getValue(), name2, good, goods4.goodsInfo.amount);
                            goodsHuangSe3.remove(entry5.getKey());
                            final GoodsHuangSe goodsHuangSeObj6 = (GoodsHuangSe)JSONUtils.parseObject(JSONUtils.toJSONString((Object)goodsHuangSe3), (Class)GoodsHuangSe.class);
                            goods4.goodsHuangSe = goodsHuangSeObj6;
                            final List list3 = new ArrayList();
                            list3.add(goods4);
                            GameObjectChar.send(new MSG_INVENTORY(), list3);
                            jilv = 0;
                            break;
                        }
                    }
                    for (final Map.Entry<Object, Object> entry5 : goodsFenSe.entrySet()) {
                        if (!entry5.getKey().equals("groupNo")) {
                            if (entry5.getKey().equals("groupType")) {
                                continue;
                            }
                            if ((int)entry5.getValue() != 0 && cont <= jilv) {
                                final Goods good = new Goods();
                                final Map<Object, Object> goodsFenSe3 = UtilObjMapshuxing.GoodsLanSe(good.goodsLanSe);
                                goodsFenSe3.put(entry5.getKey(), entry5.getValue());
                                name2 = ForgingEquipmentUtils.getEquipmentKeyByName((String) entry5.getKey(), false);
                                if (name2.contentEquals("伤害_最低伤害")) {
                                    name2 = "伤害";
                                }
                                final StoreInfo storeInfo = GameData.that.baseStoreInfoService.findOneByName("超级黑水晶");
                                final GoodsLanSe goodsFenSeObj = (GoodsLanSe)JSONUtils.parseObject(JSONUtils.toJSONString((Object)goodsFenSe3), (Class)GoodsLanSe.class);
                                good.goodsLanSe = goodsFenSeObj;
                                GameUtil.huodecaifen(chara, storeInfo, 1, goods4.goodsInfo.attrib, (Integer) entry5.getValue(), name2, good, goods4.goodsInfo.amount);
                                goodsFenSe.remove(entry5.getKey());
                                final GoodsFenSe goodsFenSeObj2 = (GoodsFenSe)JSONUtils.parseObject(JSONUtils.toJSONString((Object)goodsFenSe), (Class)GoodsFenSe.class);
                                goods4.goodsFenSe = goodsFenSeObj2;
                                final List list3 = new ArrayList();
                                list3.add(goods4);
                                GameObjectChar.send(new MSG_INVENTORY(), list3);
                                jilv = 0;
                                break;
                            }
                            continue;
                        }
                    }
                    int number = 0;
                    for (final Map.Entry<Object, Object> entry6 : goodsLanSe.entrySet()) {
                        if (!entry6.getKey().equals("groupNo")) {
                            if (entry6.getKey().equals("groupType")) {
                                continue;
                            }
                            number += (int)entry6.getValue();
                        }
                    }
                    for (final Map.Entry<Object, Object> entry6 : goodsHuangSe3.entrySet()) {
                        if (!entry6.getKey().equals("groupNo")) {
                            if (entry6.getKey().equals("groupType")) {
                                continue;
                            }
                            number += (int)entry6.getValue();
                        }
                    }
                    for (final Map.Entry<Object, Object> entry6 : goodsFenSe.entrySet()) {
                        if (!entry6.getKey().equals("groupNo")) {
                            if (entry6.getKey().equals("groupType")) {
                                continue;
                            }
                            number += (int)entry6.getValue();
                        }
                    }
                    if (number == 0) {
                        final List<Goods> listbeibao4 = new ArrayList<Goods>();
                        final Goods goods10 = new Goods();
                        goods10.goodsBasics = null;
                        goods10.goodsInfo = null;
                        goods10.goodsLanSe = null;
                        goods10.pos = pos;
                        listbeibao4.add(goods10);
                        chara.backpack.remove(chara.backpack.get(i));
                        GameObjectChar.send(new MSG_INVENTORY(), listbeibao4);
                    }
                    final Vo_20481_0 vo_20481_7 = new Vo_20481_0();
                    if (name2.equals("")) {
                        vo_20481_7.msg = "拆分失败，请继续努力";
                    }
                    else {
                        vo_20481_7.msg = "你成功拆分出了属性#R" + name2 + "#n";
                    }
                    vo_20481_7.time = 1562987118;
                    GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_7);
                    GameUtil.removemunber(chara, "超级黑水晶", 1);
                    if (para.equals("3")) {
                        GameUtil.removemunber(chara, "混沌玉", 1);
                    }
                }
            }
        }
        if (1 == type || 12 == type) {
            for (int i = 0; i < chara.backpack.size(); ++i) {
                if (chara.backpack.get(i).pos == pos) {
                    final Goods goods = chara.backpack.get(i);
                    final Map<Object, Object> objectObjectMap = UtilObjMapshuxing.Goods(goods);
                    if (type == 1) {
                        final List<Hashtable<String, Integer>> hashtables5 = ForgingEquipmentUtils.appraisalEquipment(goods.goodsInfo.amount, goods.goodsInfo.attrib, 1);
                        final Map<Object, Object> goodsLanSe8 = UtilObjMapshuxing.GoodsLanSe(goods.goodsLanSe);
                        for (final Hashtable<String, Integer> maps6 : hashtables5) {
                            final int groupNo = maps6.get("groupNo");
                            final int groupNolanse = (int) goodsLanSe8.get("groupNo");
                            if (groupNolanse == groupNo) {
                                for (final Map.Entry<String, Integer> entry7 : maps6.entrySet()) {
                                    goodsLanSe8.put(entry7.getKey(), entry7.getValue());
                                }
                            }
                        }
                        final GoodsLanSe goodsLanSeObj5 = (GoodsLanSe)JSONUtils.parseObject(JSONUtils.toJSONString((Object)goodsLanSe8), (Class)GoodsLanSe.class);
                        final Goods goods11 = (Goods)JSONUtils.parseObject(JSONUtils.toJSONString((Object)objectObjectMap), (Class)Goods.class);
                        Goods goods7 = new Goods();
                        goods7 = goods11;
                        goods7.pos = GameUtil.beibaoweizhi(chara);
                        goods7.goodsInfo.degree_32 = 0;
                        goods7.goodsInfo.owner_id = 1;
                        goods7.goodsLanSe = goodsLanSeObj5;
                        GameUtil.MSG_UPDATE_IMPROVEMENT(chara);
                        final List list4 = new ArrayList();
                        list4.add(goods7);
                        GameUtil.removemunber(chara, goods, 1);
                        chara.backpack.add(goods7);
                        GameObjectChar.send(new MSG_INVENTORY(), list4);
                    }
                    if (type == 12) {
                        final List<Hashtable<String, Integer>> hashtables5 = ForgingEquipmentUtils.appraisalEquipment(goods.goodsInfo.amount, goods.goodsInfo.attrib, 2);
                        final Map<Object, Object> goodsLanSe8 = UtilObjMapshuxing.GoodsLanSe(goods.goodsLanSe);
                        final Map<Object, Object> goodshuangse = UtilObjMapshuxing.GoodsHuangSe(goods.goodsHuangSe);
                        final Map<Object, Object> goodsfense = UtilObjMapshuxing.GoodsFenSe(goods.goodsFenSe);
                        for (final Hashtable<String, Integer> maps4 : hashtables5) {
                            final int groupNo2 = maps4.get("groupNo");
                            final int groupNolanse2 = (int)goodsLanSe8.get("groupNo");
                            final int groupNohuangse = (int)goodshuangse.get("groupNo");
                            final int groupNofense = (int)goodsfense.get("groupNo");
                            if (groupNolanse2 == groupNo2) {
                                for (final Map.Entry<String, Integer> entry8 : maps4.entrySet()) {
                                    goodsLanSe8.put(entry8.getKey(), entry8.getValue());
                                }
                            }
                            if (groupNohuangse == groupNo2) {
                                for (final Map.Entry<String, Integer> entry8 : maps4.entrySet()) {
                                    goodshuangse.put(entry8.getKey(), entry8.getValue());
                                }
                            }
                            if (groupNofense == groupNo2) {
                                for (final Map.Entry<String, Integer> entry8 : maps4.entrySet()) {
                                    goodsfense.put(entry8.getKey(), entry8.getValue());
                                }
                            }
                        }
                        final GoodsLanSe goodsLanSeObj6 = (GoodsLanSe)JSONUtils.parseObject(JSONUtils.toJSONString((Object)goodsLanSe8), (Class)GoodsLanSe.class);
                        final GoodsHuangSe goodshuangseObj = (GoodsHuangSe)JSONUtils.parseObject(JSONUtils.toJSONString((Object)goodshuangse), (Class)GoodsHuangSe.class);
                        final GoodsFenSe goodsfenseObj = (GoodsFenSe)JSONUtils.parseObject(JSONUtils.toJSONString((Object)goodsfense), (Class)GoodsFenSe.class);
                        Goods goods12 = new Goods();
                        final Goods goods6 = goods12 = (Goods)JSONUtils.parseObject(JSONUtils.toJSONString((Object)objectObjectMap), (Class)Goods.class);
                        goods12.pos = GameUtil.beibaoweizhi(chara);
                        goods12.goodsInfo.owner_id = 1;
                        goods12.goodsInfo.degree_32 = 0;
                        goods12.goodsLanSe = goodsLanSeObj6;
                        goods12.goodsHuangSe = goodshuangseObj;
                        goods12.goodsFenSe = goodsfenseObj;
                        GameUtil.MSG_UPDATE_IMPROVEMENT(chara);
                        final List list5 = new ArrayList();
                        list5.add(goods12);
                        GameUtil.removemunber(chara, goods, 1);
                        chara.backpack.add(goods12);
                        GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
                    }
                    final int coin10 = ConsumeMoneyUtils.appraisalMoney(goods.goodsInfo.attrib);
                    chara.balance -= coin10;
                    final ListVo_65527_0 listVo_65527_9 = GameUtil.a65527(chara);
                    GameObjectChar.send(new MSG_UPDATE(), listVo_65527_9);
                }
            }
            final Vo_20481_0 vo_20481_8 = new Vo_20481_0();
            vo_20481_8.msg = "鉴定成功！";
            vo_20481_8.time = 1562987118;
            GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_8);
            final Vo_9129_0 vo_9129_7 = new Vo_9129_0();
            vo_9129_7.notify = 20022;
            vo_9129_7.para = "11516529|1";
            GameObjectChar.send(new M9129_0(), vo_9129_7);
        }
    }

    @Override
    public int cmd() {
        return 32776;
    }

    public static Goods shuxing(final Goods goods, final Goods good) {
        return good;
    }
}
