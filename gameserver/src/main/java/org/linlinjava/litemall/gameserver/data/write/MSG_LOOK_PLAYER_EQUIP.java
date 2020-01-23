/*     */ package org.linlinjava.litemall.gameserver.data.write;
/*     */ 
/*     */ import java.io.PrintStream;
/*     */ import java.util.Iterator;
/*     */ import java.util.List;
/*     */ import java.util.Map;
/*     */ import java.util.Map.Entry;
/*     */ import java.util.Set;
/*     */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*     */ import org.linlinjava.litemall.gameserver.data.UtilObjMapshuxing;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_49153_0;
/*     */ import org.linlinjava.litemall.gameserver.domain.BuildFields;
/*     */ import org.linlinjava.litemall.gameserver.domain.Goods;
/*     */ import org.linlinjava.litemall.gameserver.domain.GoodsGaiZao;
/*     */ import org.linlinjava.litemall.gameserver.domain.GoodsGaiZaoGongMing;
/*     */ import org.linlinjava.litemall.gameserver.domain.GoodsHuangSe;
/*     */

/**
 * 查看装备
 */
/*     */ @org.springframework.stereotype.Service
/*     */ public class MSG_LOOK_PLAYER_EQUIP extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*     */ {
/*     */   protected void writeO(io.netty.buffer.ByteBuf writeBuf, Object object)
/*     */   {
/*  23 */     Vo_49153_0 object1 = (Vo_49153_0)object;
/*  24 */     GameWriteTool.writeString(writeBuf, object1.name);
/*     */     
/*  26 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.level));
/*     */     
/*  28 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.icon));
/*     */     
/*  30 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.special_icon));
/*     */     
/*  32 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.weapon_icon));
/*     */     
/*  34 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.suit_icon));
/*     */     
/*  36 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.suit_effect));
/*     */     
/*  38 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.power));
/*     */     
/*  40 */     GameWriteTool.writeString(writeBuf, object1.partyName);
/*     */     
/*  42 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.fashionIcon));
/*     */     
/*  44 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.upgradetype));
/*     */     
/*  46 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.upgradelevel));
/*     */     
/*     */ 
/*     */ 
/*  50 */     List<Goods> list = object1.backpack;
/*  51 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(list.size()));
/*  52 */     Entry<Object, Object> entry; for (int i = 0; i < list.size(); i++) {
/*  53 */       Goods goods = (Goods)list.get(i);
/*  54 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(goods.pos));
/*  55 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(10));
/*  56 */       Map<Object, Object> map = new java.util.HashMap();
/*  57 */       Entry<Object, Object> objectObjectEntry; if (goods.goodsInfo != null) {
/*  58 */         map = UtilObjMapshuxing.GoodsInfo(goods.goodsInfo);
/*  59 */         map.remove("groupNo");
/*  60 */         map.remove("groupType");
/*     */         
/*  62 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsInfo.groupNo));
/*  63 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsInfo.groupType));
/*  64 */         Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/*     */         
/*  66 */         while (it.hasNext()) {
/*  67 */           objectObjectEntry = (Entry)it.next();
/*  68 */           if ((objectObjectEntry.getValue().equals(Integer.valueOf(0))) && (objectObjectEntry.getKey().equals("silver_coin"))) {
/*  69 */             it.remove();
/*     */           }
/*     */         }
/*  72 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/*  73 */         for (Entry<Object, Object> objectObjectEntry1 : map.entrySet()) {
/*  74 */           if (BuildFields.data.get((String)objectObjectEntry1.getKey()) != null) {
/*  75 */             BuildFields.get((String)objectObjectEntry1.getKey()).write(writeBuf, objectObjectEntry1.getValue());
/*     */           } else
/*  77 */             System.out.println(objectObjectEntry1.getKey());
/*     */         }
/*     */       }
/*     */       Entry<Object, Object> objectObjectEntry1;
/*  81 */       if (goods.goodsBasics != null) {
/*  82 */         map = UtilObjMapshuxing.GoodsBasics(goods.goodsBasics);
/*  83 */         map.remove("groupNo");
/*  84 */         map.remove("groupType");
/*     */         
/*  86 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsBasics.groupNo));
/*  87 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsBasics.groupType));
/*  88 */         Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/*  89 */         while (it.hasNext()) {
/*  90 */           objectObjectEntry1 = (Entry)it.next();
/*  91 */           if (objectObjectEntry1.getValue().equals(Integer.valueOf(0))) {
/*  92 */             it.remove();
/*     */           }
/*     */         }
/*  95 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/*  96 */         for (Entry<Object, Object> objectObjectEntry2 : map.entrySet()) {
/*  97 */           if (BuildFields.data.get((String)objectObjectEntry2.getKey()) != null) {
/*  98 */             BuildFields.get((String)objectObjectEntry2.getKey()).write(writeBuf, objectObjectEntry2.getValue());
/*     */           } else
/* 100 */             System.out.println(objectObjectEntry2.getKey());
/*     */         }
/*     */       }
/*     */       Entry<Object, Object> objectObjectEntry2;
/* 104 */       if (goods.goodsLanSe != null) {
/* 105 */         map = UtilObjMapshuxing.GoodsLanSe(goods.goodsLanSe);
/* 106 */         map.remove("groupNo");
/* 107 */         map.remove("groupType");
/*     */         
/* 109 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsLanSe.groupNo));
/* 110 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsLanSe.groupType));
/* 111 */         Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/* 112 */         while (it.hasNext()) {
/* 113 */           objectObjectEntry2 = (Entry)it.next();
/* 114 */           if (objectObjectEntry2.getValue().equals(Integer.valueOf(0))) {
/* 115 */             it.remove();
/*     */           }
/*     */         }
/* 118 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 119 */         for (Entry<Object, Object> objectObjectEntry3 : map.entrySet()) {
/* 120 */           if (BuildFields.data.get((String)objectObjectEntry3.getKey()) != null) {
/* 121 */             BuildFields.get((String)objectObjectEntry3.getKey()).write(writeBuf, objectObjectEntry3.getValue());
/*     */           } else
/* 123 */             System.out.println(objectObjectEntry3.getKey());
/*     */         }
/*     */       }
/*     */       Entry<Object, Object> objectObjectEntry3;
/* 127 */       if (goods.goodsFenSe != null) {
/* 128 */         map = UtilObjMapshuxing.GoodsFenSe(goods.goodsFenSe);
/* 129 */         map.remove("groupNo");
/* 130 */         map.remove("groupType");
/*     */         
/* 132 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsFenSe.groupNo));
/* 133 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsFenSe.groupType));
/* 134 */         Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/* 135 */         while (it.hasNext()) {
/* 136 */           objectObjectEntry3 = (Entry)it.next();
/* 137 */           if (objectObjectEntry3.getValue().equals(Integer.valueOf(0))) {
/* 138 */             it.remove();
/*     */           }
/*     */         }
/* 141 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 142 */         for (Entry<Object, Object> objectObjectEntry4 : map.entrySet()) {
/* 143 */           if (BuildFields.data.get((String)objectObjectEntry4.getKey()) != null) {
/* 144 */             BuildFields.get((String)objectObjectEntry4.getKey()).write(writeBuf, objectObjectEntry4.getValue());
/*     */           } else
/* 146 */             System.out.println(objectObjectEntry4.getKey());
/*     */         }
/*     */       }
/*     */       Entry<Object, Object> objectObjectEntry4;
/* 150 */       if (goods.goodsHuangSe != null) {
/* 151 */         map = UtilObjMapshuxing.GoodsHuangSe(goods.goodsHuangSe);
/* 152 */         map.remove("groupNo");
/* 153 */         map.remove("groupType");
/*     */         
/* 155 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsHuangSe.groupNo));
/* 156 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsHuangSe.groupType));
/* 157 */         Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/* 158 */         while (it.hasNext()) {
/* 159 */           objectObjectEntry4 = (Entry)it.next();
/* 160 */           if (objectObjectEntry4.getValue().equals(Integer.valueOf(0))) {
/* 161 */             it.remove();
/*     */           }
/*     */         }
/* 164 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 165 */         for (Entry<Object, Object> objectEntry : map.entrySet()) {
/* 166 */           if (BuildFields.data.get((String)objectEntry.getKey()) != null) {
/* 167 */             BuildFields.get((String)objectEntry.getKey()).write(writeBuf, objectEntry.getValue());
/*     */           } else
/* 169 */             System.out.println(objectEntry.getKey());
/*     */         }
/*     */       }
/*     */       Entry<Object, Object> objectObjectEntry5;
/* 173 */       if (goods.goodsLvSe != null) {
/* 174 */         map = UtilObjMapshuxing.GoodsLvSe(goods.goodsLvSe);
/* 175 */         map.remove("groupNo");
/* 176 */         map.remove("groupType");
/*     */         
/* 178 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsLvSe.groupNo));
/* 179 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsLvSe.groupType));
/* 180 */         Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/* 181 */         while (it.hasNext()) {
/* 182 */           objectObjectEntry5 = (Entry)it.next();
/* 183 */           if (objectObjectEntry5.getValue().equals(Integer.valueOf(0))) {
/* 184 */             it.remove();
/*     */           }
/*     */         }
/* 187 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 188 */         for (Entry<Object, Object> objectObjectEntry6 : map.entrySet()) {
/* 189 */           if (BuildFields.data.get((String)objectObjectEntry6.getKey()) != null) {
/* 190 */             BuildFields.get((String)objectObjectEntry6.getKey()).write(writeBuf, objectObjectEntry6.getValue());
/*     */           } else
/* 192 */             System.out.println(objectObjectEntry6.getKey());
/*     */         }
/*     */       }
/*     */       Entry<Object, Object> objectObjectEntry6;
/* 196 */       if (goods.goodsGaiZao != null) {
/* 197 */         map = UtilObjMapshuxing.GoodsGaiZao(goods.goodsGaiZao);
/* 198 */         map.remove("groupNo");
/* 199 */         map.remove("groupType");
/*     */         
/* 201 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsGaiZao.groupNo));
/* 202 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsGaiZao.groupType));
/* 203 */         Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/* 204 */         while (it.hasNext()) {
/* 205 */           objectObjectEntry6 = (Entry)it.next();
/* 206 */           if (objectObjectEntry6.getValue().equals(Integer.valueOf(0))) {
/* 207 */             it.remove();
/*     */           }
/*     */         }
/* 210 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 211 */         for (Entry<Object, Object> objectObjectEntry7 : map.entrySet()) {
/* 212 */           if (BuildFields.data.get((String)objectObjectEntry7.getKey()) != null) {
/* 213 */             BuildFields.get((String)objectObjectEntry7.getKey()).write(writeBuf, objectObjectEntry7.getValue());
/*     */           } else
/* 215 */             System.out.println(objectObjectEntry7.getKey());
/*     */         }
/*     */       }
/*     */       Entry<Object, Object> objectObjectEntry7;
/* 219 */       if (goods.goodsGaiZaoGongMing != null) {
/* 220 */         map = UtilObjMapshuxing.GoodsGaiZaoGongMing(goods.goodsGaiZaoGongMing);
/* 221 */         map.remove("groupNo");
/* 222 */         map.remove("groupType");
/*     */         
/* 224 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsGaiZaoGongMing.groupNo));
/* 225 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsGaiZaoGongMing.groupType));
/* 226 */         Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/* 227 */         while (it.hasNext()) {
/* 228 */           objectObjectEntry7 = (Entry)it.next();
/* 229 */           if (objectObjectEntry7.getValue().equals(Integer.valueOf(0))) {
/* 230 */             it.remove();
/*     */           }
/*     */         }
/* 233 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 234 */         for (Entry<Object, Object> objectObjectEntry8 : map.entrySet()) {
/* 235 */           if (BuildFields.data.get((String)objectObjectEntry8.getKey()) != null) {
/* 236 */             BuildFields.get((String)objectObjectEntry8.getKey()).write(writeBuf, objectObjectEntry8.getValue());
/*     */           } else
/* 238 */             System.out.println(objectObjectEntry8.getKey());
/*     */         }
/*     */       }
/*     */       Entry<Object, Object> objectObjectEntry8;
/* 242 */       if (goods.goodsGaiZaoGongMingChengGong != null) {
/* 243 */         map = UtilObjMapshuxing.GoodsGaiZaoGongMingChengGong(goods.goodsGaiZaoGongMingChengGong);
/* 244 */         map.remove("groupNo");
/* 245 */         map.remove("groupType");
/*     */         
/* 247 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsGaiZaoGongMingChengGong.groupNo));
/* 248 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsGaiZaoGongMingChengGong.groupType));
/* 249 */         Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/* 250 */         while (it.hasNext()) {
/* 251 */           objectObjectEntry8 = (Entry)it.next();
/* 252 */           if (objectObjectEntry8.getValue().equals(Integer.valueOf(0))) {
/* 253 */             it.remove();
/*     */           }
/*     */         }
/* 256 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 257 */         for (Entry<Object, Object> objectObjectEntry9 : map.entrySet()) {
/* 258 */           if (BuildFields.data.get((String)objectObjectEntry9.getKey()) != null) {
/* 259 */             BuildFields.get((String)objectObjectEntry9.getKey()).write(writeBuf, objectObjectEntry9.getValue());
/*     */           } else {
/* 261 */             System.out.println(objectObjectEntry9.getKey());
/*     */           }
/*     */         }
/*     */       }
/* 265 */       if (goods.goodsLvSeGongMing != null) {
/* 266 */         map = UtilObjMapshuxing.GoodsLvSeGongMing(goods.goodsLvSeGongMing);
/* 267 */         map.remove("groupNo");
/* 268 */         map.remove("groupType");
/*     */         
/* 270 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsLvSeGongMing.groupNo));
/* 271 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsLvSeGongMing.groupType));
/* 272 */         Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/* 273 */         while (it.hasNext()) {
/* 274 */           objectObjectEntry8 = (Entry)it.next();
/* 275 */           if (objectObjectEntry8.getValue().equals(Integer.valueOf(0))) {
/* 276 */             it.remove();
/*     */           }
/*     */         }
/* 279 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 280 */         for (Entry<Object, Object> objectObjectEntry9 : map.entrySet()) {
/* 281 */           if (BuildFields.data.get((String)objectObjectEntry9.getKey()) != null) {
/* 282 */             BuildFields.get((String)objectObjectEntry9.getKey()).write(writeBuf, objectObjectEntry9.getValue());
/*     */           } else {
/* 284 */             System.out.println(objectObjectEntry9.getKey());
/*     */           }
/*     */         }
/*     */       }
/*     */     }
/*     */   }
/*     */   
/*     */ 
/*     */ 
/*     */   public int cmd()
/*     */   {
/* 295 */     return 49153;
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M49153_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */