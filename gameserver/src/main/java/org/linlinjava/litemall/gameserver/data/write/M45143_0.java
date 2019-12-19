/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_45143_0;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class M45143_0 extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     Vo_45143_0 object1 = (Vo_45143_0)object;
/* 13 */     GameWriteTool.writeString(writeBuf, object1.line_name);
/*    */     
/* 15 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.expect_time));
/*    */     
/* 17 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.reconnet_time));
/*    */     
/* 19 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.waitCode));
/*    */     
/* 21 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.count));
/*    */     
/* 23 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.keep_alive));
/*    */     
/* 25 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.need_wait));
/*    */     
/* 27 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.indsider_lv));
/*    */     
/* 29 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.gold_coin));
/*    */     
/* 31 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.status));
/*    */   }
/*    */   
/* 34 */   public int cmd() { return 45143; }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M45143_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */