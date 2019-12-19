/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_49183;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_49183_0;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class M49183_0 extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 14 */     Vo_49183_0 object1 = (Vo_49183_0)object;
/* 15 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.totalPage));
/*    */     
/* 17 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.cur_page));
/*    */     
/* 19 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.vo_49183s.size()));
/*    */     
/* 21 */     for (int i = 0; i < object1.vo_49183s.size(); i++) {
/* 22 */       Vo_49183 vo_49183 = (Vo_49183)object1.vo_49183s.get(i);
/*    */       
/* 24 */       GameWriteTool.writeString(writeBuf, vo_49183.name);
/*    */       
/* 26 */       GameWriteTool.writeByte(writeBuf, Integer.valueOf(vo_49183.is_my_goods));
/*    */       
/* 28 */       GameWriteTool.writeString(writeBuf, vo_49183.id);
/*    */       
/* 30 */       GameWriteTool.writeInt(writeBuf, Integer.valueOf(vo_49183.price));
/*    */       
/* 32 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(vo_49183.status));
/*    */       
/* 34 */       GameWriteTool.writeInt(writeBuf, Integer.valueOf(vo_49183.startTime));
/*    */       
/* 36 */       GameWriteTool.writeInt(writeBuf, Integer.valueOf(vo_49183.endTime));
/*    */       
/* 38 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(vo_49183.level));
/*    */       
/* 40 */       GameWriteTool.writeByte(writeBuf, Integer.valueOf(vo_49183.unidentified));
/*    */       
/* 42 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(vo_49183.amount));
/*    */       
/* 44 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(vo_49183.req_level));
/*    */       
/* 46 */       GameWriteTool.writeString(writeBuf, vo_49183.extra);
/*    */       
/* 48 */       GameWriteTool.writeByte(writeBuf, Integer.valueOf(vo_49183.item_polar));
/*    */     }
/*    */     
/*    */ 
/*    */ 
/* 53 */     GameWriteTool.writeString(writeBuf, object1.path_str);
/*    */     
/* 55 */     GameWriteTool.writeString(writeBuf, object1.select_gid);
/*    */     
/* 57 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.sell_stage));
/*    */     
/* 59 */     GameWriteTool.writeString(writeBuf, object1.sort_key);
/*    */     
/* 61 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.is_descending));
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 66 */     return 49183;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M49183_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */