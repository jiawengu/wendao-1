/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_33049_0;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class M33049_0 extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 13 */     Vo_33049_0 object1 = (Vo_33049_0)object;
/* 14 */     GameWriteTool.writeString(writeBuf, object1.goods_gid);
/*    */     
/* 16 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.type));
/*    */     
/* 18 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.result));
/*    */     
/* 20 */     GameWriteTool.writeString(writeBuf, object1.tips);
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 25 */     return 33049;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M33049_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */