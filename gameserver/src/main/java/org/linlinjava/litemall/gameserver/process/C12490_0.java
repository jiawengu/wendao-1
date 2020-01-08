/*     */ package org.linlinjava.litemall.gameserver.process;
/*     */
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import io.netty.channel.ChannelHandlerContext;
/*     */ import java.util.List;
/*     */ import org.linlinjava.litemall.db.domain.Characters;
/*     */ import org.linlinjava.litemall.db.domain.SaleGood;
/*     */
/*     */
/*     */ import org.linlinjava.litemall.db.util.JSONUtils;
/*     */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_12269_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_33049_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_40964_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_49183;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_49183_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_NOTIFY_MISC_EX;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE;
import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE_PETS;
import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ import org.linlinjava.litemall.gameserver.domain.Goods;
/*     */ import org.linlinjava.litemall.gameserver.domain.PetShuXing;
/*     */ import org.linlinjava.litemall.gameserver.domain.Petbeibao;
/*     */ import org.linlinjava.litemall.gameserver.game.GameData;
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * CMD_BUY_FROM_STALL
 */
/*     */
/*     */ @org.springframework.stereotype.Service
/*     */ public class C12490_0 implements org.linlinjava.litemall.gameserver.GameHandler
        /*     */ {
                private static final Logger log = LoggerFactory.getLogger(C12490_0.class);
    /*     */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
    /*     */   {
        /*  31 */     String id = GameReadTool.readString(buff);
        /*     */
        /*  33 */     String key = GameReadTool.readString(buff);
        /*     */
        /*  35 */     String pageStr = GameReadTool.readString(buff);
        /*     */
        /*  37 */     int price = GameReadTool.readInt(buff);
        /*     */
        /*  39 */     int type = GameReadTool.readByte(buff);
        /*     */
        /*  41 */     int amount = GameReadTool.readShort(buff);
        /*     */
        /*     */
        /*  44 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
        /*  45 */     SaleGood saleGood = GameData.that.saleGoodService.findOneByGoodsId(id);
        /*     */
        /*  47 */     if (saleGood.getOwnerUuid().equals(chara.uuid)) {
            /*  48 */       Vo_20481_0 vo_20481_0 = new Vo_20481_0();
            /*  49 */       vo_20481_0.msg = "道友,这是你自己出售的商品哦。";
            /*  50 */       vo_20481_0.time = ((int)(System.currentTimeMillis() / 1000L));
            /*  51 */       GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
            /*  52 */       return;
            /*     */     }
        /*     */
        /*  55 */     if (saleGood.getIspet().intValue() == 1) {
            /*  56 */       String goods = saleGood.getGoods();
            /*  57 */       Goods goods1 = (Goods)JSONUtils.parseObject(goods, Goods.class);
            /*  58 */       List list = new java.util.LinkedList();
            /*  59 */       goods1.pos = GameUtil.beibaoweizhi(chara);
            /*  60 */       goods1.goodsInfo.owner_id = 1;
            /*  61 */       GameUtil.addwupin(goods1, chara);
            /*  62 */       Vo_40964_0 vo_40964_9 = new Vo_40964_0();
            /*  63 */       vo_40964_9.type = 1;
            /*  64 */       vo_40964_9.name = saleGood.getName();
            /*  65 */       vo_40964_9.param = "-1";
            /*  66 */       vo_40964_9.rightNow = 0;
            /*  67 */       GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M40964_0(), vo_40964_9);
            /*     */     } else {
            /*  69 */       String goods = saleGood.getGoods();
            /*  70 */       Petbeibao petbeibao = (Petbeibao)JSONUtils.parseObject(goods, Petbeibao.class);
            /*  71 */       Vo_12269_0 vo_12269_0 = new Vo_12269_0();
            /*  72 */       vo_12269_0.id = petbeibao.id;
            /*  73 */       vo_12269_0.owner_id = chara.id;
            /*  74 */       GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M12269_0(), vo_12269_0);
            /*  75 */       Vo_40964_0 vo_40964_11 = new Vo_40964_0();
            /*  76 */       vo_40964_11.type = 2;
            /*  77 */       vo_40964_11.name = "立正";
            /*  78 */       vo_40964_11.param = String.valueOf(((PetShuXing)petbeibao.petShuXing.get(0)).type);
            /*  79 */       vo_40964_11.rightNow = 0;
            /*  80 */       GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M40964_0(), vo_40964_11);
            /*  81 */       Vo_20481_0 vo_20481_0 = new Vo_20481_0();
            /*  82 */       vo_20481_0.msg = ("你成功将#R" + saleGood.getName() + "#n购买了");
            /*  83 */       vo_20481_0.time = ((int)(System.currentTimeMillis() / 1000L));
            /*  84 */       GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
            /*  85 */       List list = new java.util.ArrayList();
            /*  86 */       list.add(petbeibao);
            /*  87 */       petbeibao.id = GameUtil.getCard(chara);
            /*  88 */       GameObjectChar.send(new MSG_UPDATE_PETS(), list);
            /*  89 */       boolean isfagong = ((PetShuXing)petbeibao.petShuXing.get(0)).rank > ((PetShuXing)petbeibao.petShuXing.get(0)).pet_mag_shape;
            /*  90 */       GameUtil.dujineng(1, ((PetShuXing)petbeibao.petShuXing.get(0)).metal, ((PetShuXing)petbeibao.petShuXing.get(0)).skill, isfagong, petbeibao.id, chara);
            /*  91 */       chara.pets.add(petbeibao);
            /*  92 */       GameData.that.saleGoodService.deleteById(saleGood.getId().intValue());
            /*     */     }
        /*  94 */     Vo_33049_0 vo_33049_0 = new Vo_33049_0();
        /*  95 */     vo_33049_0.goods_gid = id;
        /*  96 */     vo_33049_0.type = 0;
        /*  97 */     vo_33049_0.result = 1;
        /*  98 */     vo_33049_0.tips = "";
        /*  99 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M33049_0(), vo_33049_0);
        /* 100 */     Vo_20481_0 vo_20481_0 = new Vo_20481_0();
        /* 101 */     vo_20481_0.msg = ("购买了#R" + saleGood.getName() + "#n。");
        /* 102 */     vo_20481_0.time = 1562987118;
        /* 103 */     GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
        /*     */
        /* 105 */     chara.balance -= price;
        /* 106 */     org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
        /* 107 */     GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
        /*     */
        /* 109 */     GameData.that.saleGoodService.deleteById(saleGood.getId().intValue());
        /*     */
        /* 111 */     String[] split = pageStr.split("\\;");
        /* 112 */     int pos1 = Integer.parseInt(split[0]);
        /* 113 */     int pos2 = Integer.parseInt(split[1]);
        /* 114 */     List<SaleGood> saleGoodList = GameData.that.saleGoodService.findByStr(key);
        /* 115 */     Vo_49183_0 vo_49183_0 = new Vo_49183_0();
        /* 116 */     vo_49183_0.totalPage = (saleGoodList.size() / 3);
        /* 117 */     vo_49183_0.cur_page = pos1;
        /* 118 */     int weizhi = (pos1 - 1) * 8;
        /* 119 */     int size = saleGoodList.size() - (pos1 - 1) * 8;
        /* 120 */     if (size > 8) {
            /* 121 */       size = 8;
            /*     */     }
        /* 123 */     for (int i = 0; i < size; i++) {
            /* 124 */       Vo_49183 vo_49183 = new Vo_49183();
            /* 125 */       vo_49183.name = ((SaleGood)saleGoodList.get(i + weizhi)).getName();
            /* 126 */       vo_49183.is_my_goods = 0;
            /* 127 */       vo_49183.id = ((SaleGood)saleGoodList.get(i + weizhi)).getGoodsId();
            /* 128 */       vo_49183.price = ((SaleGood)saleGoodList.get(i + weizhi)).getPrice().intValue();
            /* 129 */       vo_49183.status = 2;
            /* 130 */       vo_49183.startTime = ((SaleGood)saleGoodList.get(i + weizhi)).getStartTime().intValue();
            /* 131 */       vo_49183.endTime = ((SaleGood)saleGoodList.get(i + weizhi)).getEndTime().intValue();
            /* 132 */       vo_49183.level = ((SaleGood)saleGoodList.get(i + weizhi)).getLevel().intValue();
            /* 133 */       vo_49183.unidentified = (((SaleGood)saleGoodList.get(i + weizhi)).getLevel().intValue() > 0 ? 1 : 0);
            /* 134 */       if (((SaleGood)saleGoodList.get(i + weizhi)).getIspet().intValue() == 2) {
                /* 135 */         vo_49183.unidentified = 0;
                /*     */       }
            /* 137 */       vo_49183.amount = 1;
            /* 138 */       vo_49183.req_level = ((SaleGood)saleGoodList.get(i + weizhi)).getReqLevel().intValue();
            /* 139 */       vo_49183.extra = "\"{\"rank\":2,\"enchant\":0,\"mount_type\":0,\"rebuild_level\":1,\"eclosion\":0}\"";
            /* 140 */       vo_49183.item_polar = 0;
            /* 141 */       vo_49183_0.vo_49183s.add(vo_49183);
            /*     */     }
        /* 143 */     vo_49183_0.path_str = key;
        /* 144 */     vo_49183_0.select_gid = "";
        /* 145 */     vo_49183_0.sell_stage = 2;
        /* 146 */     vo_49183_0.sort_key = "price";
        /* 147 */     vo_49183_0.is_descending = 0;
        /* 148 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M49183_0(), vo_49183_0);
        /*     */
        /* 150 */     Characters characters = GameData.that.characterService.finOnByGiD(saleGood.getOwnerUuid());
        /* 151 */     Chara chara1 = (Chara)JSONUtils.parseObject(characters.getData(), Chara.class);
        /* 152 */     GameObjectChar session = org.linlinjava.litemall.gameserver.game.GameObjectCharMng.getGameObjectChar(chara1.id);
        /* 153 */     if (session != null) {
            /* 154 */       session.chara.jishou_coin += price;
            /*     */     } else {
            /* 156 */       chara1.jishou_coin += price;
            String data = characters.getData();
            Chara chara111 = JSONUtils.parseObject(data, Chara.class);
            if (chara111.level < chara1.level)
            {
                log.error("人物等级{old}",chara111.name,chara111.level);
                log.error("人物等级{new}",chara.name,chara.level);
                throw new RuntimeException("角色等级回档！！！");
            }
            /* 157 */       characters.setData(JSONUtils.toJSONString(chara1));
            /* 158 */       GameData.that.characterService.updateById(characters);
            /*     */     }
        /*     */   }
    /*     */
    /*     */   public int cmd()
    /*     */   {
        /* 164 */     return 12490;
        /*     */   }
    /*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C12490_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */