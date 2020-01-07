/*    */ package org.linlinjava.litemall.gameserver.netty;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.Channel;
/*    */ import io.netty.channel.ChannelHandler;
      import io.netty.channel.ChannelHandler.Sharable;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import io.netty.channel.ChannelInboundHandlerAdapter;
/*    */ import io.netty.util.Attribute;
/*    */ import io.netty.util.AttributeKey;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
/*    */ import org.slf4j.Logger;
/*    */ import org.slf4j.LoggerFactory;
/*    */ import org.springframework.beans.factory.annotation.Autowired;
/*    */ import org.springframework.beans.factory.annotation.Qualifier;
/*    */ import org.springframework.stereotype.Component;
/*    */ 
/*    */ @Qualifier("serverHandler")
/*    */ @ChannelHandler.Sharable
/*    */ @Component
/*    */ public class ServerHandler extends ChannelInboundHandlerAdapter
/*    */ {
/* 25 */   private static final Logger log = LoggerFactory.getLogger(ServerHandler.class);
/* 26 */   public static final AttributeKey<GameObjectChar> akey = AttributeKey.newInstance("session");
/*    */   @Autowired
/*    */   private java.util.List<GameHandler> gameHandlers;
/*    */   
/* 30 */   public void channelActive(ChannelHandlerContext ctx) throws Exception { super.channelActive(ctx); }
/*    */   
/*    */ 
/*    */   public void channelInactive(ChannelHandlerContext ctx)
/*    */     throws Exception
/*    */   {
/* 36 */     super.channelInactive(ctx);
/* 37 */     Attribute<GameObjectChar> attr = ctx.channel().attr(akey);
/* 38 */     if (attr == null) {
/* 39 */       return;
/*    */     }
/* 41 */     GameObjectChar session = (GameObjectChar)attr.get();
/* 42 */     if ((session == null) || (session.chara == null)) {
/* 43 */       return;
/*    */     }
/* 45 */     GameObjectCharMng.remove(session);
/*    */   }
/*    */   
/*    */ 
/*    */ 
/*    */ 
/*    */   public void channelRead(ChannelHandlerContext ctx, Object msg)
/*    */     throws Exception
/*    */   {
/* 54 */     Attribute<GameObjectChar> attr = ctx.channel().attr(akey);
/* 55 */     GameObjectChar session = null;
/* 56 */     if ((attr != null) && (attr.get() != null)) {
/* 57 */       session = (GameObjectChar)attr.get();
/* 58 */       GameObjectChar.GAMEOBJECTCHAR_THREAD_LOCAL.set(session);
/*    */     }
/* 60 */     ByteBuf buff = (ByteBuf)msg;
/* 61 */     GameReadTool.readInt(buff);
/* 62 */     GameReadTool.readShort(buff);
/* 63 */     int cmd = GameReadTool.readShort(buff);
             if(cmd != 4274){ System.out.println("cmd == " + cmd); }
/* 64 */     for (GameHandler waitLine : this.gameHandlers) {
/* 65 */       if (cmd == waitLine.cmd()) {
/* 66 */         if (session != null) {
                   if(cmd != 4274){ System.out.println("start == " + cmd + ":" + waitLine.toString()); }
/* 67 */           if (session.lock()) {
/*    */             try {
/* 69 */               waitLine.process(ctx, buff);
/*    */             }
/*    */             finally {
/* 72 */               session.unlock();
/*    */             }
/*    */           }
                if(cmd != 4274){ System.out.println("end   == " + cmd + ":" + waitLine.toString()); }
/*    */         } else {
/* 76 */           waitLine.process(ctx, buff);
/* 77 */           break;
/*    */         }
/*    */       }
/*    */     }
/*    */   }
/*    */   
/*    */   public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception
/*    */   {
/* 85 */     if (!cause.toString().contains("java.io.IOException")) {
/* 86 */       log.error("exceptionCaught", cause);
/*    */     }
/* 88 */     ctx.close();
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\netty\ServerHandler.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */