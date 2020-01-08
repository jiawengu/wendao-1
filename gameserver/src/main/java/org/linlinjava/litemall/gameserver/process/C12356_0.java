/*     */ package org.linlinjava.litemall.gameserver.process;
/*     */ 
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import io.netty.channel.ChannelHandlerContext;
/*     */ import java.util.ArrayList;
/*     */ import java.util.List;
/*     */ import org.linlinjava.litemall.db.domain.GroceriesShop;
/*     */ import org.linlinjava.litemall.db.domain.MedicineShop;
/*     */ import org.linlinjava.litemall.db.domain.StoreInfo;
/*     */
/*     */
/*     */
/*     */ import org.linlinjava.litemall.gameserver.GameHandler;
/*     */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20480_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_40964_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M20480_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M40964_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_INVENTORY;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE;
/*     */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ import org.linlinjava.litemall.gameserver.domain.Goods;
/*     */ import org.linlinjava.litemall.gameserver.domain.GoodsInfo;
/*     */ import org.linlinjava.litemall.gameserver.domain.GoodsLanSe;
/*     */ import org.linlinjava.litemall.gameserver.game.GameData;
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*     */ import org.springframework.stereotype.Service;
/*     */ 
/*     */ @Service
/*     */ public class C12356_0 implements GameHandler
/*     */ {
/*     */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*     */   {
/*  35 */     int shipper = GameReadTool.readInt(buff);
/*     */     
/*  37 */     int pos = GameReadTool.readShort(buff);
/*     */     
/*  39 */     int amount = GameReadTool.readShort(buff);
/*     */     
/*  41 */     int to_pos = GameReadTool.readShort(buff);
/*     */     
/*  43 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*     */     
/*  45 */     if (shipper == 15908) {
/*  46 */       GroceriesShop groceriesShop = GameData.that.baseGroceriesShopService.findOneByGoodsNo(Integer.valueOf(pos));
/*     */       
/*     */ 
/*  49 */       StoreInfo storeInfo = GameData.that.baseStoreInfoService.findOneByName(groceriesShop.getName());
/*  50 */       if (pos < 2) {
/*  51 */         GameUtil.huodedaoju(chara, storeInfo, amount);
/*     */       } else {
/*  53 */         List<Goods> list = new ArrayList();
/*  54 */         Goods goods = new Goods();
/*  55 */         goods.pos = GameUtil.beibaoweizhi(chara);
/*  56 */         goods.goodsInfo = new GoodsInfo();
/*     */         
/*     */ 
/*  59 */         goods.goodsDaoju(storeInfo);
/*  60 */         goods.goodsInfo.degree_32 = 0;
/*  61 */         goods.goodsInfo.skill = 3;
/*  62 */         goods.goodsInfo.owner_id = amount;
/*  63 */         goods.goodsInfo.damage_sel_rate = 400976;
/*  64 */         goods.goodsInfo.silver_coin = 6000;
/*  65 */         goods.goodsInfo.degree_32 = 1;
/*     */         
/*  67 */         goods.goodsLanSe = new GoodsLanSe();
/*  68 */         if (pos == 2) {
/*  69 */           goods.goodsLanSe.wiz = 270;
/*     */         }
/*  71 */         if (pos == 3) {
/*  72 */           goods.goodsLanSe.accurate = 594;
/*     */         }
/*  74 */         if (pos == 4) {
/*  75 */           goods.goodsLanSe.mana = 392;
/*     */         }
/*  77 */         if (pos == 5) {
/*  78 */           goods.goodsLanSe.def = 900;
/*     */         }
/*  80 */         if (pos == 6) {
/*  81 */           goods.goodsLanSe.parry = 96;
/*     */         }
/*  83 */         if (pos == 7) {
/*  84 */           goods.goodsLanSe.dex = 594;
/*     */         }
/*  86 */         GameUtil.addwupin(goods, chara);
/*     */         
/*     */ 
/*  89 */         GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
/*     */       }
/*     */       
/*  92 */       Vo_20480_0 vo_20480_0 = new Vo_20480_0();
/*  93 */       vo_20480_0.msg = ("你购买了" + storeInfo.getName() + "#n");
/*  94 */       vo_20480_0.time = 1562593376;
/*  95 */       GameObjectChar.send(new M20480_0(), vo_20480_0);
/*  96 */       Vo_40964_0 vo_40964_0 = new Vo_40964_0();
/*  97 */       vo_40964_0.type = 1;
/*  98 */       vo_40964_0.name = storeInfo.getName();
/*  99 */       vo_40964_0.param = "-1";
/* 100 */       vo_40964_0.rightNow = 0;
/* 101 */       GameObjectChar.send(new M40964_0(), vo_40964_0);
/* 102 */       if (chara.lock_exp == 0) {
/* 103 */         chara.balance -= storeInfo.getRebuildLevel().intValue();
/*     */       } else {
/* 105 */         chara.use_money_type -= storeInfo.getRebuildLevel().intValue();
/*     */       }
/* 107 */       ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
/* 108 */       GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
/*     */     }
/* 110 */     if (shipper == 15907) {
/* 111 */       MedicineShop medicineShop = GameData.that.baseMedicineShopService.findOneByGoodsNo(Integer.valueOf(pos));
/*     */       
/*     */ 
/* 114 */       StoreInfo storeInfo = GameData.that.baseStoreInfoService.findOneByName(medicineShop.getName());
/* 115 */       GameUtil.huodedaoju(chara, storeInfo, amount);
/* 116 */       Vo_20480_0 vo_20480_0 = new Vo_20480_0();
/* 117 */       vo_20480_0.msg = ("你购买了" + storeInfo.getName() + "#n");
/* 118 */       vo_20480_0.time = 1562593376;
/* 119 */       GameObjectChar.send(new M20480_0(), vo_20480_0);
/* 120 */       Vo_40964_0 vo_40964_0 = new Vo_40964_0();
/* 121 */       vo_40964_0.type = 1;
/* 122 */       vo_40964_0.name = storeInfo.getName();
/* 123 */       vo_40964_0.param = "-1";
/* 124 */       vo_40964_0.rightNow = 0;
/* 125 */       GameObjectChar.send(new M40964_0(), vo_40964_0);
/*     */       
/* 127 */       if (chara.lock_exp == 0) {
/* 128 */         chara.balance -= storeInfo.getRebuildLevel().intValue();
/*     */       } else {
/* 130 */         chara.use_money_type -= storeInfo.getRebuildLevel().intValue();
/*     */       }
/* 132 */       ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
/* 133 */       GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
/*     */     }
/*     */   }
/*     */   
/*     */ 
/*     */ 
/*     */   public int cmd()
/*     */   {
/* 141 */     return 12356;
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C12356_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */