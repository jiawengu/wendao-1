/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_49177_0;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */

/**
 * MSG_SHIDAO_TASK_INFO
 */
/*    */ @org.springframework.stereotype.Service
/*    */ public class M49177_0 extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 13 */     Vo_49177_0 object1 = (Vo_49177_0)object;
/* 14 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.isPK));
/*    */     
/* 16 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.stageId));
/*    */     
/* 18 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.monsterPoint));
/*    */     
/* 20 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.pkValue));
/*    */     
/* 22 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.totalScore));
/*    */     
/* 24 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.startTime));
/*    */     
/* 26 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.stage1_duration_time));
/*    */     
/* 28 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.stage2_duration_time));
/*    */     
/* 30 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.rank));
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 35 */     return 49177;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M49177_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */