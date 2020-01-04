/*     */ package org.linlinjava.litemall.gameserver.process;
/*     */ 
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import io.netty.channel.ChannelHandlerContext;
/*     */
/*     */ import org.linlinjava.litemall.db.domain.PackModification;
/*     */
/*     */ import org.linlinjava.litemall.gameserver.GameHandler;
/*     */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_41505_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61677_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_NOTIFY_MISC_EX;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M41505_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M61677_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M61677_01;
/*     */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ import org.linlinjava.litemall.gameserver.domain.Goods;
/*     */
/*     */ import org.linlinjava.litemall.gameserver.game.GameData;
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*     */ import org.springframework.stereotype.Service;
/*     */ 
/*     */ @Service
/*     */ public class C33318_0 implements GameHandler
/*     */ {
/*     */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*     */   {
/*  30 */     int is_buy = GameReadTool.readByte(buff);
/*     */     
/*  32 */     String item_names = GameReadTool.readString(buff);
/*     */     
/*     */ 
/*  35 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*     */     
/*     */ 
/*  38 */     PackModification packModification = GameData.that.basePackModificationService.findOneByAlias(item_names);
/*     */     
/*     */ 
/*  41 */     chara.extra_life -= packModification.getGoodsPrice().intValue();
/*  42 */     ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
/*     */     
/*  44 */     Goods goods = new Goods();
/*  45 */     goods.goodsInfo.owner_id = 1;
/*  46 */     goods.goodsInfo.value = 2097924;
/*  47 */     goods.goodsInfo.quality = "金色";
/*  48 */     goods.goodsInfo.alias = item_names;
/*  49 */     goods.goodsInfo.amount = 16;
/*  50 */     goods.pos = packModification.getPosition().intValue();
/*  51 */     goods.goodsInfo.food_num = 2;
/*  52 */     goods.goodsInfo.master = chara.sex;
/*  53 */     goods.goodsInfo.recognize_recognized = 0;
/*  54 */     goods.goodsInfo.type = Integer.valueOf(packModification.getType()).intValue();
/*  55 */     goods.goodsInfo.total_score = 25;
/*  56 */     goods.goodsInfo.damage_sel_rate = 1842075;
/*  57 */     goods.goodsInfo.str = packModification.getStr();
/*  58 */     goods.goodsInfo.metal = chara.menpai;
/*  59 */     goods.goodsInfo.durability = 8;
/*  60 */     goods.goodsInfo.rebuild_level = 500;
/*  61 */     goods.goodsInfo.auto_fight = "5d65f0216e9552d52c521d59";
/*  62 */     chara.shizhuang.add(goods);
/*     */     
/*     */ 
/*     */ 
/*  66 */     Vo_61677_0 vo_61677_0 = new Vo_61677_0();
/*  67 */     vo_61677_0.store_type = "fasion_store";
/*  68 */     vo_61677_0.npcID = 0;
/*  69 */     vo_61677_0.list = chara.shizhuang;
/*  70 */     vo_61677_0.count = chara.shizhuang.size();
/*  71 */     GameObjectChar.send(new M61677_0(), vo_61677_0);
/*     */     
/*     */ 
/*  74 */     Vo_20481_0 vo_20481_0 = new Vo_20481_0();
/*  75 */     vo_20481_0.msg = ("你花费了" + packModification.getGoodsPrice() + "#n个金元宝购买了#Y" + item_names + "#n。");
/*  76 */     vo_20481_0.time = ((int)(System.currentTimeMillis() / 1000L));
/*  77 */     GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
/*     */     
/*     */ 
/*  80 */     Vo_41505_0 vo_41505_0 = new Vo_41505_0();
/*  81 */     vo_41505_0.type = "equip_fasion";
/*  82 */     GameObjectChar.send(new M41505_0(), vo_41505_0);
/*     */     
/*  84 */     for (int i = 0; i < chara.backpack.size(); i++) {
/*  85 */       if (((Goods)chara.backpack.get(i)).pos == 31) {
/*  86 */         packModification = GameData.that.basePackModificationService.findOneByStr(((Goods)chara.backpack.get(i)).goodsInfo.str);
/*  87 */         Vo_61677_0 vo_61677_12 = new Vo_61677_0();
/*  88 */         vo_61677_12.store_type = "fasion_store";
/*  89 */         vo_61677_12.npcID = 0;
/*  90 */         vo_61677_12.count = 1;
/*  91 */         vo_61677_12.isGoon = 0;
/*  92 */         vo_61677_12.pos = packModification.getPosition().intValue();
/*  93 */         GameObjectChar.send(new M61677_01(), vo_61677_12);
/*     */       }
/*     */     }
/*     */   }
/*     */   
/*     */ 
/*     */ 
/*     */ 
/*     */   public int cmd()
/*     */   {
/* 103 */     return 33318;
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C33318_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */