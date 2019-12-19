/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_45239_0;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class M45239_0 extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     Vo_45239_0 object1 = (Vo_45239_0)object;
/* 13 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.ti));
/*    */     
/* 15 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.state));
/*    */     
/* 17 */     GameWriteTool.writeString(writeBuf, object1.task_name);
/*    */     
/* 19 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.is_smart));
/*    */   }
/*    */   
/* 22 */   public int cmd() { return 45239; }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M45239_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */