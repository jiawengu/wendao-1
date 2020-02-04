/*     */ package org.linlinjava.litemall.gameserver.data.write;
/*     */ 
/*     */ import java.io.PrintStream;
/*     */ import java.util.HashMap;
/*     */ import java.util.Iterator;
/*     */ import java.util.List;
/*     */ import java.util.Map;
/*     */ import java.util.Map.Entry;
/*     */ import java.util.Set;
/*     */ import org.apache.commons.lang3.StringUtils;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*     */ import org.linlinjava.litemall.gameserver.data.UtilObjMapshuxing;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61677_0;
/*     */ import org.linlinjava.litemall.gameserver.domain.BuildFields;
/*     */ import org.linlinjava.litemall.gameserver.domain.Goods;
/*     */ import org.linlinjava.litemall.gameserver.domain.GoodsGaiZaoGongMing;

/*     */
/*     */ @org.springframework.stereotype.Service
/*     */ public class M61677_0 extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*     */ {
/*     */   protected void writeO(io.netty.buffer.ByteBuf writeBuf, Object object)
/*     */   {
/*  22 */     Vo_61677_0 object1 = (Vo_61677_0)object;
/*  23 */     GameWriteTool.writeString(writeBuf, object1.store_type);
/*     */     
/*  25 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.npcID));
/*     */     
/*  27 */     List<Goods> list = object1.list;
/*     */     
/*  29 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.count));
/*     */     
/*     */     Entry<Object, Object> entry;
/*  32 */     for (int j = 0; j < list.size(); j++) {
/*  33 */       Goods goods = (Goods)list.get(j);
/*  34 */       GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.isGoon));
/*  35 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(goods.pos));
/*  36 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(10));
/*  37 */       Map<Object, Object> map = new HashMap();
/*  38 */       Entry<Object, Object> objectEntry; if (goods.goodsInfo != null) {
/*  39 */         map = UtilObjMapshuxing.GoodsInfo(goods.goodsInfo);
/*  40 */         map.remove("groupNo");
/*  41 */         map.remove("groupType");
/*  42 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsInfo.groupNo));
/*  43 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsInfo.groupType));
/*  44 */         Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/*  45 */         while (it.hasNext()) {
/*  46 */           objectEntry = (Entry)it.next();
/*  47 */           if ((objectEntry.getValue().equals(Integer.valueOf(0))) && (objectEntry.getKey().equals("silver_coin"))) {
/*  48 */             it.remove();
/*     */           }
/*     */         }
/*  51 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/*  52 */         for (Entry<Object, Object> objectEntry1 : map.entrySet()) {
/*  53 */           if (BuildFields.data.get((String)objectEntry1.getKey()) != null) {
/*  54 */             BuildFields.get((String)objectEntry1.getKey()).write(writeBuf, objectEntry1.getValue());
/*     */           } else
/*  56 */             System.out.println(objectEntry1.getKey());
/*     */         }
/*     */       }
/*     */       Entry<Object, Object> objectObjectEntry;
/*  60 */       if (goods.goodsBasics != null) {
/*  61 */         map = UtilObjMapshuxing.GoodsBasics(goods.goodsBasics);
/*  62 */         map.remove("groupNo");
/*  63 */         map.remove("groupType");
/*     */         
/*  65 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsBasics.groupNo));
/*  66 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsBasics.groupType));
/*  67 */         Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/*  68 */         while (it.hasNext()) {
/*  69 */           objectObjectEntry = (Entry)it.next();
/*  70 */           if (objectObjectEntry.getValue().equals(Integer.valueOf(0))) {
/*  71 */             it.remove();
/*     */           }
/*     */         }
/*  74 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/*  75 */         for (Entry<Object, Object> objectEntry1 : map.entrySet()) {
/*  76 */           if (BuildFields.data.get((String)objectEntry1.getKey()) != null) {
/*  77 */             BuildFields.get((String)objectEntry1.getKey()).write(writeBuf, objectEntry1.getValue());
/*     */           } else
/*  79 */             System.out.println(objectEntry1.getKey());
/*     */         }
/*     */       }
/*     */       Entry<Object, Object> objectObjectEntry1;
/*  83 */       if (goods.goodsLanSe != null) {
/*  84 */         map = UtilObjMapshuxing.GoodsLanSe(goods.goodsLanSe);
/*  85 */         map.remove("groupNo");
/*  86 */         map.remove("groupType");
/*     */         
/*  88 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsLanSe.groupNo));
/*  89 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsLanSe.groupType));
/*  90 */         Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/*  91 */         while (it.hasNext()) {
/*  92 */           objectObjectEntry1 = (Entry)it.next();
/*  93 */           if (objectObjectEntry1.getValue().equals(Integer.valueOf(0))) {
/*  94 */             it.remove();
/*     */           }
/*     */         }
/*  97 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/*  98 */         for (Entry<Object, Object> objectObjectEntry2 : map.entrySet()) {
/*  99 */           if (BuildFields.data.get((String)objectObjectEntry2.getKey()) != null) {
/* 100 */             BuildFields.get((String)objectObjectEntry2.getKey()).write(writeBuf, objectObjectEntry2.getValue());
/*     */           } else
/* 102 */             System.out.println(objectObjectEntry2.getKey());
/*     */         }
/*     */       }
/*     */       Entry<Object, Object> objectObjectEntry2;
/* 106 */       if (goods.goodsFenSe != null) {
/* 107 */         map = UtilObjMapshuxing.GoodsFenSe(goods.goodsFenSe);
/* 108 */         map.remove("groupNo");
/* 109 */         map.remove("groupType");
/*     */         
/* 111 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsFenSe.groupNo));
/* 112 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsFenSe.groupType));
/* 113 */         Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/* 114 */         while (it.hasNext()) {
/* 115 */           objectObjectEntry2 = (Entry)it.next();
/* 116 */           if (objectObjectEntry2.getValue().equals(Integer.valueOf(0))) {
/* 117 */             it.remove();
/*     */           }
/*     */         }
/* 120 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 121 */         for (Entry<Object, Object> objectObjectEntry3 : map.entrySet()) {
/* 122 */           if (BuildFields.data.get((String)objectObjectEntry3.getKey()) != null) {
/* 123 */             BuildFields.get((String)objectObjectEntry3.getKey()).write(writeBuf, objectObjectEntry3.getValue());
/*     */           } else
/* 125 */             System.out.println(objectObjectEntry3.getKey());
/*     */         }
/*     */       }
/*     */       Entry<Object, Object> objectObjectEntry3;
/* 129 */       if (goods.goodsHuangSe != null) {
/* 130 */         map = UtilObjMapshuxing.GoodsHuangSe(goods.goodsHuangSe);
/* 131 */         map.remove("groupNo");
/* 132 */         map.remove("groupType");
/*     */         
/* 134 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsHuangSe.groupNo));
/* 135 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsHuangSe.groupType));
/* 136 */         Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/* 137 */         while (it.hasNext()) {
/* 138 */           objectObjectEntry3 = (Entry)it.next();
/* 139 */           if (objectObjectEntry3.getValue().equals(Integer.valueOf(0))) {
/* 140 */             it.remove();
/*     */           }
/*     */         }
/* 143 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 144 */         for (Entry<Object, Object> objectObjectEntry4 : map.entrySet()) {
/* 145 */           if (BuildFields.data.get((String)objectObjectEntry4.getKey()) != null) {
/* 146 */             BuildFields.get((String)objectObjectEntry4.getKey()).write(writeBuf, objectObjectEntry4.getValue());
/*     */           } else
/* 148 */             System.out.println(objectObjectEntry4.getKey());
/*     */         }
/*     */       }
/*     */       Entry<Object, Object> objectObjectEntry4;
/* 152 */       if (goods.goodsLvSe != null) {
/* 153 */         map = UtilObjMapshuxing.GoodsLvSe(goods.goodsLvSe);
/* 154 */         map.remove("groupNo");
/* 155 */         map.remove("groupType");
/*     */         
/* 157 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsLvSe.groupNo));
/* 158 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsLvSe.groupType));
/* 159 */         Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/* 160 */         while (it.hasNext()) {
/* 161 */           objectObjectEntry4 = (Entry)it.next();
/* 162 */           if (objectObjectEntry4.getValue().equals(Integer.valueOf(0))) {
/* 163 */             it.remove();
/*     */           }
/*     */         }
/* 166 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 167 */         for (Entry<Object, Object> objectObjectEntry5 : map.entrySet()) {
/* 168 */           if (BuildFields.data.get((String)objectObjectEntry5.getKey()) != null) {
/* 169 */             BuildFields.get((String)objectObjectEntry5.getKey()).write(writeBuf, objectObjectEntry5.getValue());
/*     */           } else
/* 171 */             System.out.println(objectObjectEntry5.getKey());
/*     */         }
/*     */       }
/*     */       Entry<Object, Object> objectObjectEntry5;
/* 175 */       if (goods.goodsGaiZao != null) {
/* 176 */         map = UtilObjMapshuxing.GoodsGaiZao(goods.goodsGaiZao);
/* 177 */         map.remove("groupNo");
/* 178 */         map.remove("groupType");
/*     */         
/* 180 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsGaiZao.groupNo));
/* 181 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsGaiZao.groupType));
/* 182 */         Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/* 183 */         while (it.hasNext()) {
/* 184 */           objectObjectEntry5 = (Entry)it.next();
/* 185 */           if (objectObjectEntry5.getValue().equals(Integer.valueOf(0))) {
/* 186 */             it.remove();
/*     */           }
/*     */         }
/* 189 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 190 */         for (Entry<Object, Object> objectObjectEntry6 : map.entrySet()) {
/* 191 */           if (BuildFields.data.get((String)objectObjectEntry6.getKey()) != null) {
/* 192 */             BuildFields.get((String)objectObjectEntry6.getKey()).write(writeBuf, objectObjectEntry6.getValue());
/*     */           } else
/* 194 */             System.out.println(objectObjectEntry6.getKey());
/*     */         }
/*     */       }
/*     */       Entry<Object, Object> objectObjectEntry6;
/* 198 */       if (goods.goodsGaiZaoGongMing != null) {
/* 199 */         map = UtilObjMapshuxing.GoodsGaiZaoGongMing(goods.goodsGaiZaoGongMing);
/* 200 */         map.remove("groupNo");
/* 201 */         map.remove("groupType");
/*     */         
/* 203 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsGaiZaoGongMing.groupNo));
/* 204 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsGaiZaoGongMing.groupType));
/* 205 */         Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/* 206 */         while (it.hasNext()) {
/* 207 */           objectObjectEntry6 = (Entry)it.next();
/* 208 */           if (objectObjectEntry6.getValue().equals(Integer.valueOf(0))) {
/* 209 */             it.remove();
/*     */           }
/*     */         }
/* 212 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 213 */         for (Entry<Object, Object> objectObjectEntry7 : map.entrySet()) {
/* 214 */           if (BuildFields.data.get((String)objectObjectEntry7.getKey()) != null) {
/* 215 */             BuildFields.get((String)objectObjectEntry7.getKey()).write(writeBuf, objectObjectEntry7.getValue());
/*     */           } else
/* 217 */             System.out.println(objectObjectEntry7.getKey());
/*     */         }
/*     */       }
/*     */       Entry<Object, Object> objectObjectEntry7;
/* 221 */       if (goods.goodsGaiZaoGongMingChengGong != null) {
/* 222 */         map = UtilObjMapshuxing.GoodsGaiZaoGongMingChengGong(goods.goodsGaiZaoGongMingChengGong);
/* 223 */         map.remove("groupNo");
/* 224 */         map.remove("groupType");
/*     */         
/* 226 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsGaiZaoGongMingChengGong.groupNo));
/* 227 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsGaiZaoGongMingChengGong.groupType));
/* 228 */         Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/* 229 */         while (it.hasNext()) {
/* 230 */           objectObjectEntry7 = (Entry)it.next();
/* 231 */           if (objectObjectEntry7.getValue().equals(Integer.valueOf(0))) {
/* 232 */             it.remove();
/*     */           }
/*     */         }
/* 235 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 236 */         for (Entry<Object, Object> objectObjectEntry8 : map.entrySet()) {
/* 237 */           if (BuildFields.data.get((String)objectObjectEntry8.getKey()) != null) {
/* 238 */             BuildFields.get((String)objectObjectEntry8.getKey()).write(writeBuf, objectObjectEntry8.getValue());
/*     */           } else {
/* 240 */             System.out.println(objectObjectEntry8.getKey());
/*     */           }
/*     */         }
/*     */       }
/* 244 */       if (goods.goodsLvSeGongMing != null) {
/* 245 */         map = UtilObjMapshuxing.GoodsLvSeGongMing(goods.goodsLvSeGongMing);
/* 246 */         map.remove("groupNo");
/* 247 */         map.remove("groupType");
/*     */         
/* 249 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsLvSeGongMing.groupNo));
/* 250 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(goods.goodsLvSeGongMing.groupType));
/* 251 */         Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/* 252 */         while (it.hasNext()) {
/* 253 */           objectObjectEntry7 = (Entry)it.next();
/* 254 */           if (objectObjectEntry7.getValue().equals(Integer.valueOf(0))) {
/* 255 */             it.remove();
/*     */           }
/*     */         }
/* 258 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/* 259 */         for (Entry<Object, Object> objectObjectEntry8 : map.entrySet()) {
/* 260 */           if (BuildFields.data.get((String)objectObjectEntry8.getKey()) != null) {
/* 261 */             BuildFields.get((String)objectObjectEntry8.getKey()).write(writeBuf, objectObjectEntry8.getValue());
/*     */           } else {
/* 263 */             System.out.println(objectObjectEntry8.getKey());
/*     */           }
/*     */         }
/*     */       }
/*     */     }
/* 268 */     for (int i = 201; i < 335; i++) {
/* 269 */       if (weizhi(list, i)) {
/* 270 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.isGoon));
/* 271 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(i));
/* 272 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(0));
/*     */       }
/*     */     }

                if(StringUtils.equals(object1.store_type, "home_store")){
                    for (int i = 501; i < 501 + object1.count; i++) {
                        if (weizhi(list, i)) {
                            GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.isGoon));
                            GameWriteTool.writeShort(writeBuf, Integer.valueOf(i));
                            GameWriteTool.writeShort(writeBuf, Integer.valueOf(0));
                        }
                    }
                }
}

/*     *
}/   }
/*     */   
/*     */   public int cmd()
/*     */   {
/* 279 */     return 61677;
/*     */   }
/*     */   
/*     */   public boolean weizhi(List<Goods> list, int j) {
/* 283 */     HashMap<Object, Object> map = new HashMap();
/* 284 */     for (int i = 0; i < list.size(); i++) {
/* 285 */       map.put(Integer.valueOf(((Goods)list.get(i)).pos), Integer.valueOf(((Goods)list.get(i)).pos));
/*     */     }
/* 287 */     if (map.get(Integer.valueOf(j)) == null) {
/* 288 */       return true;
/*     */     }
/* 290 */     return false;
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M61677_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */