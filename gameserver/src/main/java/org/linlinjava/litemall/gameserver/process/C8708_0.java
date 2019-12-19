/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import java.util.concurrent.atomic.AtomicInteger;
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.fight.FightContainer;
/*    */ import org.linlinjava.litemall.gameserver.fight.FightManager;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.slf4j.Logger;
/*    */ import org.slf4j.LoggerFactory;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class C8708_0 implements org.linlinjava.litemall.gameserver.GameHandler
/*    */ {
/* 17 */   static boolean b = true;
/* 18 */   private static final Logger log = LoggerFactory.getLogger(C8708_0.class);
/*    */   
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 22 */     int answer = GameReadTool.readInt(buff);
/* 23 */     int id = GameObjectChar.getGameObjectChar().chara.id;
/* 24 */     FightContainer fightContainer = FightManager.getFightContainer();
/* 25 */     if (fightContainer == null) {
/* 26 */       return;
/*    */     }
/* 28 */     if ((fightContainer.state.compareAndSet(3, 1)) || (fightContainer.state.get() == 4)) {
/* 29 */       FightManager.nextRoundOrSendOver(FightManager.getFightContainer());
/*    */     }
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 35 */     return 8708;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C8708_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */