/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_36889_0;
/*    */

/**
 * 重连时通过如下消息发送之前设置的战斗指令
 */
/*    */ @org.springframework.stereotype.Service
/*    */ public class MSG_FIGHT_CMD_INFO extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     Vo_36889_0 object1 = (Vo_36889_0)object;
/* 13 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.count));
/*    */     
/* 15 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.id));
/*    */     
/* 17 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.auto_select));
/*    */     
/* 19 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.multi_index));
/*    */     
/* 21 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.action));
/*    */     
/* 23 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.para));
/*    */     
/* 25 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.multi_count));
/*    */   }
/*    */   
/*    */   public int cmd() {
/* 29 */     return 36889;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M36889_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */