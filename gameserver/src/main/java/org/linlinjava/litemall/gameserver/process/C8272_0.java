/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import java.util.LinkedList;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE_2;
/*    */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.domain.PetShuXing;
/*    */ import org.linlinjava.litemall.gameserver.domain.Petbeibao;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class C8272_0 implements org.linlinjava.litemall.gameserver.GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 22 */     int no = GameReadTool.readByte(buff);
/*    */     
/* 24 */     String name = GameReadTool.readString(buff);
/*    */     
/* 26 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/* 27 */     int id = 0;
/* 28 */     for (int i = 0; i < chara.pets.size(); i++) {
/* 29 */       if (((Petbeibao)chara.pets.get(i)).no == no) {
/* 30 */         id = ((Petbeibao)chara.pets.get(i)).id;
/* 31 */         ((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(0)).name = name;
/*    */       }
/*    */     }
/* 34 */     Vo_8165_0 vo_8165_0 = new Vo_8165_0();
/* 35 */     vo_8165_0.msg = "宠物名字修改成功。";
/* 36 */     vo_8165_0.active = 0;
/* 38 */     List list = new LinkedList();
/* 39 */     list.add(Integer.valueOf(id));
/* 40 */     list.add(name);
/* 41 */     GameObjectChar.send(new MSG_UPDATE_2(), list);
/*    */   }
/*    */   
/*    */ 
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 48 */     return 8272;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C8272_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */