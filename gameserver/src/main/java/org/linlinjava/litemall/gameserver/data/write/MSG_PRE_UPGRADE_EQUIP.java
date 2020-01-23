/*     */ package org.linlinjava.litemall.gameserver.data.write;
/*     */ 
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import java.io.PrintStream;
/*     */ import java.util.Iterator;
/*     */ import java.util.Map;
/*     */ import java.util.Map.Entry;
/*     */ import java.util.Set;
/*     */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*     */ import org.linlinjava.litemall.gameserver.data.UtilObjMapshuxing;
/*     */ import org.linlinjava.litemall.gameserver.domain.BuildFields;
/*     */ import org.linlinjava.litemall.gameserver.domain.Goods;
/*     */ import org.linlinjava.litemall.gameserver.domain.GoodsGaiZao;
/*     */ import org.linlinjava.litemall.gameserver.domain.GoodsGaiZaoGongMing;
/*     */ import org.linlinjava.litemall.gameserver.domain.GoodsLanSe;
/*     */ 
/*     */ @org.springframework.stereotype.Service
/*     */ public class MSG_PRE_UPGRADE_EQUIP extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*     */ {
/*     */   protected void writeO(ByteBuf writeBuf, Object object)
/*     */   {
/*  22 */     Goods goods = (Goods)object;
/*  23 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.pos));
/*  24 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(3));
/*  25 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(10));
/*  26 */     Map<Object, Object> map = new java.util.HashMap();
/*  27 */     if (goods.goodsInfo != null) {
/*  28 */       map = UtilObjMapshuxing.GoodsInfo(goods.goodsInfo);
/*  29 */       map.remove("groupNo");
/*  30 */       map.remove("groupType");
/*     */       
/*  32 */       GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsInfo.groupNo));
/*  33 */       GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsInfo.groupType));
/*  34 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/*  35 */       for (Entry<Object, Object> entry : map.entrySet()) {
/*  36 */         if (BuildFields.data.get((String)entry.getKey()) != null) {
/*  37 */           BuildFields.get((String)entry.getKey()).write(writeBuf, entry.getValue());
/*     */         } else
/*  39 */           System.out.println(entry.getKey());
/*     */       }
/*     */     }
/*     */     Entry<Object, Object> entry;
/*  43 */     if (goods.goodsBasics != null) {
/*  44 */       map = UtilObjMapshuxing.GoodsBasics(goods.goodsBasics);
/*  45 */       map.remove("groupNo");
/*  46 */       map.remove("groupType");
/*     */       
/*  48 */       GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsBasics.groupNo));
/*  49 */       GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsBasics.groupType));
/*  50 */       Object it = map.entrySet().iterator();
/*  51 */       while (((Iterator)it).hasNext()) {
/*  52 */         entry = (Entry)((Iterator)it).next();
/*  53 */         if (entry.getValue().equals(Integer.valueOf(0))) {
/*  54 */           ((Iterator)it).remove();
/*     */         }
/*     */       }
/*  57 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/*  58 */       for (Entry<Object, Object> objectObjectEntry : map.entrySet()) {
/*  59 */         if (BuildFields.data.get((String)objectObjectEntry.getKey()) != null) {
/*  60 */           BuildFields.get((String)objectObjectEntry.getKey()).write(writeBuf, objectObjectEntry.getValue());
/*     */         } else
/*  62 */           System.out.println(objectObjectEntry.getKey());
/*     */       }
/*     */     }
/*     */     Entry<Object, Object> objectObjectEntry;
/*  66 */     if (goods.goodsLanSe != null) {
/*  67 */       map = UtilObjMapshuxing.GoodsLanSe(goods.goodsLanSe);
/*  68 */       map.remove("groupNo");
/*  69 */       map.remove("groupType");
/*     */       
/*  71 */       GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsLanSe.groupNo));
/*  72 */       GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsLanSe.groupType));
/*  73 */       Object it = map.entrySet().iterator();
/*  74 */       while (((Iterator)it).hasNext()) {
/*  75 */         objectObjectEntry = (Entry)((Iterator)it).next();
/*  76 */         if (objectObjectEntry.getValue().equals(Integer.valueOf(0))) {
/*  77 */           ((Iterator)it).remove();
/*     */         }
/*     */       }
/*  80 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/*  81 */       for (Entry<Object, Object> objectObjectEntry1 : map.entrySet()) {
/*  82 */         if (BuildFields.data.get((String)objectObjectEntry1.getKey()) != null) {
/*  83 */           BuildFields.get((String)objectObjectEntry1.getKey()).write(writeBuf, objectObjectEntry1.getValue());
/*     */         } else {
/*  85 */           System.out.println(objectObjectEntry1.getKey());
/*     */         }
/*     */       }
/*     */     }
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
/*     */     Entry<Object, Object> objectObjectEntry1;
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
/* 158 */     if (goods.goodsGaiZao != null) {
/* 159 */       map = UtilObjMapshuxing.GoodsGaiZao(goods.goodsGaiZao);
/* 160 */       map.remove("groupNo");
/* 161 */       map.remove("groupType");
/*     */       
/* 163 */       GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsGaiZao.groupNo));
/* 164 */       GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsGaiZao.groupType));
/* 165 */       Object it = map.entrySet().iterator();
/* 166 */       while (((Iterator)it).hasNext()) {
/* 167 */         objectObjectEntry1 = (Entry)((Iterator)it).next();
/* 168 */         if (objectObjectEntry1.getValue().equals(Integer.valueOf(0))) {
/* 169 */           ((Iterator)it).remove();
/*     */         }
/*     */       }
/* 172 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 173 */       for (Entry<Object, Object> objectObjectEntry2 : map.entrySet()) {
/* 174 */         if (BuildFields.data.get((String)objectObjectEntry2.getKey()) != null) {
/* 175 */           BuildFields.get((String)objectObjectEntry2.getKey()).write(writeBuf, objectObjectEntry2.getValue());
/*     */         } else
/* 177 */           System.out.println(objectObjectEntry2.getKey());
/*     */       }
/*     */     }
/*     */     Entry<Object, Object> objectObjectEntry2;
/* 181 */     if (goods.goodsGaiZaoGongMing != null) {
/* 182 */       map = UtilObjMapshuxing.GoodsGaiZaoGongMing(goods.goodsGaiZaoGongMing);
/* 183 */       map.remove("groupNo");
/* 184 */       map.remove("groupType");
/*     */       
/* 186 */       GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsGaiZaoGongMing.groupNo));
/* 187 */       GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsGaiZaoGongMing.groupType));
/* 188 */       Object it = map.entrySet().iterator();
/* 189 */       while (((Iterator)it).hasNext()) {
/* 190 */         objectObjectEntry2 = (Entry)((Iterator)it).next();
/* 191 */         if (objectObjectEntry2.getValue().equals(Integer.valueOf(0))) {
/* 192 */           ((Iterator)it).remove();
/*     */         }
/*     */       }
/* 195 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 196 */       for (Entry<Object, Object> objectObjectEntry3 : map.entrySet()) {
/* 197 */         if (BuildFields.data.get((String)objectObjectEntry3.getKey()) != null) {
/* 198 */           BuildFields.get((String)objectObjectEntry3.getKey()).write(writeBuf, objectObjectEntry3.getValue());
/*     */         } else
/* 200 */           System.out.println(objectObjectEntry3.getKey());
/*     */       }
/*     */     }
/*     */     Entry<Object, Object> objectObjectEntry3;
/* 204 */     if (goods.goodsGaiZaoGongMingChengGong != null) {
/* 205 */       map = UtilObjMapshuxing.GoodsGaiZaoGongMingChengGong(goods.goodsGaiZaoGongMingChengGong);
/* 206 */       map.remove("groupNo");
/* 207 */       map.remove("groupType");
/*     */       
/* 209 */       GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsGaiZaoGongMingChengGong.groupNo));
/* 210 */       GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsGaiZaoGongMingChengGong.groupType));
/* 211 */       Object it = map.entrySet().iterator();
/* 212 */       while (((Iterator)it).hasNext()) {
/* 213 */         objectObjectEntry3 = (Entry)((Iterator)it).next();
/* 214 */         if (objectObjectEntry3.getValue().equals(Integer.valueOf(0))) {
/* 215 */           ((Iterator)it).remove();
/*     */         }
/*     */       }
/* 218 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 219 */       for (Entry<Object, Object> objectObjectEntry4 : map.entrySet()) {
/* 220 */         if (BuildFields.data.get((String)objectObjectEntry4.getKey()) != null) {
/* 221 */           BuildFields.get((String)objectObjectEntry4.getKey()).write(writeBuf, objectObjectEntry4.getValue());
/*     */         } else
/* 223 */           System.out.println(objectObjectEntry4.getKey());
/*     */       }
/*     */     }
/*     */     Entry<Object, Object> objectObjectEntry4;
/* 227 */     if (goods.goodsLvSeGongMing != null) {
/* 228 */       map = UtilObjMapshuxing.GoodsLvSeGongMing(goods.goodsLvSeGongMing);
/* 229 */       map.remove("groupNo");
/* 230 */       map.remove("groupType");
/*     */       
/* 232 */       GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsLvSeGongMing.groupNo));
/* 233 */       GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsLvSeGongMing.groupType));
/* 234 */       Object it = map.entrySet().iterator();
/* 235 */       while (((Iterator)it).hasNext()) {
/* 236 */         objectObjectEntry4 = (Entry)((Iterator)it).next();
/* 237 */         if (objectObjectEntry4.getValue().equals(Integer.valueOf(0))) {
/* 238 */           ((Iterator)it).remove();
/*     */         }
/*     */       }
/* 241 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 242 */       for (Entry<Object, Object> objectObjectEntry5 : map.entrySet()) {
/* 243 */         if (BuildFields.data.get((String)objectObjectEntry5.getKey()) != null) {
/* 244 */           BuildFields.get((String)objectObjectEntry5.getKey()).write(writeBuf, objectObjectEntry5.getValue());
/*     */         } else {
/* 246 */           System.out.println(objectObjectEntry5.getKey());
/*     */         }
/*     */       }
/*     */     }
/*     */   }
/*     */   
/*     */   public int cmd()
/*     */   {
/* 254 */     return 32775;
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M32775_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */