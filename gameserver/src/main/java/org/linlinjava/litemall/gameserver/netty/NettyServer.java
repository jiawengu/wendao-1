/*    */ package org.linlinjava.litemall.gameserver.netty;
/*    */ 
/*    */ import io.netty.bootstrap.ServerBootstrap;
/*    */ import io.netty.channel.ChannelFuture;
/*    */ import io.netty.channel.ChannelOption;
/*    */ import io.netty.channel.EventLoopGroup;
/*    */ import io.netty.channel.nio.NioEventLoopGroup;
/*    */ import io.netty.channel.socket.nio.NioServerSocketChannel;
/*    */ import java.net.InetSocketAddress;
/*    */ import org.slf4j.Logger;
/*    */ import org.slf4j.LoggerFactory;
/*    */ import org.springframework.beans.factory.annotation.Autowired;
/*    */ import org.springframework.stereotype.Component;
/*    */ 
/*    */ 
/*    */ @Component
/*    */ public class NettyServer
/*    */ {
/*    */   @Autowired
/*    */   private ServerChannelInitializer serverChannelInitializer;
/* 21 */   private static final Logger logger = LoggerFactory.getLogger(NettyServer.class);
/*    */   
/* 23 */   public void start(InetSocketAddress address) { EventLoopGroup bossGroup = new NioEventLoopGroup(1);
/* 24 */     EventLoopGroup workerGroup = new NioEventLoopGroup();
/*    */     try
/*    */     {
/* 32 */       ServerBootstrap bootstrap = new ServerBootstrap().group(bossGroup, workerGroup)
                .channel(NioServerSocketChannel.class)
                .localAddress(address)
                .option(ChannelOption.SO_REUSEADDR, true)
                .option(ChannelOption.SO_BACKLOG, 400)
                .option(ChannelOption.SO_RCVBUF, 8196)

                .childOption(ChannelOption.SO_KEEPALIVE, false)
                .childOption(ChannelOption.TCP_NODELAY, true)
                .childOption(ChannelOption.SO_SNDBUF, 2048)
                .childOption(ChannelOption.SO_LINGER, 0)
                .childHandler(this.serverChannelInitializer)
                ;

/* 34 */       ChannelFuture localChannelFuture = bootstrap.bind(address).sync();
/*    */     } catch (Exception e) {
/* 36 */       e.printStackTrace();
/* 37 */       bossGroup.shutdownGracefully();
/* 38 */       workerGroup.shutdownGracefully();
/*    */     }
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\netty\NettyServer.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */