/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_53399_0;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */

/**
 * 通知推送开关信息
 */
/*    */ @org.springframework.stereotype.Service
/*    */ public class MSG_SET_PUSH_SETTINGS extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 13 */     Vo_53399_0 object1 = (Vo_53399_0)object;
/* 14 */     GameWriteTool.writeString(writeBuf, object1.value);
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 19 */     return 53399;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M53399_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */