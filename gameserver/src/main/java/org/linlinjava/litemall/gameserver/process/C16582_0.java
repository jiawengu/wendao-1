/*     */ package org.linlinjava.litemall.gameserver.process;
/*     */
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import io.netty.channel.ChannelHandlerContext;
/*     */
/*     */ import java.util.List;
/*     */ import org.linlinjava.litemall.db.domain.SaleClassifyGood;
/*     */ import org.linlinjava.litemall.db.domain.SaleGood;
/*     */
/*     */
/*     */ import org.linlinjava.litemall.db.util.JSONUtils;
/*     */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_12269_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20480_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M20480_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M8165_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE;
import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ import org.linlinjava.litemall.gameserver.domain.Goods;
/*     */
/*     */ import org.linlinjava.litemall.gameserver.domain.PetShuXing;
/*     */ import org.linlinjava.litemall.gameserver.domain.Petbeibao;
/*     */ import org.linlinjava.litemall.gameserver.game.GameData;
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*     */
/*     */ @org.springframework.stereotype.Service
/*     */ public class C16582_0 implements org.linlinjava.litemall.gameserver.GameHandler
        /*     */ {
    /*     */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
    /*     */   {
        /*  31 */     int inventoryPos = GameReadTool.readInt(buff);
        /*     */
        /*  33 */     int price = GameReadTool.readInt(buff);
        /*     */
        /*  35 */     int pos = GameReadTool.readShort(buff);
        /*     */
        /*     */
        /*  38 */     int type = GameReadTool.readShort(buff);
        /*     */
        /*  40 */     int amount = GameReadTool.readShort(buff);
        /*     */
        /*  42 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
        /*  43 */     String str = null;
        /*  44 */     int coin = price / 100;
        /*     */     if(coin<0) {return;}
        /*     */ 	  if(price<0) {return;}
        if(price>2000000000) {return;}
        /*  47 */     if (type == 1) {
            /*  48 */       for (int i = 0; i < chara.backpack.size(); i++) {
                /*  49 */         if (((Goods)chara.backpack.get(i)).pos == inventoryPos) {
                    /*  50 */           Goods goods = (Goods)chara.backpack.get(i);
                    /*  51 */           SaleClassifyGood saleClassifyGood = GameData.that.baseSaleClassifyGoodService.findOneByStr(goods.goodsInfo.str);
                    /*  52 */           if (goods.goodsInfo.str.contains("超级黑水晶·")) {
                        /*  53 */             List<SaleClassifyGood> classifyGoodList = GameData.that.baseSaleClassifyGoodService.findByStr(goods.goodsInfo.str);
                        /*  54 */             for (int j = 0; j < classifyGoodList.size(); j++) {
                            /*  55 */               if ((Integer.valueOf(((SaleClassifyGood)classifyGoodList.get(j)).getAttrib()).intValue() == goods.goodsInfo.attrib) && (Integer.valueOf(((SaleClassifyGood)classifyGoodList.get(j)).getCname()).intValue() == goods.goodsInfo.add_pet_exp)) {
                                /*  56 */                 saleClassifyGood = (SaleClassifyGood)classifyGoodList.get(j);
                                /*     */               }
                            /*     */             }
                        /*     */           }
                    /*  60 */           if (saleClassifyGood == null) {
                        /*  61 */             //System.out.println(goods.goodsInfo.str);
                        /*  62 */             return;
                        /*     */           }
                    /*  64 */           SaleGood saleGood = new SaleGood();
                    /*  65 */           str = saleClassifyGood.getCompose();
                    /*  66 */           if ((saleClassifyGood.getPname().equals("低级首饰")) || (goods.goodsInfo.degree_32 == 1)) {
                        /*  67 */             if (coin < 1000) {
                            /*  68 */               coin = 1000;
                            /*     */             }
                        /*  70 */             if (goods.goodsInfo.degree_32 == 1) {
                            /*  71 */               str = "未鉴定" + saleClassifyGood.getCompose();
                            /*  72 */               saleGood.setLevel(Integer.valueOf(256));
                            /*     */             }
                        /*     */           }
                    /*  75 */           else if (coin < 100000) {
                        /*  76 */             coin = 100000;
                        /*     */           }
                    /*     */
                    /*  79 */           chara.balance -= coin;
                    /*  80 */           org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
                    /*  81 */           GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
                    /*     */
                    /*  83 */           GameUtil.removemunber(chara, (Goods)chara.backpack.get(i), 1);
                    /*  84 */           Vo_20480_0 vo_20480_0 = new Vo_20480_0();
                    /*  85 */           vo_20480_0.msg = "摆摊成功";
                    /*  86 */           vo_20480_0.time = ((int)System.currentTimeMillis() / 1000);
                    /*  87 */           GameObjectChar.send(new M20480_0(), vo_20480_0);
                    /*  88 */           Vo_8165_0 vo_8165_0 = new Vo_8165_0();
                    /*  89 */           vo_8165_0.msg = ("花费了摊位费" + coin + "#n文钱#n");
                    /*  90 */           vo_8165_0.active = 0;
                    /*  91 */           GameObjectChar.send(new M8165_0(), vo_8165_0);
                    /*     */
                    /*     */
                    /*  94 */           int time = (int)(System.currentTimeMillis() / 1000L);
                    /*  95 */           saleGood.setStartTime(Integer.valueOf(time));
                    /*  96 */           saleGood.setEndTime(Integer.valueOf(time - 604800));
                    /*  97 */           saleGood.setGoodsId(goods.goodsInfo.auto_fight);
                    /*  98 */           saleGood.setName(goods.goodsInfo.str);
                    /*  99 */           saleGood.setPrice(Integer.valueOf(price));
                    /* 100 */           saleGood.setReqLevel(Integer.valueOf(goods.goodsInfo.attrib));
                    /* 101 */           saleGood.setOwnerUuid(chara.uuid);
                    /* 102 */           saleGood.setStr(str);
                    /* 103 */           saleGood.setIspet(Integer.valueOf(1));
                    /* 104 */           saleGood.setGoods(JSONUtils.toJSONString(goods));
                    /* 105 */           GameData.that.baseSaleGoodService.add(saleGood);
                    /*     */         }
                /*     */       }
            /*     */     }
        /*     */
        /* 110 */     if (type == 2) {
            /* 111 */       if (coin < 100000) {
                /* 112 */         coin = 100000;
                /*     */       }
            if(chara.balance<coin) {return;}
            chara.balance -= coin;
            /* 115 */       org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
            /* 116 */       for (int i = 0; i < chara.pets.size(); i++) {
                /* 117 */         if (((Petbeibao)chara.pets.get(i)).id == inventoryPos) {
                    /* 118 */           Petbeibao pet = (Petbeibao)chara.pets.get(i);
                    /* 119 */           SaleClassifyGood saleClassifyGood = GameData.that.baseSaleClassifyGoodService.findOneByStr(((PetShuXing)pet.petShuXing.get(0)).str);
                    if (saleClassifyGood == null) {
                        /* 121 */             System.out.println(((PetShuXing)pet.petShuXing.get(0)).type);
                        /* 122 */             return;
                        /*     */           }
                    /* 124 */           Vo_12269_0 vo_12269_0 = new Vo_12269_0();
                    /* 125 */           vo_12269_0.id = pet.id;
                    /* 126 */           vo_12269_0.owner_id = 0;
                    /* 127 */           GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M12269_0(), vo_12269_0);
                    /*     */
                    /* 129 */           str = saleClassifyGood.getCompose();
                    /* 130 */           Vo_20480_0 vo_20480_0 = new Vo_20480_0();
                    /* 131 */           vo_20480_0.msg = "摆摊成功";
                    /* 132 */           vo_20480_0.time = ((int)System.currentTimeMillis() / 1000);
                    /* 133 */           GameObjectChar.send(new M20480_0(), vo_20480_0);
                    /* 134 */           Vo_8165_0 vo_8165_0 = new Vo_8165_0();
                    /* 135 */           vo_8165_0.msg = ("花费了摊位费" + coin + "#n文钱#n");
                    /* 136 */           vo_8165_0.active = 0;
                    /* 137 */           GameObjectChar.send(new M8165_0(), vo_8165_0);
                    /* 138 */           SaleGood saleGood = new SaleGood();
                    /* 139 */           int time = (int)(System.currentTimeMillis() / 1000L);
                    /* 140 */           saleGood.setStartTime(Integer.valueOf(time));
                    /* 141 */           saleGood.setEndTime(Integer.valueOf(time - 604800));
                    /* 142 */           saleGood.setGoodsId(((PetShuXing)pet.petShuXing.get(0)).auto_fight);
                    /* 143 */           saleGood.setName(saleClassifyGood.getStr());
                    /* 144 */           saleGood.setPrice(Integer.valueOf(price));
                    /* 145 */           saleGood.setReqLevel(Integer.valueOf(((PetShuXing)pet.petShuXing.get(0)).skill));
                    /* 146 */           saleGood.setOwnerUuid(chara.uuid);
                    /* 147 */           saleGood.setStr(str);
                    /* 148 */           saleGood.setGoods(JSONUtils.toJSONString(pet));
                    /* 149 */           saleGood.setIspet(Integer.valueOf(2));
                    /* 150 */           GameData.that.baseSaleGoodService.add(saleGood);
                    /* 151 */           chara.pets.remove(pet);
                    /*     */         }
                /*     */       }
            /*     */     }
        /*     */
        /*     */
        /* 157 */     List<SaleGood> saleGoodList = GameData.that.saleGoodService.findByOwnerUuid(chara.uuid);
        /*     */
        /* 159 */     org.linlinjava.litemall.gameserver.data.vo.Vo_49179_0 vo_49179_0 = GameUtil.a49179(saleGoodList, chara);
        /* 160 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M49179_0(), vo_49179_0);
        /*     */   }
    /*     */
    /*     */   public int cmd()
    /*     */   {
        /* 165 */     return 16582;
        /*     */   }
    /*     */ }
