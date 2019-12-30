/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.db.domain.Npc;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ import org.springframework.stereotype.Service;
/*    */

/**
 * MSG_APPEAR
 */
/*    */ @Service
/*    */ public class M65529_npc
/*    */   extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 15 */     Npc npc = (Npc)object;
/*    */     
/* 17 */     GameWriteTool.writeInt(writeBuf, npc.getId());
/*    */     
/* 19 */     GameWriteTool.writeShort(writeBuf, npc.getX());
/*    */     
/* 21 */     GameWriteTool.writeShort(writeBuf, npc.getY());
/*    */     
/* 23 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(7));
/*    */     
/* 25 */     GameWriteTool.writeInt(writeBuf, npc.getIcon());
/*    */     
/* 27 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(0));
/*    */     
/* 29 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(4));
/*    */     
/* 31 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(0));
/*    */     
/* 33 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(0));
/*    */     
/* 35 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(0));
/*    */     
/* 37 */     GameWriteTool.writeString(writeBuf, npc.getName());
/*    */     
/* 39 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(0));
/*    */     
/* 41 */     GameWriteTool.writeString(writeBuf, "");
/*    */     
/* 43 */     GameWriteTool.writeString(writeBuf, "");
/*    */     
/* 45 */     GameWriteTool.writeString(writeBuf, "");
/*    */     
/* 47 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(0));
/*    */     
/* 49 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(0));
/*    */     
/* 51 */     GameWriteTool.writeInt(writeBuf, npc.getIcon());
/*    */     
/* 53 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(0));
/*    */     
/* 55 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(0));
/*    */     
/* 57 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(0));
/*    */     
/* 59 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(0));
/*    */     
/* 61 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(0));
/*    */     
/* 63 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(0));
/*    */     
/* 65 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(0));
/*    */     
/* 67 */     GameWriteTool.writeString(writeBuf, "");
/*    */     
/* 69 */     GameWriteTool.writeString(writeBuf, "");
/*    */     
/* 71 */     GameWriteTool.writeString(writeBuf, "");
/*    */     
/* 73 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(0));
/*    */     
/* 75 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(0));
/*    */     
/* 77 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(0));
/*    */     
/* 79 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(0));
/*    */     
/* 81 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(0));
/*    */     
/* 83 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(0));
/*    */     
/* 85 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(0));
/*    */     
/* 87 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(0));
/*    */     
/* 89 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(0));
/*    */     
/* 91 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(0));
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 96 */     return 65529;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M65529_npc.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */