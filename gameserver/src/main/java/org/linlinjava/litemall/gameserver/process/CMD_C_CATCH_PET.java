/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_11713_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_53715_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.MSG_C_SANDGLASS;
/*    */ import org.linlinjava.litemall.gameserver.data.write.MSG_SELECT_COMMAND;
/*    */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.fight.FightContainer;
/*    */ import org.linlinjava.litemall.gameserver.fight.FightManager;
/*    */ import org.linlinjava.litemall.gameserver.fight.FightObject;
/*    */ import org.linlinjava.litemall.gameserver.fight.FightRequest;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.springframework.stereotype.Service;
/*    */

/**
 * CMD_C_CATCH_PET
 */
/*    */ @Service
/*    */ public class CMD_C_CATCH_PET implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 23 */     GameObjectChar session = GameObjectChar.getGameObjectChar();
/* 24 */     Chara chara = session.chara;
/* 25 */     FightRequest fr = new FightRequest();
/* 26 */     fr.id = chara.id;
/* 27 */     fr.action = 9;
/* 28 */     fr.vid = 0;
/*    */     
/* 30 */     FightContainer fightContainer = FightManager.getFightContainer();
/*    */     
/* 32 */     FightObject fightObject = FightManager.getFightObject(fightContainer, chara.id);
/* 33 */     FightObject fightObjectPet = FightManager.getFightObjectPet(fightContainer, fightObject);
/* 34 */     if (fightObjectPet == null) {
/* 35 */       Vo_53715_0 vo_53715_0 = new Vo_53715_0();
/* 36 */       vo_53715_0.attacker_id = chara.id;
/* 37 */       vo_53715_0.victim_id = 0;
/* 38 */       vo_53715_0.action = 7;
/* 39 */       vo_53715_0.no = 0;
/* 40 */       GameObjectChar.send(new MSG_SELECT_COMMAND(), vo_53715_0);
/*    */       
/* 42 */       Vo_11713_0 vo_11713_0 = new Vo_11713_0();
/* 43 */       vo_11713_0.id = chara.id;
/* 44 */       vo_11713_0.show = 0;
/* 45 */       GameObjectChar.send(new MSG_C_SANDGLASS(), vo_11713_0);
/*    */     }
/* 47 */     FightManager.addRequest(fightContainer, fr);
/*    */   }
/*    */   
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 53 */     return 4616;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C4616_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */