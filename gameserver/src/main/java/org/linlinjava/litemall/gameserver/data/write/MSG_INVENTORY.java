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
/*     */ import org.linlinjava.litemall.gameserver.domain.BuildFields;
/*     */ import org.linlinjava.litemall.gameserver.domain.Goods;
/*     */ import org.linlinjava.litemall.gameserver.domain.GoodsFenSe;
/*     */ import org.linlinjava.litemall.gameserver.domain.GoodsGaiZao;
/*     */ import org.linlinjava.litemall.gameserver.domain.GoodsGaiZaoGongMing;
/*     */ import org.linlinjava.litemall.gameserver.domain.GoodsHuangSe;
/*     */ import org.linlinjava.litemall.gameserver.domain.GoodsLanSe;
/*     */ 
/*     */ @org.springframework.stereotype.Service
/*     */ public class MSG_INVENTORY extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*     */ {
/*     */   protected void writeO(io.netty.buffer.ByteBuf writeBuf, Object object)
/*     */   {
/*  24 */     List<Goods> list = (List)object;
/*  25 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(list.size()));
/*  26 */     Entry<Object, Object> entry; for (int i = 0; i < list.size(); i++) {
/*  27 */       Goods goods = (Goods)list.get(i);
/*  28 */       GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.pos));
/*  29 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(10));
/*  30 */       Map<Object, Object> map = new java.util.HashMap();
/*  31 */       Entry<Object, Object> objectEntry; if (goods.goodsInfo != null) {
/*  32 */         map = UtilObjMapshuxing.GoodsInfo(goods.goodsInfo);
/*  33 */         map.remove("groupNo");
/*  34 */         map.remove("groupType");
/*     */         
/*  36 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsInfo.groupNo));
/*  37 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsInfo.groupType));
/*  38 */         Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/*     */         
/*  40 */         while (it.hasNext()) {
/*  41 */           objectEntry = (Entry)it.next();
/*  42 */           if ((objectEntry.getValue().equals(Integer.valueOf(0))) && (objectEntry.getKey().equals("silver_coin"))) {
/*  43 */             it.remove();
/*     */           }
/*  45 */           if ((objectEntry.getValue().equals(Integer.valueOf(0))) && (objectEntry.getKey().equals("pot"))) {
/*  46 */             it.remove();
/*     */           }
/*     */         }
/*  49 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/*  50 */         for (Entry<Object, Object> objectEntry1 : map.entrySet()) {
/*  51 */           if (BuildFields.data.get((String)objectEntry1.getKey()) != null) {
/*  52 */             BuildFields.get((String)objectEntry1.getKey()).write(writeBuf, objectEntry1.getValue());
/*     */           } else
/*  54 */             System.out.println(objectEntry1.getKey());
/*     */         }
/*     */       }
/*     */       Entry<Object, Object> objectEntry1;
/*  58 */       if (goods.goodsBasics != null) {
/*  59 */         map = UtilObjMapshuxing.GoodsBasics(goods.goodsBasics);
/*  60 */         map.remove("groupNo");
/*  61 */         map.remove("groupType");
/*     */         
/*  63 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsBasics.groupNo));
/*  64 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsBasics.groupType));
/*  65 */         Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/*  66 */         while (it.hasNext()) {
/*  67 */           objectEntry1 = (Entry)it.next();
/*  68 */           if (objectEntry1.getValue().equals(Integer.valueOf(0))) {
/*  69 */             it.remove();
/*     */           }
/*     */         }
/*  72 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/*  73 */         for (Entry<Object, Object> objectEntry2 : map.entrySet()) {
/*  74 */           if (BuildFields.data.get((String)objectEntry2.getKey()) != null) {
/*  75 */             BuildFields.get((String)objectEntry2.getKey()).write(writeBuf, objectEntry2.getValue());
/*     */           } else
/*  77 */             System.out.println(objectEntry2.getKey());
/*     */         }
/*     */       }
/*     */       Entry<Object, Object> objectEntry2;
/*  81 */       if (goods.goodsLanSe != null) {
/*  82 */         map = UtilObjMapshuxing.GoodsLanSe(goods.goodsLanSe);
/*  83 */         map.remove("groupNo");
/*  84 */         map.remove("groupType");
/*     */         
/*  86 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsLanSe.groupNo));
/*  87 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsLanSe.groupType));
/*  88 */         Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/*  89 */         while (it.hasNext()) {
/*  90 */           objectEntry2 = (Entry)it.next();
/*  91 */           if (objectEntry2.getValue().equals(Integer.valueOf(0))) {
/*  92 */             it.remove();
/*     */           }
/*     */         }
/*  95 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/*  96 */         for (Entry<Object, Object> objectEntry3 : map.entrySet()) {
/*  97 */           if (BuildFields.data.get((String)objectEntry3.getKey()) != null) {
/*  98 */             BuildFields.get((String)objectEntry3.getKey()).write(writeBuf, objectEntry3.getValue());
/*     */           } else
/* 100 */             System.out.println(objectEntry3.getKey());
/*     */         }
/*     */       }
/*     */       Entry<Object, Object> objectEntry3;
/* 104 */       if (goods.goodsFenSe != null) {
/* 105 */         map = UtilObjMapshuxing.GoodsFenSe(goods.goodsFenSe);
/* 106 */         map.remove("groupNo");
/* 107 */         map.remove("groupType");
/*     */         
/* 109 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsFenSe.groupNo));
/* 110 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsFenSe.groupType));
/* 111 */         Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/* 112 */         while (it.hasNext()) {
/* 113 */           objectEntry3 = (Entry)it.next();
/* 114 */           if (objectEntry3.getValue().equals(Integer.valueOf(0))) {
/* 115 */             it.remove();
/*     */           }
/*     */         }
/* 118 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 119 */         for (Entry<Object, Object> objectEntry4 : map.entrySet()) {
/* 120 */           if (BuildFields.data.get((String)objectEntry4.getKey()) != null) {
/* 121 */             BuildFields.get((String)objectEntry4.getKey()).write(writeBuf, objectEntry4.getValue());
/*     */           } else
/* 123 */             System.out.println(objectEntry4.getKey());
/*     */         }
/*     */       }
/*     */       Entry<Object, Object> objectEntry4;
/* 127 */       if (goods.goodsHuangSe != null) {
/* 128 */         map = UtilObjMapshuxing.GoodsHuangSe(goods.goodsHuangSe);
/* 129 */         map.remove("groupNo");
/* 130 */         map.remove("groupType");
/*     */         
/* 132 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsHuangSe.groupNo));
/* 133 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsHuangSe.groupType));
/* 134 */         Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/* 135 */         while (it.hasNext()) {
/* 136 */           objectEntry4 = (Entry)it.next();
/* 137 */           if (objectEntry4.getValue().equals(Integer.valueOf(0))) {
/* 138 */             it.remove();
/*     */           }
/*     */         }
/* 141 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 142 */         for (Entry<Object, Object> objectEntry5 : map.entrySet()) {
/* 143 */           if (BuildFields.data.get((String)objectEntry5.getKey()) != null)
/*     */           {
/*     */ 
/* 146 */             BuildFields.get((String)objectEntry5.getKey()).write(writeBuf, objectEntry5.getValue());
/*     */           } else
/* 148 */             System.out.println(objectEntry5.getKey());
/*     */         }
/*     */       }
/*     */       Entry<Object, Object> objectEntry5;
/* 152 */       if (goods.goodsLvSe != null) {
/* 153 */         map = UtilObjMapshuxing.GoodsLvSe(goods.goodsLvSe);
/* 154 */         map.remove("groupNo");
/* 155 */         map.remove("groupType");
/* 156 */         map.remove("speed");
/*     */         
/* 158 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsLvSe.groupNo));
/* 159 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsLvSe.groupType));
/* 160 */         Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/* 161 */         while (it.hasNext()) {
/* 162 */           objectEntry5 = (Entry)it.next();
/* 163 */           if (objectEntry5.getValue().equals(Integer.valueOf(0))) {
/* 164 */             it.remove();
/*     */           }
/*     */         }
/* 167 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 168 */         for (Entry<Object, Object> objectEntry6 : map.entrySet()) {
/* 169 */           if (BuildFields.data.get((String)objectEntry6.getKey()) != null) {
/* 170 */             BuildFields.get((String)objectEntry6.getKey()).write(writeBuf, objectEntry6.getValue());
/*     */           } else
/* 172 */             System.out.println(objectEntry6.getKey());
/*     */         }
/*     */       }
/*     */       Entry<Object, Object> objectEntry6;
/* 176 */       if (goods.goodsGaiZao != null) {
/* 177 */         map = UtilObjMapshuxing.GoodsGaiZao(goods.goodsGaiZao);
/* 178 */         map.remove("groupNo");
/* 179 */         map.remove("groupType");
/*     */         
/* 181 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsGaiZao.groupNo));
/* 182 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsGaiZao.groupType));
/* 183 */         Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/* 184 */         while (it.hasNext()) {
/* 185 */           objectEntry6 = (Entry)it.next();
/* 186 */           if (objectEntry6.getValue().equals(Integer.valueOf(0))) {
/* 187 */             it.remove();
/*     */           }
/*     */         }
/* 190 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 191 */         for (Entry<Object, Object> objectEntry7 : map.entrySet()) {
/* 192 */           if (BuildFields.data.get((String)objectEntry7.getKey()) != null) {
/* 193 */             BuildFields.get((String)objectEntry7.getKey()).write(writeBuf, objectEntry7.getValue());
/*     */           } else
/* 195 */             System.out.println(objectEntry7.getKey());
/*     */         }
/*     */       }
/*     */       Entry<Object, Object> objectEntry7;
/* 199 */       if (goods.goodsGaiZaoGongMing != null) {
/* 200 */         map = UtilObjMapshuxing.GoodsGaiZaoGongMing(goods.goodsGaiZaoGongMing);
/* 201 */         map.remove("groupNo");
/* 202 */         map.remove("groupType");
/*     */         
/* 204 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsGaiZaoGongMing.groupNo));
/* 205 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsGaiZaoGongMing.groupType));
/* 206 */         Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/* 207 */         while (it.hasNext()) {
/* 208 */           objectEntry7 = (Entry)it.next();
/* 209 */           if (objectEntry7.getValue().equals(Integer.valueOf(0))) {
/* 210 */             it.remove();
/*     */           }
/*     */         }
/* 213 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 214 */         for (Entry<Object, Object> objectEntry8 : map.entrySet()) {
/* 215 */           if (BuildFields.data.get((String)objectEntry8.getKey()) != null) {
/* 216 */             BuildFields.get((String)objectEntry8.getKey()).write(writeBuf, objectEntry8.getValue());
/*     */           } else
/* 218 */             System.out.println(objectEntry8.getKey());
/*     */         }
/*     */       }
/*     */       Entry<Object, Object> objectEntry8;
/* 222 */       if (goods.goodsGaiZaoGongMingChengGong != null) {
/* 223 */         map = UtilObjMapshuxing.GoodsGaiZaoGongMingChengGong(goods.goodsGaiZaoGongMingChengGong);
/* 224 */         map.remove("groupNo");
/* 225 */         map.remove("groupType");
/*     */         
/* 227 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsGaiZaoGongMingChengGong.groupNo));
/* 228 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsGaiZaoGongMingChengGong.groupType));
/* 229 */         Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/* 230 */         while (it.hasNext()) {
/* 231 */           objectEntry8 = (Entry)it.next();
/* 232 */           if (objectEntry8.getValue().equals(Integer.valueOf(0))) {
/* 233 */             it.remove();
/*     */           }
/*     */         }
/* 236 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 237 */         for (Entry<Object, Object> objectEntry9 : map.entrySet()) {
/* 238 */           if (BuildFields.data.get((String)objectEntry9.getKey()) != null) {
/* 239 */             BuildFields.get((String)objectEntry9.getKey()).write(writeBuf, objectEntry9.getValue());
/*     */           } else {
/* 241 */             System.out.println(objectEntry9.getKey());
/*     */           }
/*     */         }
/*     */       }
/* 245 */       if (goods.goodsLvSeGongMing != null) {
/* 246 */         map = UtilObjMapshuxing.GoodsLvSeGongMing(goods.goodsLvSeGongMing);
/* 247 */         map.remove("groupNo");
/* 248 */         map.remove("groupType");
/*     */         
/* 250 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsLvSeGongMing.groupNo));
/* 251 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsLvSeGongMing.groupType));
/* 252 */         Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/* 253 */         while (it.hasNext()) {
/* 254 */           objectEntry8 = (Entry)it.next();
/* 255 */           if (objectEntry8.getValue().equals(Integer.valueOf(0))) {
/* 256 */             it.remove();
/*     */           }
/*     */         }
/* 259 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 260 */         for (Entry<Object, Object> objectEntry9 : map.entrySet()) {
/* 261 */           if (BuildFields.data.get((String)objectEntry9.getKey()) != null) {
/* 262 */             BuildFields.get((String)objectEntry9.getKey()).write(writeBuf, objectEntry9.getValue());
/*     */           } else {
/* 264 */             System.out.println(objectEntry9.getKey());
/*     */           }
/*     */         }
/*     */       }
/*     */     }
/*     */   }
/*     */   
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */   public int cmd()
/*     */   {
/* 360 */     return 65525;
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M65525_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */