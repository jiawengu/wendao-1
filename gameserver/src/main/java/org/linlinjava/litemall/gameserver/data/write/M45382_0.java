/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_45382_0;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class M45382_0 extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 13 */     Vo_45382_0 object1 = (Vo_45382_0)object;
/* 14 */     GameWriteTool.writeString(writeBuf, object1.reward_str);
/*    */     
/* 16 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.level));
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 21 */     return 45382;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M45382_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */