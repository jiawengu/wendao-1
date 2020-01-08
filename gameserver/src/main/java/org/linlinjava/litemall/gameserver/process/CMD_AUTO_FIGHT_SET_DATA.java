/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.domain.Petbeibao;
/*    */ import org.linlinjava.litemall.gameserver.fight.FightContainer;
/*    */ import org.linlinjava.litemall.gameserver.fight.FightManager;
/*    */ import org.linlinjava.litemall.gameserver.fight.FightObject;
/*    */ import org.linlinjava.litemall.gameserver.fight.FightRequest;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */

/**
 * CMD_AUTO_FIGHT_SET_DATA   -- 设置自动战斗数据
 */
/*    */ @org.springframework.stereotype.Service
/*    */ public class CMD_AUTO_FIGHT_SET_DATA implements org.linlinjava.litemall.gameserver.GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 20 */     int id = GameReadTool.readInt(buff);
/*    */     
/* 22 */     int auto_select = GameReadTool.readByte(buff);
/*    */     
/* 24 */     int multi_index = GameReadTool.readByte(buff);
/*    */     
/* 26 */     int action = GameReadTool.readByte(buff);
/*    */     
/* 28 */     int para = GameReadTool.readInt(buff);
/*    */     
/* 30 */     int multi_count = GameReadTool.readShort(buff);
/*    */     
/* 32 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*    */     
/* 34 */     boolean match = false;
/* 35 */     if (chara.id == id)
/*    */     {
/* 37 */       match = true;
/*    */     }
/*    */     else {
/* 40 */       Petbeibao pet = null;
/* 41 */       List<Petbeibao> pets = chara.pets;
/* 42 */       for (int j = 0; j < pets.size(); j++) {
/* 43 */         if ((((Petbeibao)pets.get(j)).id == chara.chongwuchanzhanId) && (((Petbeibao)pets.get(j)).id == id)) {
/* 44 */           pet = (Petbeibao)pets.get(j);
/* 45 */           break;
/*    */         }
/*    */       }
/* 48 */       if (pet != null) {
/* 49 */         match = true;
/*    */       }
/*    */     }
/* 52 */     if (match) {
/* 53 */       FightObject fightObject = FightManager.getFightObject(id);
/*    */       
/* 55 */       if (fightObject != null) {
/* 56 */         fightObject.autofight_skillaction = action;
/* 57 */         fightObject.autofight_select = auto_select;
/* 58 */         fightObject.autofight_skillno = para;
/* 59 */         FightContainer fightContainer = FightManager.getFightContainer();
/* 60 */         if (fightContainer.state.intValue() == 3) {
/* 61 */           return;
/*    */         }
/*    */         
/* 64 */         FightRequest fightRequest = new FightRequest();
/* 65 */         fightRequest.id = id;
/* 66 */         fightRequest.action = action;
/* 67 */         fightRequest.para = para;
/* 68 */         FightManager.generateActionDM(FightManager.getFightContainer(), fightObject, fightRequest);
/* 69 */         FightManager.addRequest(FightManager.getFightContainer(), fightRequest);
/*    */       }
/*    */     }
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 76 */     return 32984;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C32984_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */