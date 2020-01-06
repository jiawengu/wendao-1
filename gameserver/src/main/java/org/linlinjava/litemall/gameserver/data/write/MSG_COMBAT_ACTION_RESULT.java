/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_53717_0;
/*    */

/**
 * 通知客户端战斗操作结果
 */
/*    */ @org.springframework.stereotype.Service
/*    */ public class MSG_COMBAT_ACTION_RESULT extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     Vo_53717_0 object1 = (Vo_53717_0)object;
/* 13 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.attacker_id));
/*    */     
/* 15 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.victim_id));
/*    */     
/* 17 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.type));
/*    */     
/* 19 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.result));
/*    */     
/* 21 */     GameWriteTool.writeString(writeBuf, object1.itemName);
/*    */   }
/*    */   
/* 24 */   public int cmd() { return 53717; }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M53717_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */