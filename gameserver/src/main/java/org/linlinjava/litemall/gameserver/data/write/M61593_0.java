/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61593_0;
/*    */ //"MSG_CLEAN_ALL_REQUEST",             -- 清空请求列表
/*    */ @org.springframework.stereotype.Service
/*    */ public class M61593_0 extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     Vo_61593_0 object1 = (Vo_61593_0)object;
/* 13 */     GameWriteTool.writeString(writeBuf, object1.ask_type);
/*    */   }
/*    */   
/* 16 */   public int cmd() { return 61593; }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M61593_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */