/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_53715_0;
/*    */

/**
 * 通知客户端阵营中成员选择了指令
 */
/*    */ @org.springframework.stereotype.Service
/*    */ public class MSG_SELECT_COMMAND extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     Vo_53715_0 object1 = (Vo_53715_0)object;
/* 13 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.attacker_id));
/*    */     
/* 15 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.victim_id));
/*    */     
/* 17 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.action));
/*    */     
/* 19 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.no));
/*    */   }
/*    */   
/* 22 */   public int cmd() { return 53715; }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M53715_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */