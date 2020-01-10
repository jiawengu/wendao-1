/*     */ package org.linlinjava.litemall.gameserver.process;
/*     */ 
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import io.netty.channel.ChannelHandlerContext;
/*     */ import java.util.ArrayList;
/*     */ import java.util.List;
/*     */ import org.linlinjava.litemall.db.domain.PackModification;
/*     */ import org.linlinjava.litemall.gameserver.GameHandler;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_41505_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_45608_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61671_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61677_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.*;
/*     */
/*     */
/*     */
import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ import org.linlinjava.litemall.gameserver.domain.Goods;
/*     */ import org.linlinjava.litemall.gameserver.game.GameData;
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*     */ import org.springframework.stereotype.Service;
/*     */ 
/*     */ @Service
/*     */ public class C45606_0 implements GameHandler
/*     */ {
/*     */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*     */   {
/*  28 */     String item_name = org.linlinjava.litemall.gameserver.data.GameReadTool.readString(buff);
/*     */     
/*  30 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*  31 */     for (int i = 0; i < chara.backpack.size(); i++) {
/*  32 */       if (((Goods)chara.backpack.get(i)).pos == 32) {
/*  33 */         Goods goods = (Goods)chara.backpack.get(i);
/*     */         
/*  35 */         chara.backpack.remove(chara.backpack.get(i));
/*  36 */         Vo_61677_0 vo_61677_0 = new Vo_61677_0();
/*  37 */         vo_61677_0.store_type = "effect_store";
/*  38 */         vo_61677_0.npcID = 0;
/*  39 */         vo_61677_0.list = chara.texiao;
/*  40 */         vo_61677_0.count = chara.texiao.size();
/*  41 */         GameObjectChar.send(new M61677_0(), vo_61677_0);
/*     */       }
/*     */     }
/*     */     
/*  45 */     PackModification packModification = GameData.that.basePackModificationService.findOneByAlias(item_name);
/*     */     
/*  47 */     chara.texiao_icon = Integer.valueOf(packModification.getFasionType()).intValue();
/*  48 */     chara.extra_life -= packModification.getGoodsPrice().intValue();
/*  49 */     org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
/*  50 */     Goods goods = new Goods();
/*  51 */     goods.goodsInfo.owner_id = 1;
/*  52 */     goods.goodsInfo.value = 2097924;
/*  53 */     goods.goodsInfo.quality = "金色";
/*  54 */     goods.goodsInfo.alias = item_name;
/*  55 */     goods.goodsInfo.amount = 17;
/*  56 */     goods.pos = packModification.getPosition().intValue();
/*  57 */     goods.goodsInfo.food_num = 0;
/*  58 */     goods.goodsInfo.master = chara.sex;
/*  59 */     goods.goodsInfo.recognize_recognized = 2;
/*  60 */     goods.goodsInfo.type = Integer.valueOf(packModification.getType()).intValue();
/*  61 */     goods.goodsInfo.total_score = 25;
/*  62 */     goods.goodsInfo.damage_sel_rate = 1842075;
/*  63 */     goods.goodsInfo.str = packModification.getStr();
/*  64 */     goods.goodsInfo.metal = chara.menpai;
/*  65 */     goods.goodsInfo.attrib = 0;
/*  66 */     goods.goodsInfo.durability = 8;
/*  67 */     goods.goodsInfo.rebuild_level = 0;
/*  68 */     goods.goodsInfo.auto_fight = ("5d65f0216e9552d52c521d59" + packModification.getPosition());
/*  69 */     chara.texiao.add(goods);
/*     */     
/*     */ 
/*  72 */     Vo_61677_0 vo_61677_0 = new Vo_61677_0();
/*  73 */     vo_61677_0.store_type = "effect_store";
/*  74 */     vo_61677_0.npcID = 0;
/*  75 */     vo_61677_0.list = chara.texiao;
/*  76 */     vo_61677_0.count = chara.texiao.size();
/*  77 */     GameObjectChar.send(new M61677_0(), vo_61677_0);
/*     */     
/*  79 */     Vo_61677_0 vo_61677_12 = new Vo_61677_0();
/*  80 */     vo_61677_12.store_type = "effect_store";
/*  81 */     vo_61677_12.npcID = 0;
/*  82 */     vo_61677_12.count = 1;
/*  83 */     vo_61677_12.isGoon = 0;
/*  84 */     vo_61677_12.pos = packModification.getPosition().intValue();
/*  85 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M61677_01(), vo_61677_12);
/*     */     
/*  87 */     goods = new Goods();
/*  88 */     goods.goodsInfo.owner_id = 1;
/*  89 */     goods.goodsInfo.value = 262;
/*  90 */     goods.goodsInfo.quality = "金色";
/*  91 */     goods.goodsInfo.alias = packModification.getStr();
/*  92 */     goods.goodsInfo.amount = 17;
/*  93 */     goods.pos = 32;
/*  94 */     goods.goodsInfo.food_num = 0;
/*  95 */     goods.goodsInfo.merge_rate = 0;
/*  96 */     goods.goodsInfo.master = 0;
/*  97 */     goods.goodsInfo.recognize_recognized = 2;
/*  98 */     goods.goodsInfo.type = Integer.valueOf(packModification.getType()).intValue();
/*  99 */     goods.goodsInfo.total_score = 23;
/* 100 */     goods.goodsInfo.damage_sel_rate = 809382;
/* 101 */     goods.goodsInfo.str = packModification.getStr();
/* 102 */     goods.goodsInfo.metal = 0;
/* 103 */     goods.goodsInfo.durability = 8;
/* 104 */     goods.goodsInfo.attrib = 0;
/* 105 */     goods.goodsInfo.rebuild_level = 0;
/* 106 */     goods.goodsInfo.auto_fight = ("5d65f0216e9552d52c521d59" + packModification.getPosition());
/* 107 */     chara.backpack.add(goods);
/* 108 */     List<Goods> list = new ArrayList();
/* 109 */     list.add(goods);
/* 110 */     GameObjectChar.send(new MSG_INVENTORY(), list);
/*     */     
/*     */ 
/* 113 */     org.linlinjava.litemall.gameserver.data.vo.Vo_61661_0 vo_61661_0 = GameUtil.MSG_UPDATE_APPEARANCE(chara);
/* 114 */     GameObjectChar.getGameObjectChar().gameMap.send(new MSG_UPDATE_APPEARANCE(), vo_61661_0);
/*     */     
/* 116 */     vo_61661_0 = GameUtil.MSG_UPDATE_APPEARANCE(chara);
/* 117 */     GameObjectChar.send(new MSG_UPDATE_APPEARANCE(), vo_61661_0);
/*     */     
/* 119 */     Vo_61671_0 vo_61671_0 = new Vo_61671_0();
/* 120 */     vo_61671_0.id = chara.id;
/* 121 */     vo_61671_0.count = 0;
/* 122 */     GameObjectChar.send(new MSG_TITLE(), vo_61671_0);
/*     */     
/*     */ 
/* 125 */     Vo_20481_0 vo_20481_0 = new Vo_20481_0();
/* 126 */     vo_20481_0.msg = ("你花费了 " + packModification.getGoodsPrice() + "个金元宝购买了#Y" + item_name + "#n。");
/* 127 */     vo_20481_0.time = 1562987118;
/* 128 */     GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
/*     */     
/*     */ 
/* 131 */     Vo_45608_0 vo_45608_0 = new Vo_45608_0();
/* 132 */     vo_45608_0.count = 13;
/* 133 */     vo_45608_0.name0 = "浪漫玫瑰";
/* 134 */     vo_45608_0.goods_price0 = 0;
/* 135 */     vo_45608_0.name1 = "星汉灿烂·永久";
/* 136 */     vo_45608_0.goods_price1 = 10888;
/* 137 */     vo_45608_0.name2 = "风花雪月·永久";
/* 138 */     vo_45608_0.goods_price2 = 10888;
/* 139 */     vo_45608_0.name3 = "轻羽飞扬·永久";
/* 140 */     vo_45608_0.goods_price3 = 8888;
/* 141 */     vo_45608_0.name4 = "繁花盛开·永久";
/* 142 */     vo_45608_0.goods_price4 = 6888;
/* 143 */     vo_45608_0.name5 = "踏雪无痕·永久";
/* 144 */     vo_45608_0.goods_price5 = 8888;
/* 145 */     vo_45608_0.name6 = "雨过天晴·永久";
/* 146 */     vo_45608_0.goods_price6 = 8888;
/* 147 */     vo_45608_0.name7 = "翩翩起舞";
/* 148 */     vo_45608_0.goods_price7 = 20888;
/* 149 */     vo_45608_0.name8 = "蝶影翩翩·永久";
/* 150 */     vo_45608_0.goods_price8 = 6888;
/* 151 */     vo_45608_0.name9 = "多彩泡泡";
/* 152 */     vo_45608_0.goods_price9 = 20888;
/* 153 */     vo_45608_0.name10 = "步步生莲·永久";
/* 154 */     vo_45608_0.goods_price10 = 6888;
/* 155 */     vo_45608_0.name11 = "星影特效";
/* 156 */     vo_45608_0.goods_price11 = 20888;
/* 157 */     vo_45608_0.name12 = "鸾凤宝玉";
/* 158 */     vo_45608_0.goods_price12 = 20888;
/* 159 */     vo_45608_0.count1 = 0;
/* 160 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M45608_0(), vo_45608_0);
/*     */     
/* 162 */     Vo_41505_0 vo_41505_0 = new Vo_41505_0();
/* 163 */     vo_41505_0.type = "equip_fasion";
/* 164 */     GameObjectChar.send(new M41505_0(), vo_41505_0);
/*     */   }
/*     */   
/*     */ 
/*     */ 
/*     */   public int cmd()
/*     */   {
/* 171 */     return 45606;
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C45606_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */