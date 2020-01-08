/*     */ package org.linlinjava.litemall.gameserver.process;
/*     */ 
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import io.netty.channel.ChannelHandlerContext;
/*     */ import java.util.ArrayList;
/*     */ import java.util.List;
/*     */ import org.linlinjava.litemall.gameserver.GameHandler;
/*     */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61677_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_8249_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M61677_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_INVENTORY;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M8249_0;
/*     */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ import org.linlinjava.litemall.gameserver.domain.Goods;
/*     */
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*     */ import org.springframework.stereotype.Service;
/*     */ 
/*     */ @Service
/*     */ public class C8246_0 implements GameHandler
/*     */ {
/*     */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*     */   {
/*  25 */     int count = GameReadTool.readShort(buff);
/*     */     
/*  27 */     String range = GameReadTool.readString2(buff);
/*     */     
/*  29 */     int start_pos = GameReadTool.readShort(buff);
/*     */     
/*  31 */     String to_store_cards = GameReadTool.readString2(buff);
/*     */     
/*     */ 
/*  34 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*  35 */     String[] split = range.split("\\|");
/*     */     
/*  37 */     String pos1 = split[0];
/*     */     
/*  39 */     String pos2 = split[1];
/*     */     
/*  41 */     String[] split1 = pos1.split("\\,");
/*  42 */     String[] split2 = pos2.split("\\,");
/*     */     
/*     */ 
/*  45 */     Vo_8249_0 vo_8249_0 = new Vo_8249_0();
/*  46 */     vo_8249_0.start_range = 1;
/*  47 */     GameObjectChar.send(new M8249_0(), vo_8249_0);
/*     */     
/*  49 */     GameUtil.removerbeibaocangku(chara);
/*     */     
/*     */ 
/*  52 */     if (start_pos == 41) {
/*  53 */       List<Goods> list = new ArrayList();
/*  54 */       if (!pos1.equals("")) {
/*  55 */         for (int i = 0; i < split1.length; i++) {
/*  56 */           String[] split3 = split1[i].split("\\-");
/*  57 */           Goods goods = null;
/*  58 */           for (int j = 0; j < chara.backpack.size(); j++) {
/*  59 */             if (((Goods)chara.backpack.get(j)).pos == Integer.parseInt(split3[0])) {
/*  60 */               goods = (Goods)chara.backpack.get(j);
/*  61 */               break;
/*     */             }
/*     */           }
/*  64 */           for (int j = 0; j < chara.backpack.size(); j++) {
/*  65 */             for (int k = 0; k < split3.length - 1; k++) {
/*  66 */               if (((Goods)chara.backpack.get(j)).pos == Integer.parseInt(split3[(k + 1)])) {
/*  67 */                 int munber = 10;
/*  68 */                 if ("凝香幻彩#炫影霜星#风寂云清#枯月流魂#冰落残阳#雷极弧光".contains(((Goods)chara.backpack.get(j)).goodsInfo.str)) {
/*  69 */                   munber = 999;
/*     */                 }
/*  71 */                 Goods goods1 = (Goods)chara.backpack.get(j);
/*  72 */                 int owner = goods.goodsInfo.owner_id;
/*  73 */                 goods.goodsInfo.owner_id += goods1.goodsInfo.owner_id;
/*  74 */                 if (goods.goodsInfo.owner_id >= munber) {
/*  75 */                   goods.goodsInfo.owner_id = munber;
/*  76 */                   goods1.goodsInfo.owner_id = (goods1.goodsInfo.owner_id - munber + owner);
/*  77 */                   break;
/*     */                 }
/*  79 */                 goods1.goodsInfo.owner_id = 0;
/*  80 */                 List<Goods> listbeibao = new ArrayList();
/*  81 */                 Goods goods2 = new Goods();
/*  82 */                 goods2.goodsBasics = null;
/*  83 */                 goods2.goodsInfo = null;
/*  84 */                 goods2.goodsLanSe = null;
/*  85 */                 goods2.pos = Integer.parseInt(split3[(k + 1)]);
/*  86 */                 listbeibao.add(goods2);
/*  87 */                 list.add(goods1);
/*     */                 
/*  89 */                 GameObjectChar.send(new MSG_INVENTORY(), listbeibao);
/*     */                 
/*  91 */                 break;
/*     */               }
/*     */             }
/*     */           }
/*     */         }
/*  96 */         for (int i = 0; i < list.size(); i++) {
/*  97 */           chara.backpack.remove(list.get(i));
/*     */         }
/*     */       }
/* 100 */       if (!pos2.equals("")) {
/* 101 */         for (int i = 0; i < split2.length; i++) {
/* 102 */           String[] split4 = split2[i].split("\\-");
/* 103 */           for (int j = 0; j < chara.backpack.size(); j++) {
/* 104 */             if (((Goods)chara.backpack.get(j)).pos == Integer.parseInt(split4[0])) {
/* 105 */               Goods goods = (Goods)chara.backpack.get(j);
/* 106 */               goods.pos = Integer.parseInt(split4[1]);
/* 107 */               list = new ArrayList();
/* 108 */               list.add(goods);
/* 109 */               GameObjectChar.send(new MSG_INVENTORY(), list);
/* 110 */               break;
/*     */             }
/*     */           }
/* 113 */           List<Goods> listbeibao = new ArrayList();
/* 114 */           Goods goods1 = new Goods();
/* 115 */           goods1.goodsBasics = null;
/* 116 */           goods1.goodsInfo = null;
/* 117 */           goods1.goodsLanSe = null;
/* 118 */           goods1.pos = Integer.parseInt(split4[0]);
/* 119 */           listbeibao.add(goods1);
/* 120 */           GameObjectChar.send(new MSG_INVENTORY(), listbeibao);
/*     */         }
/*     */       }
/* 123 */       GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
/* 124 */       vo_8249_0 = new Vo_8249_0();
/* 125 */       vo_8249_0.start_range = 0;
/* 126 */       GameObjectChar.send(new M8249_0(), vo_8249_0);
/*     */     }
/* 128 */     vo_8249_0 = new Vo_8249_0();
/* 129 */     vo_8249_0.start_range = 1;
/* 130 */     GameObjectChar.send(new M8249_0(), vo_8249_0);
/*     */     
/* 132 */     if (start_pos == 201) {
/* 133 */       List<Goods> list = new ArrayList();
/* 134 */       for (int i = 0; i < split1.length; i++) {
/* 135 */         String[] split3 = split1[i].split("\\-");
/* 136 */         Goods goods = null;
/* 137 */         if (!split3[0].equals(""))
/*     */         {
/* 139 */           for (int j = 0; j < chara.cangku.size(); j++) {
/* 140 */             if (((Goods)chara.cangku.get(j)).pos == Integer.parseInt(split3[0])) {
/* 141 */               goods = (Goods)chara.cangku.get(j);
/* 142 */               break;
/*     */             }
/*     */           }
/* 145 */           for (int j = 0; j < chara.cangku.size(); j++) {
/* 146 */             for (int k = 0; k < split3.length - 1; k++) {
/* 147 */               if (((Goods)chara.cangku.get(j)).pos == Integer.parseInt(split3[(k + 1)])) {
/* 148 */                 int munber = 10;
/* 149 */                 if ("凝香幻彩#炫影霜星#风寂云清#枯月流魂#冰落残阳#雷极弧光".contains(((Goods)chara.cangku.get(j)).goodsInfo.str)) {
/* 150 */                   munber = 999;
/*     */                 }
/* 152 */                 Goods goods1 = (Goods)chara.cangku.get(j);
/* 153 */                 int owner = goods.goodsInfo.owner_id;
/* 154 */                 goods.goodsInfo.owner_id += goods1.goodsInfo.owner_id;
/* 155 */                 if (goods.goodsInfo.owner_id >= munber) {
/* 156 */                   goods.goodsInfo.owner_id = munber;
/* 157 */                   goods1.goodsInfo.owner_id = (goods1.goodsInfo.owner_id - munber + owner);
/* 158 */                   break;
/*     */                 }
/* 160 */                 goods1.goodsInfo.owner_id = 0;
/* 161 */                 list.add(goods1);
/*     */                 
/* 163 */                 break;
/*     */               }
/*     */             }
/*     */           }
/*     */         }
/*     */       }
/* 169 */       for (int i = 0; i < list.size(); i++) {
/* 170 */         chara.cangku.remove(list.get(i));
/*     */       }
/* 172 */       Vo_61677_0 vo_61677_0 = new Vo_61677_0();
/* 173 */       vo_61677_0.list = chara.cangku;
/* 174 */       GameObjectChar.send(new M61677_0(), vo_61677_0);
/* 175 */       if (!pos2.equals("")) {
/* 176 */         for (int i = 0; i < split2.length; i++) {
/* 177 */           String[] split4 = split2[i].split("\\-");
/* 178 */           for (int j = 0; j < chara.cangku.size(); j++) {
/* 179 */             if (((Goods)chara.cangku.get(j)).pos == Integer.parseInt(split4[0])) {
/* 180 */               Goods goods = (Goods)chara.cangku.get(j);
/* 181 */               goods.pos = Integer.parseInt(split4[1]);
/* 182 */               break;
/*     */             }
/*     */           }
/*     */         }
/*     */       }
/* 187 */       vo_61677_0 = new Vo_61677_0();
/* 188 */       vo_61677_0.list = chara.cangku;
/* 189 */       GameObjectChar.send(new M61677_0(), vo_61677_0);
/*     */     }
/*     */     
/* 192 */     vo_8249_0 = new Vo_8249_0();
/* 193 */     vo_8249_0.start_range = 0;
/* 194 */     GameObjectChar.send(new M8249_0(), vo_8249_0);
/*     */   }
/*     */   
/*     */ 
/*     */   public int cmd()
/*     */   {
/* 200 */     return 8246;
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C8246_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */