/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_41009_0;
/*    */

/**
 * MSG_REPLY_SERVER_TIME    -- 更新服务器时间
 */
/*    */ @org.springframework.stereotype.Service
/*    */ public class M41009_0 extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     Vo_41009_0 object1 = (Vo_41009_0)object;
/* 13 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.server_time));
/*    */     
/* 15 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.time_zone));
/*    */   }
/*    */   
/* 18 */   public int cmd() { return 41009; }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M41009_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */