/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.MSG_MENU_LIST_VO;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */

/**
 * MSG_MENU_LIST
 */
/*    */ @org.springframework.stereotype.Service
/*    */ public class MSG_MENU_LIST extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 13 */     MSG_MENU_LIST_VO object1 = (MSG_MENU_LIST_VO)object;
/* 14 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.id));
/*    */     
/* 16 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.portrait));
/*    */     
/* 18 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.pic_no));
/*    */     
/* 20 */     GameWriteTool.writeString2(writeBuf, object1.content);
/*    */     
/* 22 */     GameWriteTool.writeString(writeBuf, object1.secret_key);
/*    */     
/* 24 */     GameWriteTool.writeString(writeBuf, object1.name);
/*    */     
/* 26 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.attrib));
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 31 */     return 8247;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M8247_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */