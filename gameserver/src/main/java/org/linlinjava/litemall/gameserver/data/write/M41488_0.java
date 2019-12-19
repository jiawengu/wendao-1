/*     */ package org.linlinjava.litemall.gameserver.data.write;
/*     */ 
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_41488_0;
/*     */ 
/*     */ @org.springframework.stereotype.Service
/*     */ public class M41488_0 extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*     */ {
/*     */   protected void writeO(ByteBuf writeBuf, Object object)
/*     */   {
/*  12 */     Vo_41488_0 object1 = (Vo_41488_0)object;
/*  13 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.flag));
/*     */     
/*  15 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.label));
/*     */     
/*  17 */     GameWriteTool.writeString(writeBuf, object1.para);
/*     */     
/*  19 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.count2));
/*     */     
/*  21 */     GameWriteTool.writeString(writeBuf, object1.name0);
/*     */     
/*  23 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.goods_price0));
/*     */     
/*  25 */     GameWriteTool.writeString(writeBuf, object1.name1);
/*     */     
/*  27 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.goods_price1));
/*     */     
/*  29 */     GameWriteTool.writeString(writeBuf, object1.name2);
/*     */     
/*  31 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.goods_price2));
/*     */     
/*  33 */     GameWriteTool.writeString(writeBuf, object1.name3);
/*     */     
/*  35 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.goods_price3));
/*     */     
/*  37 */     GameWriteTool.writeString(writeBuf, object1.name4);
/*     */     
/*  39 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.goods_price4));
/*     */     
/*  41 */     GameWriteTool.writeString(writeBuf, object1.name5);
/*     */     
/*  43 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.goods_price5));
/*     */     
/*  45 */     GameWriteTool.writeString(writeBuf, object1.name6);
/*     */     
/*  47 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.goods_price6));
/*     */     
/*  49 */     GameWriteTool.writeString(writeBuf, object1.name7);
/*     */     
/*  51 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.goods_price7));
/*     */     
/*  53 */     GameWriteTool.writeString(writeBuf, object1.name8);
/*     */     
/*  55 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.goods_price8));
/*     */     
/*  57 */     GameWriteTool.writeString(writeBuf, object1.name9);
/*     */     
/*  59 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.goods_price9));
/*     */     
/*  61 */     GameWriteTool.writeString(writeBuf, object1.name10);
/*     */     
/*  63 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.goods_price10));
/*     */     
/*  65 */     GameWriteTool.writeString(writeBuf, object1.name11);
/*     */     
/*  67 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.goods_price11));
/*     */     
/*  69 */     GameWriteTool.writeString(writeBuf, object1.name12);
/*     */     
/*  71 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.goods_price12));
/*     */     
/*  73 */     GameWriteTool.writeString(writeBuf, object1.name13);
/*     */     
/*  75 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.goods_price13));
/*     */     
/*  77 */     GameWriteTool.writeString(writeBuf, object1.name14);
/*     */     
/*  79 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.goods_price14));
/*     */     
/*  81 */     GameWriteTool.writeString(writeBuf, object1.name15);
/*     */     
/*  83 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.goods_price15));
/*     */     
/*  85 */     GameWriteTool.writeString(writeBuf, object1.name16);
/*     */     
/*  87 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.goods_price16));
/*     */     
/*  89 */     GameWriteTool.writeString(writeBuf, object1.name17);
/*     */     
/*  91 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.goods_price17));
/*     */     
/*  93 */     GameWriteTool.writeString(writeBuf, object1.name18);
/*     */     
/*  95 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.goods_price18));
/*     */     
/*  97 */     GameWriteTool.writeString(writeBuf, object1.name19);
/*     */     
/*  99 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.goods_price19));
/*     */   }
/*     */   
/* 102 */   public int cmd() { return 41488; }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M41488_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */