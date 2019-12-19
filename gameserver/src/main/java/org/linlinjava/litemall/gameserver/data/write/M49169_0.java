/*     */ package org.linlinjava.litemall.gameserver.data.write;
/*     */ 
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_49169_0;
/*     */ 
/*     */ @org.springframework.stereotype.Service
/*     */ public class M49169_0 extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*     */ {
/*     */   protected void writeO(ByteBuf writeBuf, Object object)
/*     */   {
/*  12 */     Vo_49169_0 object1 = (Vo_49169_0)object;
/*  13 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.monthDays));
/*     */     
/*  15 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.signDays));
/*     */     
/*  17 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.isCanSgin));
/*     */     
/*  19 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.isCanReplenishSign));
/*     */     
/*  21 */     GameWriteTool.writeString(writeBuf, object1.name0);
/*     */     
/*  23 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.number0));
/*     */     
/*  25 */     GameWriteTool.writeString(writeBuf, object1.name1);
/*     */     
/*  27 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.number1));
/*     */     
/*  29 */     GameWriteTool.writeString(writeBuf, object1.name2);
/*     */     
/*  31 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.number2));
/*     */     
/*  33 */     GameWriteTool.writeString(writeBuf, object1.name3);
/*     */     
/*  35 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.number3));
/*     */     
/*  37 */     GameWriteTool.writeString(writeBuf, object1.name4);
/*     */     
/*  39 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.number4));
/*     */     
/*  41 */     GameWriteTool.writeString(writeBuf, object1.name5);
/*     */     
/*  43 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.number5));
/*     */     
/*  45 */     GameWriteTool.writeString(writeBuf, object1.name6);
/*     */     
/*  47 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.number6));
/*     */     
/*  49 */     GameWriteTool.writeString(writeBuf, object1.name7);
/*     */     
/*  51 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.number7));
/*     */     
/*  53 */     GameWriteTool.writeString(writeBuf, object1.name8);
/*     */     
/*  55 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.number8));
/*     */     
/*  57 */     GameWriteTool.writeString(writeBuf, object1.name9);
/*     */     
/*  59 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.number9));
/*     */     
/*  61 */     GameWriteTool.writeString(writeBuf, object1.name10);
/*     */     
/*  63 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.number10));
/*     */     
/*  65 */     GameWriteTool.writeString(writeBuf, object1.name11);
/*     */     
/*  67 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.number11));
/*     */     
/*  69 */     GameWriteTool.writeString(writeBuf, object1.name12);
/*     */     
/*  71 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.number12));
/*     */     
/*  73 */     GameWriteTool.writeString(writeBuf, object1.name13);
/*     */     
/*  75 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.number13));
/*     */     
/*  77 */     GameWriteTool.writeString(writeBuf, object1.name14);
/*     */     
/*  79 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.number14));
/*     */     
/*  81 */     GameWriteTool.writeString(writeBuf, object1.name15);
/*     */     
/*  83 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.number15));
/*     */     
/*  85 */     GameWriteTool.writeString(writeBuf, object1.name16);
/*     */     
/*  87 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.number16));
/*     */     
/*  89 */     GameWriteTool.writeString(writeBuf, object1.name17);
/*     */     
/*  91 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.number17));
/*     */     
/*  93 */     GameWriteTool.writeString(writeBuf, object1.name18);
/*     */     
/*  95 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.number18));
/*     */     
/*  97 */     GameWriteTool.writeString(writeBuf, object1.name19);
/*     */     
/*  99 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.number19));
/*     */     
/* 101 */     GameWriteTool.writeString(writeBuf, object1.name20);
/*     */     
/* 103 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.number20));
/*     */     
/* 105 */     GameWriteTool.writeString(writeBuf, object1.name21);
/*     */     
/* 107 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.number21));
/*     */     
/* 109 */     GameWriteTool.writeString(writeBuf, object1.name22);
/*     */     
/* 111 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.number22));
/*     */     
/* 113 */     GameWriteTool.writeString(writeBuf, object1.name23);
/*     */     
/* 115 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.number23));
/*     */     
/* 117 */     GameWriteTool.writeString(writeBuf, object1.name24);
/*     */     
/* 119 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.number24));
/*     */     
/* 121 */     GameWriteTool.writeString(writeBuf, object1.name25);
/*     */     
/* 123 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.number25));
/*     */     
/* 125 */     GameWriteTool.writeString(writeBuf, object1.name26);
/*     */     
/* 127 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.number26));
/*     */     
/* 129 */     GameWriteTool.writeString(writeBuf, object1.name27);
/*     */     
/* 131 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.number27));
/*     */     
/* 133 */     GameWriteTool.writeString(writeBuf, object1.name28);
/*     */     
/* 135 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.number28));
/*     */     
/* 137 */     GameWriteTool.writeString(writeBuf, object1.name29);
/*     */     
/* 139 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.number29));
/*     */     
/* 141 */     GameWriteTool.writeString(writeBuf, object1.name30);
/*     */     
/* 143 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.number30));
/*     */   }
/*     */   
/* 146 */   public int cmd() { return 49169; }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M49169_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */