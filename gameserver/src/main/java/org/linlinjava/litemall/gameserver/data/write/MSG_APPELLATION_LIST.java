/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_62209_0;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class MSG_APPELLATION_LIST extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 15 */     List<Vo_62209_0> object1 = (List)object;
/* 16 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.size()));
/* 17 */     for (int i = 0; i < object1.size(); i++) {
/* 18 */       GameWriteTool.writeString(writeBuf, ((Vo_62209_0)object1.get(i)).stringformat);
/* 19 */       GameWriteTool.writeString(writeBuf, ((Vo_62209_0)object1.get(i)).title);
/* 20 */       GameWriteTool.writeInt(writeBuf, Integer.valueOf(((Vo_62209_0)object1.get(i)).titled_left_time));
/*    */     }
/*    */   }
/*    */   
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 27 */     return 62209;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M62209_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */