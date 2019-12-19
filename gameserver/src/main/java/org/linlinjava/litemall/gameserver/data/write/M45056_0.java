/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_45056_0;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class M45056_0 extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     Vo_45056_0 object1 = (Vo_45056_0)object;
/* 13 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.id));
/*    */     
/* 15 */     GameWriteTool.writeString(writeBuf, object1.name);
/*    */     
/* 17 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.portrait));
/*    */     
/* 19 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.pic_no));
/*    */     
/* 21 */     GameWriteTool.writeString2(writeBuf, object1.content);
/*    */     
/* 23 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.isComplete));
/*    */     
/* 25 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.isInCombat));
/*    */     
/* 27 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.playTime));
/*    */     
/* 29 */     GameWriteTool.writeString(writeBuf, object1.task_type);
/*    */   }
/*    */   
/* 32 */   public int cmd() { return 45056; }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M45056_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */