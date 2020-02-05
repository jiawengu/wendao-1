/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_49179;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_49179_0;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class MSG_STALL_MINE extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 16 */     Vo_49179_0 object1 = (Vo_49179_0)object;
/* 17 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.dealNum));
/*    */     
/* 19 */     GameWriteTool.writeString(writeBuf, object1.sellCash);
/*    */     
/* 21 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.stallTotalNum));
/*    */     
/* 23 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.record_count_max));
/*    */     
/* 25 */     List<Vo_49179> vo_49179 = object1.vo_49179s;
/*    */     
/* 27 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(vo_49179.size()));
/*    */     
/* 29 */     for (int i = 0; i < vo_49179.size(); i++) {
/* 30 */       Vo_49179 vo_491791 = (Vo_49179)vo_49179.get(i);
/*    */       
/* 32 */       GameWriteTool.writeString(writeBuf, vo_491791.name);
/*    */       
/* 34 */       GameWriteTool.writeString(writeBuf, vo_491791.id);
/*    */       
/* 36 */       GameWriteTool.writeInt(writeBuf, Integer.valueOf(vo_491791.price));
/*    */       
/* 38 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(vo_491791.pos));
/*    */       
/* 40 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(vo_491791.status));
/*    */       
/* 42 */       GameWriteTool.writeInt(writeBuf, Integer.valueOf(vo_491791.startTime));
/*    */       
/* 44 */       GameWriteTool.writeInt(writeBuf, Integer.valueOf(vo_491791.endTime));
/*    */       
/* 46 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(vo_491791.level));
/*    */       
/* 48 */       GameWriteTool.writeByte(writeBuf, Integer.valueOf(vo_491791.unidentified));
/*    */       
/* 50 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(vo_491791.amount));
/*    */       
/* 52 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(vo_491791.req_level));
/*    */       
/* 54 */       GameWriteTool.writeByte(writeBuf, Integer.valueOf(vo_491791.extra));
/*    */       
/* 56 */       GameWriteTool.writeByte(writeBuf, Integer.valueOf(vo_491791.item_polar));
/*    */       
/* 58 */       GameWriteTool.writeByte(writeBuf, Integer.valueOf(vo_491791.cg_price_count));
/*    */       
/* 60 */       GameWriteTool.writeInt(writeBuf, Integer.valueOf(vo_491791.init_price));
/*    */     }
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 66 */     return 49179;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M49179_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */