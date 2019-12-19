/*     */ package org.linlinjava.litemall.gameserver.data.write;
/*     */ 
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_53475_0;
/*     */ 
/*     */ @org.springframework.stereotype.Service
/*     */ public class M53475_0 extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*     */ {
/*     */   protected void writeO(ByteBuf writeBuf, Object object)
/*     */   {
/*  12 */     Vo_53475_0 object1 = (Vo_53475_0)object;
/*  13 */     GameWriteTool.writeString(writeBuf, object1.name0);
/*     */     
/*  15 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.count0));
/*     */     
/*  17 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.activeValue0));
/*     */     
/*  19 */     GameWriteTool.writeString(writeBuf, object1.timeStr0);
/*     */     
/*  21 */     GameWriteTool.writeString(writeBuf, object1.name1);
/*     */     
/*  23 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.count1));
/*     */     
/*  25 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.activeValue1));
/*     */     
/*  27 */     GameWriteTool.writeString(writeBuf, object1.timeStr1);
/*     */     
/*  29 */     GameWriteTool.writeString(writeBuf, object1.name2);
/*     */     
/*  31 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.count2));
/*     */     
/*  33 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.activeValue2));
/*     */     
/*  35 */     GameWriteTool.writeString(writeBuf, object1.timeStr2);
/*     */     
/*  37 */     GameWriteTool.writeString(writeBuf, object1.name3);
/*     */     
/*  39 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.count3));
/*     */     
/*  41 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.activeValue3));
/*     */     
/*  43 */     GameWriteTool.writeString(writeBuf, object1.timeStr3);
/*     */     
/*  45 */     GameWriteTool.writeString(writeBuf, object1.name4);
/*     */     
/*  47 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.count4));
/*     */     
/*  49 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.activeValue4));
/*     */     
/*  51 */     GameWriteTool.writeString(writeBuf, object1.timeStr4);
/*     */     
/*  53 */     GameWriteTool.writeString(writeBuf, object1.name5);
/*     */     
/*  55 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.count5));
/*     */     
/*  57 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.activeValue5));
/*     */     
/*  59 */     GameWriteTool.writeString(writeBuf, object1.timeStr5);
/*     */     
/*  61 */     GameWriteTool.writeString(writeBuf, object1.name6);
/*     */     
/*  63 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.count6));
/*     */     
/*  65 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.activeValue6));
/*     */     
/*  67 */     GameWriteTool.writeString(writeBuf, object1.timeStr6);
/*     */     
/*  69 */     GameWriteTool.writeString(writeBuf, object1.name7);
/*     */     
/*  71 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.count7));
/*     */     
/*  73 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.activeValue7));
/*     */     
/*  75 */     GameWriteTool.writeString(writeBuf, object1.timeStr7);
/*     */     
/*  77 */     GameWriteTool.writeString(writeBuf, object1.name8);
/*     */     
/*  79 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.count8));
/*     */     
/*  81 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.activeValue8));
/*     */     
/*  83 */     GameWriteTool.writeString(writeBuf, object1.timeStr8);
/*     */     
/*  85 */     GameWriteTool.writeString(writeBuf, object1.name9);
/*     */     
/*  87 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.count9));
/*     */     
/*  89 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.activeValue9));
/*     */     
/*  91 */     GameWriteTool.writeString(writeBuf, object1.timeStr9);
/*     */     
/*  93 */     GameWriteTool.writeString(writeBuf, object1.name10);
/*     */     
/*  95 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.count10));
/*     */     
/*  97 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.activeValue10));
/*     */     
/*  99 */     GameWriteTool.writeString(writeBuf, object1.timeStr10);
/*     */     
/* 101 */     GameWriteTool.writeString(writeBuf, object1.name11);
/*     */     
/* 103 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.count11));
/*     */     
/* 105 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.activeValue11));
/*     */     
/* 107 */     GameWriteTool.writeString(writeBuf, object1.timeStr11);
/*     */     
/* 109 */     GameWriteTool.writeString(writeBuf, object1.name12);
/*     */     
/* 111 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.count12));
/*     */     
/* 113 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.activeValue12));
/*     */     
/* 115 */     GameWriteTool.writeString(writeBuf, object1.timeStr12);
/*     */     
/* 117 */     GameWriteTool.writeString(writeBuf, object1.name13);
/*     */     
/* 119 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.count13));
/*     */     
/* 121 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.activeValue13));
/*     */     
/* 123 */     GameWriteTool.writeString(writeBuf, object1.timeStr13);
/*     */     
/* 125 */     GameWriteTool.writeString(writeBuf, object1.name14);
/*     */     
/* 127 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.count14));
/*     */     
/* 129 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.activeValue14));
/*     */     
/* 131 */     GameWriteTool.writeString(writeBuf, object1.timeStr14);
/*     */     
/* 133 */     GameWriteTool.writeString(writeBuf, object1.name15);
/*     */     
/* 135 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.count15));
/*     */     
/* 137 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.activeValue15));
/*     */     
/* 139 */     GameWriteTool.writeString(writeBuf, object1.timeStr15);
/*     */     
/* 141 */     GameWriteTool.writeString(writeBuf, object1.name16);
/*     */     
/* 143 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.count16));
/*     */     
/* 145 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.activeValue16));
/*     */     
/* 147 */     GameWriteTool.writeString(writeBuf, object1.timeStr16);
/*     */     
/* 149 */     GameWriteTool.writeString(writeBuf, object1.name17);
/*     */     
/* 151 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.count17));
/*     */     
/* 153 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.activeValue17));
/*     */     
/* 155 */     GameWriteTool.writeString(writeBuf, object1.timeStr17);
/*     */     
/* 157 */     GameWriteTool.writeString(writeBuf, object1.name18);
/*     */     
/* 159 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.count18));
/*     */     
/* 161 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.activeValue18));
/*     */     
/* 163 */     GameWriteTool.writeString(writeBuf, object1.timeStr18);
/*     */     
/* 165 */     GameWriteTool.writeString(writeBuf, object1.name19);
/*     */     
/* 167 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.count19));
/*     */     
/* 169 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.activeValue19));
/*     */     
/* 171 */     GameWriteTool.writeString(writeBuf, object1.timeStr19);
/*     */     
/* 173 */     GameWriteTool.writeString(writeBuf, object1.name20);
/*     */     
/* 175 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.count20));
/*     */     
/* 177 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.activeValue20));
/*     */     
/* 179 */     GameWriteTool.writeString(writeBuf, object1.timeStr20);
/*     */     
/* 181 */     GameWriteTool.writeString(writeBuf, object1.name21);
/*     */     
/* 183 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.count21));
/*     */     
/* 185 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.activeValue21));
/*     */     
/* 187 */     GameWriteTool.writeString(writeBuf, object1.timeStr21);
/*     */     
/* 189 */     GameWriteTool.writeString(writeBuf, object1.name22);
/*     */     
/* 191 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.count22));
/*     */     
/* 193 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.activeValue22));
/*     */     
/* 195 */     GameWriteTool.writeString(writeBuf, object1.timeStr22);
/*     */   }
/*     */   
/* 198 */   public int cmd() { return 53475; }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M53475_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */