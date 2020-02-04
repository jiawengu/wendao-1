/*    */ package org.linlinjava.litemall.gameserver;
/*    */ 
/*    */ import org.linlinjava.litemall.gameserver.disruptor.EventConsumer;
import org.linlinjava.litemall.gameserver.disruptor.GlobalQueue;
import org.linlinjava.litemall.gameserver.disruptor.LogicEvent;
import org.linlinjava.litemall.gameserver.disruptor.World;
import org.linlinjava.litemall.gameserver.game.GameCore;
/*    */ import org.linlinjava.litemall.gameserver.netty.NettyServer;
/*    */ import org.slf4j.Logger;
/*    */ import org.springframework.beans.factory.annotation.Autowired;
/*    */ import org.springframework.beans.factory.annotation.Value;
/*    */ import org.springframework.boot.ApplicationArguments;
/*    */ 
/*    */ @org.springframework.boot.autoconfigure.SpringBootApplication
/*    */ @org.springframework.stereotype.Component
/*    */ @org.springframework.core.annotation.Order(1)
/*    */ public class ApplicationNetty implements org.springframework.boot.ApplicationRunner
/*    */ {

    @Autowired
/*    */   private World world;
private GlobalQueue globalQueue;
/*    */   public static void main(String[] args)
/*    */   {
/* 26 */     System.out.println("run .... . ... :");
/* 27 */     org.springframework.boot.SpringApplication.run(ApplicationNetty.class, args);
/*    */   }
/*    */   
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/* 38 */   private static final Logger log = org.slf4j.LoggerFactory.getLogger(ApplicationNetty.class);
/*    */   
/*    */   public void run(ApplicationArguments args)
/*    */   {
    this.globalQueue = new GlobalQueue(new EventConsumer<LogicEvent>(world));
/* 42 */
/*    */   }

    public GlobalQueue getGlobalQueue() {
        return globalQueue;
    }
    /*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\ApplicationNetty.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */