/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_13143_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M13143_0;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
/*    */ import org.slf4j.Logger;
/*    */ import org.slf4j.LoggerFactory;
/*    */ import org.springframework.beans.factory.annotation.Value;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class C9040_0 implements GameHandler
/*    */ {
/* 18 */   private static final Logger log = LoggerFactory.getLogger(C9040_0.class);
/*    */   @Value("${netty.ip}")
/*    */   private String ip;
/*    */   
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 24 */     String type = GameReadTool.readString(buff);
/*    */     
/* 26 */     String account = GameReadTool.readString(buff);

/* 27 */     log.debug("account : " + account);
/*    */     
/* 29 */     String password = GameReadTool.readString(buff);
/*    */     
/* 31 */     String mac = GameReadTool.readString(buff);
/*    */     
/* 33 */     String aaass = GameReadTool.readString(buff);
/*    */     
/* 35 */     String lock = GameReadTool.readString(buff);
/*    */     
/* 37 */     String dist = GameReadTool.readString(buff);
/*    */     
/* 39 */     int from3rdSdk = GameReadTool.readByte(buff);
/*    */     
///* 41 */     String channel = GameReadTool.readString(buff);
/*    */     
///* 43 */     String os_ver = GameReadTool.readString(buff);
///*    */
///* 45 */     String term_info = GameReadTool.readString(buff);
///*    */
///* 47 */     String imei = GameReadTool.readString(buff);
///*    */
///* 49 */     String client_original_ver = GameReadTool.readString(buff);
///*    */
///* 51 */     int not_replace = GameReadTool.readByte(buff);
///*    */
/* 53 */     int size = GameObjectCharMng.getAll().size();
/* 54 */     Vo_13143_0 vo_13143_0 = new Vo_13143_0();
/* 55 */     vo_13143_0.result = 1;
/* 56 */     vo_13143_0.privilege = 0;  // 改成一千是gm 账号
/* 57 */     vo_13143_0.ip = this.ip;
/* 58 */     vo_13143_0.port = 14721;
/* 59 */     vo_13143_0.seed = 1446640884;
/* 60 */     vo_13143_0.auth_key = 7726836;
/* 61 */     vo_13143_0.id = 1;
/* 62 */     vo_13143_0.serverName = "一战功成";
/* 63 */     vo_13143_0.serverStatus = 3;
/* 64 */     vo_13143_0.msg = "允许该账号登录";
/* 67 */     ByteBuf write = new M13143_0().write(vo_13143_0);
/* 68 */     ctx.writeAndFlush(write);
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 73 */     return 9040;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C9040_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */