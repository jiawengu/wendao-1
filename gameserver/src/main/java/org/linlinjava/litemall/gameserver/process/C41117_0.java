/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import java.util.LinkedList;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.MSG_NOTIFY_MISC_EX;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M65527_3;
/*    */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.domain.PetShuXing;
/*    */ import org.linlinjava.litemall.gameserver.domain.Petbeibao;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class C41117_0
/*    */   implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 24 */     int no = GameReadTool.readByte(buff);
/*    */     
/* 26 */     int num1 = GameReadTool.readShort(buff);
/*    */     
/* 28 */     int num2 = GameReadTool.readShort(buff);
/*    */     
/*    */ 
/* 31 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*    */     
/* 33 */     int id = 0;
/* 34 */     int pot = 0;
/* 35 */     int resist_poison = 0;
/*    */     
/* 37 */     for (int i = 0; i < chara.pets.size(); i++) {
/* 38 */       if (((Petbeibao)chara.pets.get(i)).no == no) {
/* 39 */         if ((((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(0)).skill >= chara.level) || (((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(0)).skill >= 120)) {
/* 40 */           Vo_20481_0 vo_20481_0 = new Vo_20481_0();
/* 41 */           vo_20481_0.msg = "无法使用";
/* 42 */           vo_20481_0.time = ((int)(System.currentTimeMillis() / 1000L));
/* 43 */           GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
/* 44 */           return;
/*    */         }
/* 46 */         id = ((Petbeibao)chara.pets.get(i)).id;
/* 47 */         GameUtil.addpetjingyan((Petbeibao)chara.pets.get(i), num1 * 500000, chara);
/* 48 */         pot = ((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(0)).pot;
/* 49 */         resist_poison = ((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(0)).resist_poison;
/* 50 */         break;
/*    */       }
/*    */     }
/* 53 */     GameUtil.removemunber(chara, "宠物经验丹", num1);
/* 54 */     Vo_20481_0 vo_20481_0 = new Vo_20481_0();
/* 55 */     vo_20481_0.msg = ("你使用了#R" + num1 + "#n颗宠物经验丹。");
/* 56 */     vo_20481_0.time = 1562987118;
/* 57 */     GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
/*    */     
/*    */ 
/* 60 */     List list = new LinkedList();
/* 61 */     list.add(Integer.valueOf(id));
/* 62 */     list.add(Integer.valueOf(pot));
/* 63 */     list.add(Integer.valueOf(resist_poison));
/* 64 */     GameObjectChar.send(new M65527_3(), list);
/*    */   }
/*    */   
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 70 */     return 41117;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C41117_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */