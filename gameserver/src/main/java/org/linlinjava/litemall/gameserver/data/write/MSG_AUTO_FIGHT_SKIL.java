/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_32985_0;
/*    */ //MSG_AUTO_FIGHT_SKIL  -- 通知自动战斗战斗内的技能表现
/*    */ @org.springframework.stereotype.Service
/*    */ public class MSG_AUTO_FIGHT_SKIL extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     Vo_32985_0 object1 = (Vo_32985_0)object;
/* 13 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.user_is_multi));
/*    */     
/* 15 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.user_round));
/*    */     
/* 17 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.user_action));
/*    */     
/* 19 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.user_next_action));
/*    */     
/* 21 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.user_para));
/*    */     
/* 23 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.user_next_para));
/*    */     
/* 25 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.pet_is_multi));
/*    */     
/* 27 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.pet_round));
/*    */     
/* 29 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.pet_action));
/*    */     
/* 31 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.pet_next_action));
/*    */     
/* 33 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.pet_para));
/*    */     
/* 35 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.pet_next_para));
/*    */   }
/*    */   
/* 38 */   public int cmd() { return 32985; }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M32985_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */