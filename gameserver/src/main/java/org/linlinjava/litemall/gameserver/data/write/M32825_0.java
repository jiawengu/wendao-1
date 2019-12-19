/*     */ package org.linlinjava.litemall.gameserver.data.write;
/*     */ 
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_32825_0;
/*     */ 
/*     */ @org.springframework.stereotype.Service
/*     */ public class M32825_0 extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*     */ {
/*     */   protected void writeO(ByteBuf writeBuf, Object object)
/*     */   {
/*  12 */     Vo_32825_0 object1 = (Vo_32825_0)object;
/*  13 */     GameWriteTool.writeString(writeBuf, object1.name0);
/*     */     
/*  15 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.startTime0));
/*     */     
/*  17 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.endTime0));
/*     */     
/*  19 */     GameWriteTool.writeString(writeBuf, object1.name1);
/*     */     
/*  21 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.startTime1));
/*     */     
/*  23 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.endTime1));
/*     */     
/*  25 */     GameWriteTool.writeString(writeBuf, object1.name2);
/*     */     
/*  27 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.startTime2));
/*     */     
/*  29 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.endTime2));
/*     */     
/*  31 */     GameWriteTool.writeString(writeBuf, object1.name3);
/*     */     
/*  33 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.startTime3));
/*     */     
/*  35 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.endTime3));
/*     */     
/*  37 */     GameWriteTool.writeString(writeBuf, object1.name4);
/*     */     
/*  39 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.startTime4));
/*     */     
/*  41 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.endTime4));
/*     */     
/*  43 */     GameWriteTool.writeString(writeBuf, object1.name5);
/*     */     
/*  45 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.startTime5));
/*     */     
/*  47 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.endTime5));
/*     */     
/*  49 */     GameWriteTool.writeString(writeBuf, object1.name6);
/*     */     
/*  51 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.startTime6));
/*     */     
/*  53 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.endTime6));
/*     */     
/*  55 */     GameWriteTool.writeString(writeBuf, object1.name7);
/*     */     
/*  57 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.startTime7));
/*     */     
/*  59 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.endTime7));
/*     */     
/*  61 */     GameWriteTool.writeString(writeBuf, object1.name8);
/*     */     
/*  63 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.startTime8));
/*     */     
/*  65 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.endTime8));
/*     */     
/*  67 */     GameWriteTool.writeString(writeBuf, object1.name9);
/*     */     
/*  69 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.startTime9));
/*     */     
/*  71 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.endTime9));
/*     */     
/*  73 */     GameWriteTool.writeString(writeBuf, object1.name10);
/*     */     
/*  75 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.startTime10));
/*     */     
/*  77 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.endTime10));
/*     */     
/*  79 */     GameWriteTool.writeString(writeBuf, object1.name11);
/*     */     
/*  81 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.startTime11));
/*     */     
/*  83 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.endTime11));
/*     */     
/*  85 */     GameWriteTool.writeString(writeBuf, object1.name12);
/*     */     
/*  87 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.startTime12));
/*     */     
/*  89 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.endTime12));
/*     */     
/*  91 */     GameWriteTool.writeString(writeBuf, object1.name13);
/*     */     
/*  93 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.startTime13));
/*     */     
/*  95 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.endTime13));
/*     */     
/*  97 */     GameWriteTool.writeString(writeBuf, object1.name14);
/*     */     
/*  99 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.startTime14));
/*     */     
/* 101 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.endTime14));
/*     */     
/* 103 */     GameWriteTool.writeString(writeBuf, object1.name15);
/*     */     
/* 105 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.startTime15));
/*     */     
/* 107 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.endTime15));
/*     */     
/* 109 */     GameWriteTool.writeString(writeBuf, object1.name16);
/*     */     
/* 111 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.startTime16));
/*     */     
/* 113 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.endTime16));
/*     */     
/* 115 */     GameWriteTool.writeString(writeBuf, object1.name17);
/*     */     
/* 117 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.startTime17));
/*     */     
/* 119 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.endTime17));
/*     */     
/* 121 */     GameWriteTool.writeString(writeBuf, object1.name18);
/*     */     
/* 123 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.startTime18));
/*     */     
/* 125 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.endTime18));
/*     */   }
/*     */   
/* 128 */   public int cmd() { return 32825; }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M32825_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */