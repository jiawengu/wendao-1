/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_45240_0;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class M45240_0 extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 13 */     Vo_45240_0 object1 = (Vo_45240_0)object;
/* 14 */     GameWriteTool.writeString(writeBuf, object1.tips);
/*    */     
/* 16 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.down_count));
/*    */     
/* 18 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.only_confirm));
/*    */     
/* 20 */     GameWriteTool.writeString(writeBuf, object1.confirm_type);
/*    */     
/* 22 */     GameWriteTool.writeString(writeBuf, object1.confirmText);
/*    */     
/* 24 */     GameWriteTool.writeString(writeBuf, object1.cancelText);
/*    */     
/* 26 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.show_dlg_mode));
/*    */     
/* 28 */     GameWriteTool.writeString(writeBuf, object1.countDownTips);
/*    */     
/* 30 */     GameWriteTool.writeString2(writeBuf, object1.para_str);
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 35 */     return 45240;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M45240_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */