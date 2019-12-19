/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_45072_0;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class M45072_0 extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     Vo_45072_0 object1 = (Vo_45072_0)object;
/* 13 */     GameWriteTool.writeString(writeBuf, object1.new_name);
/*    */   }
/*    */   
/* 16 */   public int cmd() { return 45072; }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M45072_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */