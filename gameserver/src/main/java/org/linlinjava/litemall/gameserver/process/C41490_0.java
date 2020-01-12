/*     */ package org.linlinjava.litemall.gameserver.process;
/*     */ 
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import io.netty.channel.ChannelHandlerContext;
/*     */ import java.util.ArrayList;
/*     */ import java.util.List;
/*     */ import org.linlinjava.litemall.db.domain.PackModification;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_41505_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61671_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61677_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.*;
/*     */
/*     */
/*     */
import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ import org.linlinjava.litemall.gameserver.domain.Goods;
/*     */ import org.linlinjava.litemall.gameserver.game.GameData;
/*     */
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*     */ 
/*     */ @org.springframework.stereotype.Service
/*     */ public class C41490_0 implements org.linlinjava.litemall.gameserver.GameHandler
            {
       public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*     */   {
/*  27 */     String equip_str = org.linlinjava.litemall.gameserver.data.GameReadTool.readString(buff);
/*     */     
/*  29 */     PackModification packModification = GameData.that.basePackModificationService.findOneByStr(equip_str);
/*  30 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*     */     
/*     */ 
/*  33 */     if (packModification.getCategory().intValue() == 1) {
/*  34 */       for (int i = 0; i < chara.backpack.size(); i++) {
/*  35 */         if (((Goods)chara.backpack.get(i)).pos == 31) {
/*  36 */           Goods goods = (Goods)chara.backpack.get(i);
/*     */           
/*  38 */           chara.backpack.remove(chara.backpack.get(i));
/*  39 */           Vo_61677_0 vo_61677_0 = new Vo_61677_0();
/*  40 */           vo_61677_0.store_type = "fasion_store";
/*  41 */           vo_61677_0.npcID = 0;
/*  42 */           vo_61677_0.list = chara.shizhuang;
/*  43 */           vo_61677_0.count = chara.shizhuang.size();
/*  44 */           GameObjectChar.send(new M61677_0(), vo_61677_0);
/*     */         }
/*     */       }
/*     */       
/*  48 */       Goods goods = new Goods();
/*  49 */       goods.goodsInfo.owner_id = 1;
/*  50 */       goods.goodsInfo.value = 2097924;
/*  51 */       goods.goodsInfo.quality = "金色";
/*  52 */       goods.goodsInfo.alias = packModification.getAlias();
/*  53 */       goods.goodsInfo.amount = 16;
/*  54 */       goods.pos = 31;
/*  55 */       goods.goodsInfo.food_num = 2;
/*  56 */       goods.goodsInfo.master = chara.sex;
/*  57 */       goods.goodsInfo.recognize_recognized = 0;
/*  58 */       goods.goodsInfo.type = Integer.valueOf(packModification.getType()).intValue();
/*  59 */       goods.goodsInfo.total_score = 25;
/*  60 */       goods.goodsInfo.damage_sel_rate = 1842075;
/*  61 */       goods.goodsInfo.str = packModification.getStr();
/*  62 */       goods.goodsInfo.metal = chara.menpai;
/*  63 */       goods.goodsInfo.durability = 8;
/*  64 */       goods.goodsInfo.rebuild_level = 500;
/*  65 */       goods.goodsInfo.auto_fight = "5d65f0216e9552d52c521d59";
/*  66 */       chara.backpack.add(goods);
/*  67 */       List<Goods> list = new ArrayList();
/*  68 */       list.add(goods);
/*  69 */       GameObjectChar.send(new MSG_INVENTORY(), list);
/*  70 */       chara.special_icon = Integer.valueOf(packModification.getFasionType()).intValue();
/*  71 */       Vo_61677_0 vo_61677_12 = new Vo_61677_0();
/*  72 */       vo_61677_12.store_type = "fasion_store";
/*  73 */       vo_61677_12.npcID = 0;
/*  74 */       vo_61677_12.count = 1;
/*  75 */       vo_61677_12.isGoon = 0;
/*  76 */       vo_61677_12.pos = packModification.getPosition().intValue();
/*  77 */       GameObjectChar.send(new M61677_01(), vo_61677_12);
/*     */     }
/*     */     
/*     */ 
/*  81 */     if (packModification.getCategory().intValue() == 2) {
/*  82 */       for (int i = 0; i < chara.backpack.size(); i++) {
/*  83 */         if (((Goods)chara.backpack.get(i)).pos == 32) {
/*  84 */           Goods goods = (Goods)chara.backpack.get(i);
/*     */           
/*  86 */           chara.backpack.remove(chara.backpack.get(i));
/*  87 */           Vo_61677_0 vo_61677_0 = new Vo_61677_0();
/*  88 */           vo_61677_0.store_type = "effect_store";
/*  89 */           vo_61677_0.npcID = 0;
/*  90 */           vo_61677_0.list = chara.texiao;
/*  91 */           vo_61677_0.count = chara.texiao.size();
/*  92 */           GameObjectChar.send(new M61677_0(), vo_61677_0);
/*     */         }
/*     */       }
/*     */       
/*  96 */       Goods goods = new Goods();
/*  97 */       goods.goodsInfo.owner_id = 1;
/*  98 */       goods.goodsInfo.value = 262;
/*  99 */       goods.goodsInfo.quality = "金色";
/* 100 */       goods.goodsInfo.alias = packModification.getStr();
/* 101 */       goods.goodsInfo.amount = 17;
/* 102 */       goods.pos = 32;
/* 103 */       goods.goodsInfo.food_num = 0;
/* 104 */       goods.goodsInfo.merge_rate = 0;
/* 105 */       goods.goodsInfo.master = 0;
/* 106 */       goods.goodsInfo.recognize_recognized = 2;
/* 107 */       goods.goodsInfo.type = Integer.valueOf(packModification.getType()).intValue();
/* 108 */       goods.goodsInfo.total_score = 23;
/* 109 */       goods.goodsInfo.damage_sel_rate = 809382;
/* 110 */       goods.goodsInfo.str = packModification.getStr();
/*     */       
/* 112 */       goods.goodsInfo.attrib = 0;
/* 113 */       goods.goodsInfo.durability = 8;
/* 114 */       goods.goodsInfo.rebuild_level = 0;
/* 115 */       goods.goodsInfo.auto_fight = ("5d65f0216e9552d52c521d59" + packModification.getType());
/* 116 */       chara.backpack.add(goods);
/* 117 */       List<Goods> list = new ArrayList();
/* 118 */       list.add(goods);
/* 119 */       GameObjectChar.send(new MSG_INVENTORY(), list);
/* 120 */       GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
/* 121 */       Vo_61677_0 vo_61677_12 = new Vo_61677_0();
/* 122 */       vo_61677_12.store_type = "effect_store";
/* 123 */       vo_61677_12.npcID = 0;
/* 124 */       vo_61677_12.count = 1;
/* 125 */       vo_61677_12.isGoon = 0;
/* 126 */       vo_61677_12.pos = packModification.getPosition().intValue();
/* 127 */       GameObjectChar.send(new M61677_01(), vo_61677_12);
/* 128 */       chara.texiao_icon = Integer.valueOf(packModification.getFasionType()).intValue();
/*     */     }
/*     */     
/* 131 */     if (packModification.getCategory().intValue() == 3) {
/* 132 */       org.linlinjava.litemall.gameserver.data.vo.Vo_4197_0 vo_4197_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_4197_0();
/* 133 */       vo_4197_0.id = 0;
/* 134 */       GameObjectChar.getGameObjectChar().gameMap.send(new org.linlinjava.litemall.gameserver.data.write.M4197_0(), vo_4197_0);
/* 135 */       GameObjectChar.getGameObjectChar().gameMap.send(new org.linlinjava.litemall.gameserver.data.write.M12285_1(), Integer.valueOf(chara.genchong_icon));
/* 136 */       for (int i = 0; i < chara.backpack.size(); i++) {
/* 137 */         if (((Goods)chara.backpack.get(i)).pos == 37) {
/* 138 */           Goods goods = (Goods)chara.backpack.get(i);
/*     */           
/* 140 */           chara.backpack.remove(chara.backpack.get(i));
/* 141 */           Vo_61677_0 vo_61677_0 = new Vo_61677_0();
/* 142 */           vo_61677_0.store_type = "follow_pet_store";
/* 143 */           vo_61677_0.npcID = 0;
/* 144 */           vo_61677_0.list = chara.genchong;
/* 145 */           vo_61677_0.count = chara.genchong.size();
/* 146 */           GameObjectChar.send(new M61677_0(), vo_61677_0);
/*     */         }
/*     */       }
/*     */       
/* 150 */       Goods goods = new Goods();
/* 151 */       goods.goodsInfo.owner_id = 1;
/* 152 */       goods.goodsInfo.value = 262;
/* 153 */       goods.goodsInfo.quality = "金色";
/* 154 */       goods.goodsInfo.alias = packModification.getStr();
/* 155 */       goods.goodsInfo.amount = 17;
/* 156 */       goods.pos = 37;
/* 157 */       goods.goodsInfo.food_num = 0;
/* 158 */       goods.goodsInfo.merge_rate = 0;
/* 159 */       goods.goodsInfo.master = 0;
/* 160 */       goods.goodsInfo.recognize_recognized = 2;
/* 161 */       goods.goodsInfo.type = Integer.valueOf(packModification.getType()).intValue();
/* 162 */       goods.goodsInfo.total_score = 23;
/* 163 */       goods.goodsInfo.damage_sel_rate = 809382;
/* 164 */       goods.goodsInfo.str = packModification.getStr();
/*     */       
/* 166 */       goods.goodsInfo.attrib = 0;
/* 167 */       goods.goodsInfo.durability = 8;
/* 168 */       goods.goodsInfo.rebuild_level = 0;
/* 169 */       goods.goodsInfo.auto_fight = ("5d65f0216e9552d52c521d59" + packModification.getType());
/* 170 */       chara.backpack.add(goods);
/* 171 */       List<Goods> list = new ArrayList();
/* 172 */       list.add(goods);
/* 173 */       GameObjectChar.send(new MSG_INVENTORY(), list);
/* 174 */       Vo_61677_0 vo_61677_12 = new Vo_61677_0();
/* 175 */       vo_61677_12.store_type = "follow_pet_store";
/* 176 */       vo_61677_12.npcID = 0;
/* 177 */       vo_61677_12.count = 1;
/* 178 */       vo_61677_12.isGoon = 0;
/* 179 */       vo_61677_12.pos = packModification.getPosition().intValue();
/* 180 */       GameObjectChar.send(new M61677_01(), vo_61677_12);
/* 181 */       chara.genchong_icon = Integer.valueOf(packModification.getFasionType()).intValue();
/* 182 */       Vo_65529_0 vo_65529_0 = new Vo_65529_0();
/* 183 */       vo_65529_0.id = Integer.valueOf(packModification.getFasionType()).intValue();
/* 184 */       vo_65529_0.x = chara.x;
/* 185 */       vo_65529_0.y = chara.y;
/* 186 */       vo_65529_0.dir = 5;
/* 187 */       vo_65529_0.icon = chara.genchong_icon;
/* 188 */       vo_65529_0.type = 32768;
/* 189 */       vo_65529_0.sub_type = 2;
/* 190 */       vo_65529_0.owner_id = chara.id;
/* 191 */       vo_65529_0.name = packModification.getStr();
/* 192 */       vo_65529_0.org_icon = chara.genchong_icon;
/* 193 */       vo_65529_0.portrait = chara.genchong_icon;
/* 194 */       GameObjectChar.getGameObjectChar().gameMap.send(new MSG_APPEAR(), vo_65529_0);
/*     */     }
/*     */     
/*     */ 
/* 198 */     org.linlinjava.litemall.gameserver.data.vo.Vo_61661_0 vo_61661_0 = GameUtil.MSG_UPDATE_APPEARANCE(chara);
/* 199 */     GameObjectChar.getGameObjectChar().gameMap.send(new MSG_UPDATE_APPEARANCE(), vo_61661_0);
/*     */     
/*     */ 
/* 202 */     Vo_61671_0 vo_61671_0 = new Vo_61671_0();
/* 203 */     vo_61671_0.id = chara.id;
/* 204 */     vo_61671_0.count = 0;
/*     */     
/* 206 */     GameObjectChar.send(new MSG_TITLE(), vo_61671_0);
/* 207 */     Vo_8165_0 vo_8165_0 = new Vo_8165_0();
/* 208 */     vo_8165_0.msg = "穿戴成功";
/* 209 */     vo_8165_0.active = 0;
/* 210 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M8165_0(), vo_8165_0);
/* 211 */     Vo_41505_0 vo_41505_0 = new Vo_41505_0();
/* 212 */     vo_41505_0.type = "equip_fasion";
/* 213 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M41505_0(), vo_41505_0);
/*     */   }
/*     */   
/*     */ 
/*     */ 
/*     */   public int cmd()
/*     */   {
/* 220 */     return 41490;
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C41490_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */