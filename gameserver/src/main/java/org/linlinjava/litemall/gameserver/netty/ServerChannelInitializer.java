/*    */ package org.linlinjava.litemall.gameserver.netty;
/*    */ 
/*    */ import io.netty.channel.ChannelHandler;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import io.netty.channel.ChannelInitializer;
/*    */ import io.netty.channel.ChannelPipeline;
/*    */ import io.netty.channel.socket.SocketChannel;
/*    */ import io.netty.handler.codec.LengthFieldBasedFrameDecoder;
/*    */ import org.slf4j.Logger;
/*    */ import org.slf4j.LoggerFactory;
/*    */ import org.springframework.beans.factory.annotation.Autowired;
/*    */ import org.springframework.stereotype.Component;
/*    */ 
/*    */ 
/*    */ 
/*    */ @Component
/*    */ public class ServerChannelInitializer
/*    */   extends ChannelInitializer<SocketChannel>
/*    */ {
/*    */   @Autowired
/*    */   private ServerHandler serverHandler;
/* 22 */   private static final Logger log = LoggerFactory.getLogger(ServerChannelInitializer.class);
/*    */   
/*    */ 
/*    */   public void handlerAdded(ChannelHandlerContext channelHandlerContext)
/*    */     throws Exception
/*    */   {}
/*    */   
/*    */   public void handlerRemoved(ChannelHandlerContext channelHandlerContext)
/*    */     throws Exception
/*    */   {}
/*    */   
/*    */   public void exceptionCaught(ChannelHandlerContext channelHandlerContext, Throwable throwable)
/*    */     throws Exception
/*    */   {
/* 36 */     log.error("", throwable);
/*    */   }
/*    */   
/*    */   protected void initChannel(SocketChannel channel) throws Exception {
/* 40 */     channel.pipeline().addLast(new ChannelHandler[] { new LengthFieldBasedFrameDecoder(10240, 8, 2, 0, 4) });
/*    */     
/* 42 */     channel.pipeline().addLast(new ChannelHandler[] { this.serverHandler });
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\netty\ServerChannelInitializer.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */