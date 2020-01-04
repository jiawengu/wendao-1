/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import java.util.ArrayList;
/*    */ import java.util.LinkedList;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.MSG_NOTIFY_MISC_EX;
import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE_PETS;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M65527_5;
/*    */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.domain.PetShuXing;
/*    */ import org.linlinjava.litemall.gameserver.domain.Petbeibao;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class C53706_0 implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 24 */     int no = GameReadTool.readByte(buff);
/*    */     
/* 26 */     int num = GameReadTool.readShort(buff);
/*    */     
/* 28 */     int flag = GameReadTool.readByte(buff);
/*    */     
/* 30 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/* 31 */     if (flag == 1) {
/* 32 */       for (int i = 0; i < chara.pets.size(); i++) {
/* 33 */         if (((Petbeibao)chara.pets.get(i)).no == no) {
/* 34 */           ((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(0)).shape += 2000 * num;
/* 35 */           GameUtil.removemunber(chara, "超级神兽丹", num);
/* 36 */           List list = new ArrayList();
/* 37 */           list.add(chara.pets.get(i));
/* 38 */           GameObjectChar.send(new MSG_UPDATE_PETS(), list);
/* 39 */           List list1 = new LinkedList();
/* 40 */           list1.add(Integer.valueOf(((Petbeibao)chara.pets.get(i)).id));
/* 41 */           list1.add(Integer.valueOf(((PetShuXing)((Petbeibao)chara.pets.get(i)).petShuXing.get(0)).shape));
/* 42 */           GameObjectChar.send(new M65527_5(), list1);
/* 43 */           Vo_20481_0 vo_20481_0 = new Vo_20481_0();
/* 44 */           vo_20481_0.msg = ("增加#R" + 2000 * num + "点#n亲密度。");
/* 45 */           vo_20481_0.time = ((int)(System.currentTimeMillis() / 1000L));
/* 46 */           GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
/*    */         }
/*    */       }
/*    */     }
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 54 */     return 53706;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C53706_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */