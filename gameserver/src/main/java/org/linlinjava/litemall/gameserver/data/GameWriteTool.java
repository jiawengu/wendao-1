/*    */ package org.linlinjava.litemall.gameserver.data;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import java.nio.charset.Charset;
/*    */ import java.util.List;
/*    */ 
/*    */ public class GameWriteTool
/*    */ {
/*  9 */   public static final Charset DEFAULT_CHARSET = Charset.forName("GBK");
/*    */   public static final int INT = 4;
/*    */   
/*    */   public static final boolean writeArraySize(ByteBuf buff, List<?> list) {
/*    */     try {
/* 14 */       buff.writeByte(list.size());
/* 15 */       return true;
/*    */     } catch (NullPointerException e) {
/* 17 */       buff.writeByte(0); }
/* 18 */     return false;
/*    */   }
/*    */   
/*    */   public static final void writeInt(ByteBuf buff, Integer value)
/*    */   {
/* 23 */     if (value == null) {
/* 24 */       value = Integer.valueOf(0);
/*    */     }
/* 26 */     buff.writeInt(value.intValue());
/*    */   }
/*    */   
/*    */   public static final void writeString(ByteBuf buff, String value) {
/* 30 */     if (value == null) {
/* 31 */       buff.writeByte(0);
/* 32 */       return;
/*    */     }
/* 34 */     byte[] bytes = value.getBytes(DEFAULT_CHARSET);
/*    */     
/* 36 */     buff.writeByte(bytes.length);
/* 37 */     buff.writeBytes(bytes);
/*    */   }
/*    */   
/*    */   public static final void writeString2(ByteBuf buff, String value) {
/* 41 */     if (value == null) {
/* 42 */       buff.writeShort(0);
/* 43 */       return;
/*    */     }
/* 45 */     byte[] bytes = value.getBytes(DEFAULT_CHARSET);
/*    */     
/* 47 */     buff.writeShort(bytes.length);
/* 48 */     buff.writeBytes(bytes);
/*    */   }
/*    */   
/*    */   public static final void writeLong(ByteBuf buff, Long value)
/*    */   {
/* 53 */     if (value == null) {
/* 54 */       value = Long.valueOf(0L);
/*    */     }
/* 56 */     buff.writeLong(value.longValue());
/*    */   }
/*    */   
/*    */   public static final void writeShort(ByteBuf buff, Integer value) {
/* 60 */     if (value == null) {
/* 61 */       value = Integer.valueOf(0);
/*    */     }
/* 63 */     buff.writeShort(value.intValue());
/*    */   }
/*    */   
/*    */   public static final void writeByte(ByteBuf buff, Integer value) {
/* 67 */     if (value == null) {
/* 68 */       value = Integer.valueOf(0);
/*    */     }
/* 70 */     buff.writeByte(value.intValue());
/*    */   }
/*    */   
/*    */   public static final void writeBoolean(ByteBuf buff, boolean value) {
/* 74 */     if (value) {
/* 75 */       buff.writeByte(1);
/*    */     } else {
/* 77 */       buff.writeByte(0);
/*    */     }
/*    */   }
/*    */   
/*    */   public static final void writeZero(ByteBuf buff, Integer length) {
/* 82 */     buff.writeZero(length.intValue());
/*    */   }
/*    */   
/*    */   public static final byte[] toArray(ByteBuf buff) {
/* 86 */     byte[] b = new byte[buff.readableBytes()];
/* 87 */     buff.readBytes(b);
/* 88 */     return b;
/*    */   }
/*    */   
/*    */ 
/* 92 */   public static void writeBytes(ByteBuf writeBuf, byte[] bytes) { writeBuf.writeBytes(bytes); }
/*    */   
/*    */   public static void writeLenBuffer2(ByteBuf writeBuf, byte[] bytes) {
/* 95 */     writeBuf.writeShort(bytes.length);
/* 96 */     writeBuf.writeBytes(bytes);
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\GameWriteTool.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */