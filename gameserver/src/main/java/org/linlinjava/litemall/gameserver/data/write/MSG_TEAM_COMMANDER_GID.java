/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20568_0;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */

/**
 * 队伍指挥 - 拥有指挥权限的玩家
 */
/*    */ @org.springframework.stereotype.Service
/*    */ public class MSG_TEAM_COMMANDER_GID extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 13 */     Vo_20568_0 object1 = (Vo_20568_0)object;
/* 14 */     GameWriteTool.writeString(writeBuf, object1.gid);
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 19 */     return 20568;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M20568_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */