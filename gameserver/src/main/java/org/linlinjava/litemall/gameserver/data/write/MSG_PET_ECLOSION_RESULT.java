/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */

/**
 * 羽化操作结果通知
 */
/*    */ @Service
/*    */ public class MSG_PET_ECLOSION_RESULT
/*    */   extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object) {
    int result = (int) object;
            GameWriteTool.writeByte(writeBuf, result);//result
}
/*    */   
/*    */   public int cmd()
/*    */   {
/* 16 */     return 53607;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M53607_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */