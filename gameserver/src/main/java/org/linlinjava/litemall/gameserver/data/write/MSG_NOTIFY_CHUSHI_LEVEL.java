/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_53521_0;
/*    */

/**
 * 通知客户端当前服务器最大出师等级
 */
/*    */ @org.springframework.stereotype.Service
/*    */ public class MSG_NOTIFY_CHUSHI_LEVEL extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     Vo_53521_0 object1 = (Vo_53521_0)object;
/* 13 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.chushiLevel));
/*    */   }
/*    */   
/* 16 */   public int cmd() { return 53521; }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M53521_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */