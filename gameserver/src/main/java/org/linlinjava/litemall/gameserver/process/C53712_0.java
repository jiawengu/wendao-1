/*     */ package org.linlinjava.litemall.gameserver.process;
/*     */ 
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import io.netty.channel.ChannelHandlerContext;
/*     */ import java.util.ArrayList;
/*     */ import java.util.List;
/*     */ import org.linlinjava.litemall.db.domain.PackModification;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_41505_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_4197_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61671_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61677_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.*;
/*     */
/*     */
import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ import org.linlinjava.litemall.gameserver.domain.Goods;
/*     */ import org.linlinjava.litemall.gameserver.game.GameData;
/*     */
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*     */ 
/*     */ @org.springframework.stereotype.Service
/*     */ public class C53712_0 implements org.linlinjava.litemall.gameserver.GameHandler
/*     */ {
/*     */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*     */   {
/*  27 */     String name = org.linlinjava.litemall.gameserver.data.GameReadTool.readString(buff);
/*     */     
/*  29 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*     */     
/*  31 */     PackModification packModification = GameData.that.basePackModificationService.findOneByAlias(name);
/*  32 */     chara.extra_life -= packModification.getGoodsPrice().intValue();
/*  33 */     org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
/*     */     
/*     */ 
/*  36 */     for (int i = 0; i < chara.backpack.size(); i++) {
/*  37 */       if (((Goods)chara.backpack.get(i)).pos == 37) {
/*  38 */         Goods goods = (Goods)chara.backpack.get(i);
/*  39 */         chara.backpack.remove(chara.backpack.get(i));
/*  40 */         Vo_61677_0 vo_61677_0 = new Vo_61677_0();
/*  41 */         vo_61677_0.store_type = "follow_pet_store";
/*  42 */         vo_61677_0.npcID = 0;
/*  43 */         vo_61677_0.list = chara.genchong;
/*  44 */         vo_61677_0.count = chara.genchong.size();
/*  45 */         GameObjectChar.send(new M61677_0(), vo_61677_0);
/*     */       }
/*     */     }
/*     */     
/*  49 */     Vo_4197_0 vo_4197_0 = new Vo_4197_0();
/*  50 */     vo_4197_0.id = 0;
/*  51 */     GameObjectChar.getGameObjectChar().gameMap.send(new org.linlinjava.litemall.gameserver.data.write.M4197_0(), vo_4197_0);
/*  52 */     GameObjectChar.getGameObjectChar().gameMap.send(new org.linlinjava.litemall.gameserver.data.write.M12285_1(), Integer.valueOf(chara.genchong_icon));
/*  53 */     Goods goods = new Goods();
/*  54 */     goods.goodsInfo.owner_id = 1;
/*  55 */     goods.goodsInfo.value = 2097924;
/*  56 */     goods.goodsInfo.quality = "金色";
/*  57 */     goods.goodsInfo.alias = name;
/*  58 */     goods.pos = packModification.getPosition().intValue();
/*  59 */     goods.goodsInfo.food_num = 0;
/*  60 */     goods.goodsInfo.master = chara.sex;
/*  61 */     goods.goodsInfo.recognize_recognized = 2;
/*  62 */     goods.goodsInfo.type = Integer.valueOf(packModification.getType()).intValue();
/*  63 */     goods.goodsInfo.total_score = 24;
/*  64 */     goods.goodsInfo.damage_sel_rate = 1842075;
/*  65 */     goods.goodsInfo.str = packModification.getStr();
/*  66 */     goods.goodsInfo.metal = chara.menpai;
/*  67 */     goods.goodsInfo.attrib = 0;
/*  68 */     goods.goodsInfo.durability = 8;
/*  69 */     goods.goodsInfo.rebuild_level = 0;
/*  70 */     goods.goodsInfo.auto_fight = ("5d65f0216e9552d52c521d59" + packModification.getPosition());
/*  71 */     chara.genchong.add(goods);
/*     */     
/*  73 */     chara.genchong_icon = Integer.valueOf(packModification.getFasionType()).intValue();
/*     */     
/*  75 */     Vo_65529_0 vo_65529_0 = new Vo_65529_0();
/*  76 */     vo_65529_0.id = Integer.valueOf(packModification.getFasionType()).intValue();
/*  77 */     vo_65529_0.x = chara.x;
/*  78 */     vo_65529_0.y = chara.y;
/*  79 */     vo_65529_0.dir = 5;
/*  80 */     vo_65529_0.icon = Integer.valueOf(packModification.getFasionType()).intValue();
/*  81 */     vo_65529_0.type = 32768;
/*  82 */     vo_65529_0.sub_type = 2;
/*  83 */     vo_65529_0.owner_id = chara.id;
/*  84 */     vo_65529_0.name = packModification.getStr();
/*  85 */     vo_65529_0.org_icon = Integer.valueOf(packModification.getFasionType()).intValue();
/*  86 */     vo_65529_0.portrait = Integer.valueOf(packModification.getFasionType()).intValue();
/*  87 */     GameObjectChar.getGameObjectChar().gameMap.send(new MSG_APPEAR(), vo_65529_0);
/*     */     
/*     */ 
/*     */ 
/*  91 */     Vo_61677_0 vo_61677_0 = new Vo_61677_0();
/*  92 */     vo_61677_0.store_type = "follow_pet_store";
/*  93 */     vo_61677_0.npcID = 0;
/*  94 */     vo_61677_0.list = chara.genchong;
/*  95 */     vo_61677_0.count = chara.genchong.size();
/*  96 */     GameObjectChar.send(new M61677_0(), vo_61677_0);
/*     */     
/*     */ 
/*  99 */     Vo_61677_0 vo_61677_12 = new Vo_61677_0();
/* 100 */     vo_61677_12.store_type = "follow_pet_store";
/* 101 */     vo_61677_12.npcID = 0;
/* 102 */     vo_61677_12.count = 1;
/* 103 */     vo_61677_12.isGoon = 0;
/* 104 */     vo_61677_12.pos = packModification.getPosition().intValue();
/* 105 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M61677_01(), vo_61677_12);
/*     */     
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/* 113 */     goods = new Goods();
/* 114 */     goods.goodsInfo.owner_id = 1;
/* 115 */     goods.goodsInfo.value = 3844;
/* 116 */     goods.goodsInfo.quality = "金色";
/* 117 */     goods.goodsInfo.alias = packModification.getStr();
/* 118 */     goods.pos = 37;
/* 119 */     goods.goodsInfo.food_num = 0;
/* 120 */     goods.goodsInfo.merge_rate = 0;
/* 121 */     goods.goodsInfo.master = 0;
/* 122 */     goods.goodsInfo.recognize_recognized = 2;
/* 123 */     goods.goodsInfo.type = Integer.valueOf(packModification.getType()).intValue();
/* 124 */     goods.goodsInfo.total_score = 24;
/* 125 */     goods.goodsInfo.damage_sel_rate = 809382;
/* 126 */     goods.goodsInfo.str = packModification.getStr();
/* 127 */     goods.goodsInfo.metal = 0;
/* 128 */     goods.goodsInfo.durability = 8;
/* 129 */     goods.goodsInfo.attrib = 0;
/* 130 */     goods.goodsInfo.rebuild_level = 0;
/* 131 */     goods.goodsInfo.auto_fight = ("5d65f0216e9552d52c521d59" + packModification.getPosition());
/* 132 */     chara.backpack.add(goods);
/* 133 */     List<Goods> list = new ArrayList();
/* 134 */     list.add(goods);
/* 135 */     GameObjectChar.send(new MSG_INVENTORY(), list);
/*     */     
/*     */ 
/*     */ 
/* 139 */     Vo_20481_0 vo_20481_0 = new Vo_20481_0();
/* 140 */     vo_20481_0.msg = "购买成功。";
/* 141 */     vo_20481_0.time = 1562987118;
/* 142 */     GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
/*     */     
/* 144 */     Vo_61671_0 vo_61671_0 = new Vo_61671_0();
/* 145 */     vo_61671_0.id = chara.id;
/* 146 */     vo_61671_0.count = 0;
/* 147 */     GameObjectChar.send(new MSG_TITLE(), vo_61671_0);
/* 148 */     Vo_41505_0 vo_41505_0 = new Vo_41505_0();
/* 149 */     vo_41505_0.type = "view_follow_pet";
/* 150 */     GameObjectChar.send(new M41505_0(), vo_41505_0);
/*     */   }
/*     */   
/*     */ 
/*     */ 
/*     */   public int cmd()
/*     */   {
/* 157 */     return 53712;
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C53712_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */