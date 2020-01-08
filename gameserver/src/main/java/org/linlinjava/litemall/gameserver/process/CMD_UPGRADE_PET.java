/*     */
package org.linlinjava.litemall.gameserver.process;
/*     */
/*     */

import io.netty.buffer.ByteBuf;
/*     */ import io.netty.channel.ChannelHandlerContext;
/*     */ import java.util.ArrayList;
/*     */ import java.util.List;
/*     */ import org.linlinjava.litemall.db.domain.Pet;
/*     */
/*     */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*     */ import org.linlinjava.litemall.gameserver.data.game.BasicAttributesUtils;
/*     */ import org.linlinjava.litemall.gameserver.data.game.PetAttributesUtils;
import org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_NOTIFY_MISC_EX;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M45670_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M53607_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE_PETS;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_INVENTORY;
import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE;
/*     */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ import org.linlinjava.litemall.gameserver.domain.Goods;
/*     */
/*     */ import org.linlinjava.litemall.gameserver.domain.PetShuXing;
/*     */ import org.linlinjava.litemall.gameserver.domain.Petbeibao;
/*     */ import org.linlinjava.litemall.gameserver.game.GameData;
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;

/*     */
/*     */
@org.springframework.stereotype.Service
/*     */ public class CMD_UPGRADE_PET implements org.linlinjava.litemall.gameserver.GameHandler
        /*     */ {
    /*     */
    public void process(ChannelHandlerContext ctx, ByteBuf buff)
    /*     */ {
        /*  31 */
        String type = GameReadTool.readString(buff);
        /*     */
        /*  33 */
        int no = GameReadTool.readInt(buff);
        /*     */
        /*  35 */
        String pos = GameReadTool.readString(buff);
        /*     */
        /*  37 */
        String other_pet = GameReadTool.readString(buff);
        /*     */
        /*  39 */
        String cost_type = GameReadTool.readString(buff);
        /*     */
        /*  41 */
        String ids = GameReadTool.readString(buff);
        /*     */
        /*  43 */
        Chara chara = GameObjectChar.getGameObjectChar().chara;
        /*     */
        /*     */
        /*     */
        /*  47 */
        if (type.equals("pet_open_eclosion")) {
            /*  48 */
            for (int i = 0; i < chara.pets.size(); i++) {
                /*  49 */
                Petbeibao petbeibao = (Petbeibao) chara.pets.get(i);
                /*  50 */
                if (petbeibao.no == no) {
                    /*  51 */
                    Pet pet = GameData.that.basePetService.findOneByName(((PetShuXing) petbeibao.petShuXing.get(0)).str);
                    /*  52 */
                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                    /*  53 */
                    vo_20481_0.msg = ("恭喜，你的#Y" + ((PetShuXing) petbeibao.petShuXing.get(0)).str + "#n已成功#G开启羽化");
                    /*  54 */
                    vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
                    /*  55 */
                    GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                    /*     */
                    /*  57 */
                    PetShuXing petShuXing = (PetShuXing) petbeibao.petShuXing.get(0);
                    /*     */
                    /*  59 */
                    int quality = ((PetShuXing) petbeibao.petShuXing.get(0)).penetrate - 1;
                    /*     */
                    /*     */
                    /*  62 */
                    int[] appends = {petShuXing.pet_mana_shape, petShuXing.pet_speed_shape, petShuXing.pet_mag_shape, petShuXing.rank, petShuXing.pet_phy_shape};
                    /*  63 */
                    int[] ints = PetAttributesUtils.emergencePet(quality, petShuXing.attrib, ((PetShuXing) petbeibao.petShuXing.get(0)).eclosion_nimbus, petShuXing.max_eclosion_nimbus, 1, 0, 0, appends);
                    /*     */
                    /*  65 */
                    if (ints[0] == 1) {
                        /*  66 */
                        ((PetShuXing) petbeibao.petShuXing.get(0)).eclosion_nimbus = 2;
                        /*     */
                    } else {
                        /*  68 */
                        ((PetShuXing) petbeibao.petShuXing.get(0)).eclosion_nimbus = 1;
                        /*     */
                    }
                    /*     */
                    /*  71 */
                    ((PetShuXing) petbeibao.petShuXing.get(0)).max_eclosion_nimbus = ints[1];
                    /*  77 */
                    List list = new ArrayList();
                    /*  78 */
                    BasicAttributesUtils.petshuxing((PetShuXing) petbeibao.petShuXing.get(0));
                    /*  79 */
                    list.add(petbeibao);
                    /*  80 */
                    GameObjectChar.send(new MSG_UPDATE_PETS(), list);
                    /*  81 */
                    GameUtil.removemunber(chara, "羽化丹", 1);
                    /*  82 */
                    GameObjectChar.send(new M53607_0(), null);
                    /*     */
                }
                /*     */
            }
            /*     */
        }
        /*     */
        /*  87 */
        if (type.equals("pet_eclosion")) {
            /*  88 */
            for (int i = 0; i < chara.pets.size(); i++) {
                /*  89 */
                Petbeibao petbeibao = (Petbeibao) chara.pets.get(i);
                /*  90 */
                if (petbeibao.no == no) {
                    /*  91 */
                    Pet pet = GameData.that.basePetService.findOneByName(((PetShuXing) petbeibao.petShuXing.get(0)).str);
                    /*  92 */
                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                    /*  93 */
                    vo_20481_0.msg = ("恭喜，你的#Y" + ((PetShuXing) petbeibao.petShuXing.get(0)).str + "#n获得灵气");
                    /*  94 */
                    vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
                    /*  95 */
                    GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                    /*  96 */
                    PetShuXing petShuXing = (PetShuXing) petbeibao.petShuXing.get(0);
                    /*  97 */
                    int quality = ((PetShuXing) petbeibao.petShuXing.get(0)).penetrate;
                    /*  98 */
                    /*  99 */
                    String[] split = pos.split("\\|");
                    int pill = 0;
                    /* 100 */
                    int unidentifiedMoney = 0;
                    /* 101 */
                    int equiqmentMoney = 0;
                    if (split.length == 1 && split[0] == "") {
//						System.out.println(cost_type + "aaa" + split[0]+ "{{{{{"+split.length+"||||111111111111111");
                        cost_type.equals("gold_coin");
                        if (chara.extra_life >= 3108 && cost_type.equals("gold_coin")) {
                            pill = 6;
                            chara.extra_life -= 3108;
                        } else if (chara.gold_coin >= 3108 && cost_type.equals("")) {
                            pill = 6;
                            chara.gold_coin -= 3108;
                        } else {
                            return;
                        }

                    } else {
                        for (int j = 0; j < chara.backpack.size(); j++) {
                            Goods goods = (Goods) chara.backpack.get(j);
                            for (int k = 0; k < split.length; k++) {
                                if (goods.pos == Integer.parseInt(split[k])) {
                                    if (goods.goodsInfo.str.equals("羽化丹")) {
                                        pill++;
                                    } else {
                                        if (goods.goodsInfo.degree_32 == 0) {
                                            unidentifiedMoney += 10000;
                                        } else {
                                            equiqmentMoney += 10000;
                                        }
                                        List<Goods> listbeibao = new ArrayList();
                                        Goods goods1 = new Goods();
                                        goods1.goodsBasics = null;
                                        goods1.goodsInfo = null;
                                        goods1.goodsLanSe = null;
                                        goods1.pos = goods.pos;
                                        listbeibao.add(goods1);
                                        chara.backpack.remove(chara.backpack.get(j));
                                        GameObjectChar.send(new MSG_INVENTORY(), listbeibao);
                                    }
                                }
                            }
                        }
                    }
                    int[] appends = {petShuXing.mana_effect + 40, petShuXing.attack_effect + 40,
                            petShuXing.mag_effect + 40, petShuXing.phy_absorb + 40, petShuXing.phy_effect + 40};
                    int[] ints = PetAttributesUtils.emergencePet(quality, petShuXing.attrib, ( petbeibao.petShuXing.get(0)).status_yanchuan_shenjiao + 1,
                            petShuXing.max_eclosion_nimbus, pill, equiqmentMoney, equiqmentMoney, appends);

                   // 往下羽化代码没问题  主要在于
                    if (ints[0] == 1) {
                        int count = ((PetShuXing) petbeibao.petShuXing.get(0)).status_yanchuan_shenjiao++;
                        ((PetShuXing) petbeibao.petShuXing.get(0)).max_eclosion_nimbus = 0;
                        ((PetShuXing) petbeibao.petShuXing.get(0)).pet_mana_shape += ints[2] / 3;
                        ((PetShuXing) petbeibao.petShuXing.get(0)).pet_speed_shape += ints[3] / 3;
                        ((PetShuXing) petbeibao.petShuXing.get(0)).pet_mag_shape += ints[4] / 3;
                        ((PetShuXing) petbeibao.petShuXing.get(0)).rank += ints[5] / 3;
                        ((PetShuXing) petbeibao.petShuXing.get(0)).pet_phy_shape += ints[6] / 3;
                    } else {
                        ((PetShuXing) petbeibao.petShuXing.get(0)).max_eclosion_nimbus = ints[1]; //相加当前灵气值 等到达瓶颈 就进行 属性的增加
                    }

                    if (((PetShuXing) petbeibao.petShuXing.get(0)).status_yanchuan_shenjiao > 2) {   //当阶段大于2的时候 就等于 羽化成功 状态为2
                        ((PetShuXing) petbeibao.petShuXing.get(0)).status_yanchuan_shenjiao = 2;
                        ((PetShuXing) petbeibao.petShuXing.get(0)).eclosion_nimbus += 1; //阶段
                        ((PetShuXing) petbeibao.petShuXing.get(0)).max_eclosion_nimbus = 0;  // 等于0羽化完成
                    }
                    List list = new ArrayList();
                    BasicAttributesUtils.petshuxing((PetShuXing) petbeibao.petShuXing.get(0));
                    list.add(petbeibao);


                    GameObjectChar.send(new MSG_UPDATE_PETS(), list);
                    GameObjectChar.send(new M53607_0(), null);
                    ListVo_65527_0 vo_65527_0 = GameUtil.a65527(chara);
                    GameObjectChar.send(new MSG_UPDATE(), vo_65527_0);
                    if (split.length == 1 && split[0] == "") {
                        return;
                    } else {
                        GameUtil.removemunber(chara, "羽化丹", pill);   //删除背包函数
                    }
                }
            }
        }

        if (type.equals("pet_enchant")) {
            for (int i = 0; i < chara.pets.size(); i++) {
                Petbeibao petbeibao = (Petbeibao) chara.pets.get(i);
                if (petbeibao.no == no) {
                    Pet pet = GameData.that.basePetService
                            .findOneByName(((PetShuXing) petbeibao.petShuXing.get(0)).str);
                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();

                    vo_20481_0.msg = ("恭喜，你的#Y" + ((PetShuXing) petbeibao.petShuXing.get(0)).str + "#n获得灵气");
                    vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));  //消息提示
                    GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);

                    PetShuXing petShuXing = (PetShuXing) petbeibao.petShuXing.get(0);

                    int quality = ((PetShuXing) petbeibao.petShuXing.get(0)).penetrate - 1;

                    String[] split = pos.split("\\|");
                    int pill = 0;
                    int unidentifiedMoney = 0;
                    int equiqmentMoney = 0;
                    for (int j = 0; j < chara.backpack.size(); j++) {
                        Goods goods = (Goods) chara.backpack.get(j);
                        for (int k = 0; k < split.length; k++) {
                            if (goods.pos == Integer.parseInt(split[k])) {
                                if (goods.goodsInfo.str.equals("点化丹")) {
                                    pill++;
                                } else {
                                    if (goods.goodsInfo.degree_32 == 0) {
                                        unidentifiedMoney += 10000;
                                    } else {
                                        equiqmentMoney += 10000;
                                    }
                                    List<Goods> listbeibao = new ArrayList();
                                    Goods goods1 = new Goods();
                                    goods1.goodsBasics = null;
                                    goods1.goodsInfo = null;
                                    goods1.goodsLanSe = null;
                                    goods1.pos = goods.pos;
                                    listbeibao.add(goods1);
                                    chara.backpack.remove(chara.backpack.get(j));
                                    GameObjectChar.send(new MSG_INVENTORY(), listbeibao);
                                }
                            }
                        }
                    }

                    int[] appends = {petShuXing.pet_mana_shape, petShuXing.pet_speed_shape, petShuXing.pet_mag_shape, petShuXing.rank, petShuXing.pet_phy_shape};
                    int[] ints = PetAttributesUtils.dotPet(quality, petShuXing.attrib, petShuXing.max_enchant_nimbus, pill, equiqmentMoney, equiqmentMoney, appends);
                    if (ints[0] == 1) { // 等于2的时候则是点化成功 只家到百分之七十就成功了
                        ((PetShuXing) petbeibao.petShuXing.get(0)).enchant_nimbus = 2;
                    } else {
                        ((PetShuXing) petbeibao.petShuXing.get(0)).enchant_nimbus = 1;
                    }

                ((PetShuXing) petbeibao.petShuXing.get(0)).max_enchant_nimbus = ints[1];
                ((PetShuXing) petbeibao.petShuXing.get(0)).pet_mana_shape = (((PetShuXing) petbeibao.petShuXing.get(0)).mana_effect + ints[2] + 40);
                ((PetShuXing) petbeibao.petShuXing.get(0)).pet_speed_shape = (((PetShuXing) petbeibao.petShuXing.get(0)).attack_effect + ints[3] + 40);
                ((PetShuXing) petbeibao.petShuXing.get(0)).pet_mag_shape = (((PetShuXing) petbeibao.petShuXing.get(0)).mag_effect + ints[4] + 40);
                ((PetShuXing) petbeibao.petShuXing.get(0)).rank = (((PetShuXing) petbeibao.petShuXing.get(0)).phy_absorb + ints[5] + 40);
                ((PetShuXing) petbeibao.petShuXing.get(0)).pet_phy_shape = (((PetShuXing) petbeibao.petShuXing.get(0)).phy_effect + ints[6] + 40);

                    List list = new ArrayList();
                    BasicAttributesUtils.petshuxing((PetShuXing) petbeibao.petShuXing.get(0));
                    list.add(petbeibao);
                    GameObjectChar.send(new MSG_UPDATE_PETS(), list);
                    GameUtil.removemunber(chara, "点化丹", pill);  //后面是删除数量
                    GameObjectChar.send(new M45670_0(), null);
                }
            }
        }


        if (type.equals("pet_open_enchant")) {
            for (int i = 0; i < chara.pets.size(); i++) {
                Petbeibao petbeibao = (Petbeibao) chara.pets.get(i);
                if (petbeibao.no == no) {
                    Pet pet = GameData.that.basePetService.findOneByName(((PetShuXing) petbeibao.petShuXing.get(0)).str);
                    Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                    vo_20481_0.msg = ("恭喜，你的#Y" + ((PetShuXing) petbeibao.petShuXing.get(0)).str + "#n已成功#G开启点化");
                    /* 269 */
                    vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
                    /* 270 */
                    GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                    /*     */
                    /* 272 */
                    PetShuXing petShuXing = (PetShuXing) petbeibao.petShuXing.get(0);
                    /*     */
                    /* 274 */
                    int quality = ((PetShuXing) petbeibao.petShuXing.get(0)).penetrate - 1;
                    /* 277 */
                    int[] appends = {petShuXing.pet_mana_shape, petShuXing.pet_speed_shape, petShuXing.pet_mag_shape, petShuXing.rank, petShuXing.pet_phy_shape};
                    /* 278 */
                    int[] ints = PetAttributesUtils.dotPet(quality, petShuXing.attrib, petShuXing.max_enchant_nimbus, 1, 0, 0, appends);
                    /*     */
                    /* 280 */
                    if (ints[0] == 1) {
                        /* 281 */
                        ((PetShuXing) petbeibao.petShuXing.get(0)).enchant_nimbus = 2;
                        /*     */
                    } else {
                        /* 283 */
                        ((PetShuXing) petbeibao.petShuXing.get(0)).enchant_nimbus = 1;
                        /*     */
                    }
                    /*     */
                    /* 286 */
                    ((PetShuXing) petbeibao.petShuXing.get(0)).max_enchant_nimbus = ints[1];
                    /* 287 */
                    ((PetShuXing) petbeibao.petShuXing.get(0)).pet_mana_shape += ints[2];
                    /* 288 */
                    ((PetShuXing) petbeibao.petShuXing.get(0)).pet_speed_shape += ints[3];
                    /* 289 */
                    ((PetShuXing) petbeibao.petShuXing.get(0)).pet_mag_shape += ints[4];
                    /* 290 */
                    ((PetShuXing) petbeibao.petShuXing.get(0)).rank += ints[5];
                    /* 291 */
                    ((PetShuXing) petbeibao.petShuXing.get(0)).pet_phy_shape += ints[6];
                    /* 292 */
                    List list = new ArrayList();
                    /* 293 */
                    BasicAttributesUtils.petshuxing((PetShuXing) petbeibao.petShuXing.get(0));
                    /* 294 */
                    list.add(petbeibao);
                    /* 295 */
                    GameObjectChar.send(new MSG_UPDATE_PETS(), list);
                    /* 296 */
                    GameUtil.removemunber(chara, "点化丹", 1);
                    /* 297 */
                    GameObjectChar.send(new M45670_0(), null);
                    /*     */
                }
                /*     */
            }
            /*     */
        }
        /*     */
    }

    /*     */
    /*     */
    /*     */
    public int cmd()
    /*     */ {
        /* 306 */
        return 53314;
        /*     */
    }
    /*     */
}

