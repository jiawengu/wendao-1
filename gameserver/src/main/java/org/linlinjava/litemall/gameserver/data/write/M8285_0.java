/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_8285_0;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class M8285_0 extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 13 */     Vo_8285_0 object1 = (Vo_8285_0)object;
/* 14 */     GameWriteTool.writeString(writeBuf, object1.gid);
/*    */     
/* 16 */     GameWriteTool.writeString(writeBuf, object1.name);
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 21 */     return 8285;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M8285_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */