/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/*    */

/**
 * MSG_NEW_LOTTERY_OPEN  -- 开启新充值好礼
 */
/*    */ @Service
/*    */ public class M45388_0
/*    */   extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object) {}
/*    */   
/*    */   public int cmd()
/*    */   {
/* 19 */     return 45388;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M45388_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */